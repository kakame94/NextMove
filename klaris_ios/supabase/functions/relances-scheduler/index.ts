// Klaris — Relances Scheduler Edge Function
//
// Cron: every 15 minutes (Supabase scheduled functions).
// Spec: docs/relances/relances-decision-matrix.md v1.2
//       24_NextMove/klaris_relances_rules_claude.md
//
// Flow per tick:
//   1. SELECT pending relances scheduled_for <= now() FOR UPDATE SKIP LOCKED
//   2. For each: evaluate 13 guards (M2) sequentially
//   3. SEND → Twilio SMS + INSERT audit log + UPDATE relance.status='sent'
//      BLOCK → INSERT audit log + UPDATE relance.status='skipped'
//      DEFER → UPDATE relance.scheduled_for = retry_at
//   4. UPDATE relances_scheduler_state (last_run metrics)
//
// Deploy:
//   supabase functions deploy relances-scheduler
//   supabase functions schedule create relances-scheduler --cron "*/15 * * * *"
//
// Secrets required (Supabase project):
//   TWILIO_ACCOUNT_SID
//   TWILIO_AUTH_TOKEN
//   TWILIO_FROM_NUMBER

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY  = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const TWILIO_SID   = Deno.env.get('TWILIO_ACCOUNT_SID')!;
const TWILIO_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN')!;
const TWILIO_FROM  = Deno.env.get('TWILIO_FROM_NUMBER')!;

const BATCH_SIZE        = 100;
const BUDGET_MAX_CAD    = 500;
const SENDER_SCORE_MIN  = 97;
const TWILIO_TIMEOUT_MS = 8_000;
const RETRY_DELAY_MS    = 2_000;

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

type Action = 'SEND' | 'BLOCK' | 'DEFER';

interface Decision {
  action: Action;
  reason: string;
  retry_at: string | null;
  audit_message: string;
  guards_evaluated: string[];
}

interface Prospect {
  id: string;
  courtier_id: string;
  phone: string | null;
  status: string;
  score: number;
  pause_relances: boolean;
  opted_out_at: string | null;
  last_inbound_at: string | null;
  locale: string | null;
  nom: string | null;
}

interface Relance {
  id: string;
  prospect_id: string;
  step: 'j2' | 'j5';
  status: string;
  scheduled_for: string;
  content: string | null;
}

// =============================================================================
// Entrypoint
// =============================================================================

Deno.serve(async () => {
  const start = Date.now();
  let processed = 0, sent = 0, blocked = 0, deferred = 0, errors = 0;
  let lastError: string | null = null;

  try {
    // 1. Fetch pending relances with FOR UPDATE SKIP LOCKED (idempotent cron)
    const candidates = await fetchPendingRelances();
    processed = candidates.length;

    for (const relance of candidates) {
      try {
        const prospect = await fetchProspect(relance.prospect_id);
        if (!prospect) {
          await logDecision(relance, null, {
            action: 'BLOCK',
            reason: 'prospect_not_found',
            retry_at: null,
            audit_message: `Prospect ${relance.prospect_id} introuvable.`,
            guards_evaluated: [],
          });
          await updateRelanceStatus(relance.id, 'skipped');
          blocked++;
          continue;
        }

        const type = `inactif_${relance.step}`;  // 'inactif_j2' | 'inactif_j5'
        const history = await fetchHistory(prospect.id);
        const decision = await canSendRelance(prospect, type, new Date(), history);

        await logDecision(relance, prospect, decision);

        switch (decision.action) {
          case 'SEND': {
            const sendOk = await sendSms(prospect, relance);
            if (sendOk) {
              await updateRelanceStatus(relance.id, 'sent', new Date());
              sent++;
            } else {
              await updateRelanceStatus(relance.id, 'skipped');
              errors++;
              lastError = `Twilio failed for relance ${relance.id}`;
            }
            break;
          }
          case 'BLOCK': {
            await updateRelanceStatus(relance.id, 'skipped');
            blocked++;
            break;
          }
          case 'DEFER': {
            await deferRelance(relance.id, decision.retry_at!);
            deferred++;
            break;
          }
        }
      } catch (e) {
        errors++;
        lastError = e instanceof Error ? e.message : String(e);
        console.error(`Error processing relance ${relance.id}:`, e);
      }
    }

    await updateSchedulerState({
      duration_ms: Date.now() - start,
      processed, sent, blocked, deferred, errors,
      error_message: lastError,
    });

    return new Response(
      JSON.stringify({ ok: true, processed, sent, blocked, deferred, errors }),
      { headers: { 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    console.error('Scheduler fatal error:', e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});

// =============================================================================
// Guards M2 — pure sync evaluator + async orchestrator
// =============================================================================
//
// `evaluateGuards()` is pure (no IO) — fully unit-testable.
// `canSendRelance()` resolves external state then delegates.

export interface GuardContext {
  blacklisted: boolean;
  isHoliday: boolean;
  monthlyCostCAD: number;
  senderScore: number;
  templateExists: boolean;
}

export function evaluateGuards(
  prospect: Prospect,
  typeRelance: string,
  now: Date,
  history: { type: string; sent_at: string; status: string }[],
  ctx: GuardContext,
): Decision {
  const guards: string[] = [];

  // G1 — Blacklist
  guards.push('G1');
  if (ctx.blacklisted) {
    return block('blacklist_phone', 'Numéro blacklisté.', guards);
  }

  // G2 — STOP CASL < 90 jours
  guards.push('G2');
  if (prospect.opted_out_at) {
    const ageDays = (now.getTime() - new Date(prospect.opted_out_at).getTime()) / 86_400_000;
    if (ageDays < 90) {
      return block('opted_out_stop',
        `Opt-out le ${prospect.opted_out_at.slice(0, 10)} (< 90 jours). CASL/Loi 25.`,
        guards);
    }
  }

  // G3 — status='perdu' + type non-réactivation
  guards.push('G3');
  if (prospect.status === 'perdu' && typeRelance !== 'reactivation_longterme') {
    return block('pipeline_closed', 'Prospect status=perdu, pipeline fermé.', guards);
  }

  // G4 — Human active (inbound < 24h)
  guards.push('G4');
  if (prospect.last_inbound_at) {
    const hrsSince = (now.getTime() - new Date(prospect.last_inbound_at).getTime()) / 3_600_000;
    if (hrsSince < 24) {
      return block('human_active',
        `Prospect a écrit il y a ${hrsSince.toFixed(1)}h. Humain actif.`,
        guards);
    }
  }

  // G5 — Courtier pause
  guards.push('G5');
  if (prospect.pause_relances) {
    return block('courtier_override', 'Override courtier: pause_relances=true.', guards);
  }

  // G6 — Cadence min
  guards.push('G6');
  const lastSameType = history
    .filter(h => h.type === typeRelance && h.status === 'sent')
    .sort((a, b) => b.sent_at.localeCompare(a.sent_at))[0];
  if (lastSameType) {
    const cadenceMs = CADENCE_MIN[typeRelance] ?? 0;
    const elapsed = now.getTime() - new Date(lastSameType.sent_at).getTime();
    if (elapsed < cadenceMs) {
      return block(`cadence_not_elapsed_${Math.floor(cadenceMs / 86_400_000)}d`,
        `Cadence ${typeRelance} non respectée.`, guards);
    }
  }

  // G7 — Max attempts
  guards.push('G7');
  const attempts = history.filter(h => h.type === typeRelance).length;
  const maxAttempts = MAX_ATTEMPTS[typeRelance] ?? 1;
  if (attempts >= maxAttempts) {
    return block('max_attempts_reached',
      `Max ${maxAttempts} tentatives atteint pour ${typeRelance}.`, guards);
  }

  // G13 — Anti-spam global 48h
  guards.push('G13');
  const relances48h = history.filter(h => {
    const hrs = (now.getTime() - new Date(h.sent_at).getTime()) / 3_600_000;
    return hrs <= 48 && h.status === 'sent';
  }).length;
  if (relances48h >= 2) {
    return block('global_spam_guard_48h',
      `${relances48h} relances dans 48h. Anti-harcèlement.`, guards);
  }

  // G8 — Business hours 8h-20h locale Québec
  guards.push('G8');
  const localHour = quebecLocalHour(now, prospect.locale);
  if (localHour < 8 || localHour >= 20) {
    const next9am = nextBusinessDay9am(now, prospect.locale);
    return defer(next9am, 'outside_business_hours',
      `${localHour}h locale Québec. Reprogrammé ${next9am}.`, guards);
  }

  // G9 — Holiday Québec
  guards.push('G9');
  if (ctx.isHoliday) {
    const next9am = nextBusinessDay9am(now, prospect.locale);
    return defer(next9am, 'quebec_holiday',
      `Jour férié QC. Reprogrammé ${next9am}.`, guards);
  }

  // G11 — Budget Twilio
  guards.push('G11');
  if (ctx.monthlyCostCAD > BUDGET_MAX_CAD) {
    return block('budget_exceeded', `Budget mensuel > ${BUDGET_MAX_CAD} CAD.`, guards);
  }

  // G12 — Sender score
  guards.push('G12');
  if (ctx.senderScore < SENDER_SCORE_MIN) {
    const retryAt = new Date(now.getTime() + 2 * 3_600_000).toISOString();
    return defer(retryAt, 'sender_score_degraded',
      'Sender score < 97, déféré 2h.', guards);
  }

  // G10 — Template exists
  guards.push('G10');
  if (!ctx.templateExists) {
    return block('no_template_available',
      `Template manquant: ${typeRelance}/sms/fr-CA.`, guards);
  }

  // All guards passed
  return {
    action: 'SEND',
    reason: 'all_guards_passed',
    retry_at: null,
    audit_message: `Relance ${typeRelance} → ${prospect.nom ?? prospect.id} (golden hour ${localHour}h).`,
    guards_evaluated: guards,
  };
}

export async function canSendRelance(
  prospect: Prospect,
  typeRelance: string,
  now: Date,
  history: { type: string; sent_at: string; status: string }[],
): Promise<Decision> {
  const ctx: GuardContext = {
    blacklisted:    await isBlacklisted(prospect.phone),
    isHoliday:      await isQuebecHoliday(now),
    monthlyCostCAD: await twilioMonthlyCost(),
    senderScore:    await twilioSenderScore(),
    templateExists: templateExists(typeRelance, 'sms', 'fr-CA'),
  };
  const decision = evaluateGuards(prospect, typeRelance, now, history, ctx);

  // Side effects for failing infra guards
  if (decision.reason === 'budget_exceeded') await alertAdmin('Budget Twilio dépassé');
  if (decision.reason === 'sender_score_degraded') await alertAdmin('Sender score dégradé');

  return decision;
}

// =============================================================================
// Cadence + max_attempts (mirror spec v1.2)
// =============================================================================

const ONE_DAY = 86_400_000;
const ONE_HOUR = 3_600_000;

const CADENCE_MIN: Record<string, number> = {
  inactif_j2:            5 * ONE_DAY,
  inactif_j5:            30 * ONE_DAY,
  nudge_courtier_chaud:  48 * ONE_HOUR,
  nudge_courtier_urgent: 4 * ONE_HOUR,
  rdv_rappel_j1:         1 * ONE_DAY,
  rdv_rappel_j7:         1 * ONE_DAY,
  post_rdv_feedback:     30 * ONE_DAY,
  etape_financement:     5 * ONE_DAY,
  reactivation_longterme: 180 * ONE_DAY,
  briefing_quotidien:    24 * ONE_HOUR,
};

const MAX_ATTEMPTS: Record<string, number> = {
  inactif_j2:            1,
  inactif_j5:            1,
  nudge_courtier_chaud:  3,
  nudge_courtier_urgent: 5,
  rdv_rappel_j1:         1,
  rdv_rappel_j7:         1,
  post_rdv_feedback:     1,
  etape_financement:     2,
  reactivation_longterme: 1,
  briefing_quotidien:    1,
};

// =============================================================================
// Helpers
// =============================================================================

function block(reason: string, msg: string, guards: string[]): Decision {
  return { action: 'BLOCK', reason, retry_at: null, audit_message: msg, guards_evaluated: guards };
}

function defer(retryAt: string, reason: string, msg: string, guards: string[]): Decision {
  return { action: 'DEFER', reason, retry_at: retryAt, audit_message: msg, guards_evaluated: guards };
}

export function quebecLocalHour(utc: Date, locale: string | null): number {
  // Default America/Toronto (covers Québec).
  const tz = locale ?? 'America/Toronto';
  const fmt = new Intl.DateTimeFormat('en-CA', {
    timeZone: tz, hour: '2-digit', hour12: false,
  });
  return parseInt(fmt.format(utc), 10);
}

export function nextBusinessDay9am(utc: Date, locale: string | null): string {
  const tz = locale ?? 'America/Toronto';
  // Find next 9h local. If already past 9h today, next day. Else today 9h.
  // Approximation: UTC offset Toronto ~ -4h summer / -5h winter.
  // For precision, defer to client / day boundary check.
  const local = new Date(utc.toLocaleString('en-CA', { timeZone: tz }));
  const tomorrow = new Date(local);
  tomorrow.setDate(local.getDate() + 1);
  tomorrow.setHours(9, 0, 0, 0);
  // Convert back to UTC ISO (approximate; production should use full TZ math).
  return tomorrow.toISOString();
}

// -- Data layer --------------------------------------------------------------

async function fetchPendingRelances(): Promise<Relance[]> {
  // FOR UPDATE SKIP LOCKED via RPC (Supabase JS doesn't expose it directly).
  const { data, error } = await admin.rpc('claim_pending_relances', {
    p_batch_size: BATCH_SIZE,
  });
  if (error) {
    // Fallback: simple select (less idempotent if multiple crons overlap).
    const { data: rows } = await admin
      .from('relances')
      .select('id, prospect_id, step, status, scheduled_for, content')
      .eq('status', 'pending')
      .lte('scheduled_for', new Date().toISOString())
      .limit(BATCH_SIZE);
    return rows ?? [];
  }
  return (data ?? []) as Relance[];
}

async function fetchProspect(prospectId: string): Promise<Prospect | null> {
  const { data } = await admin
    .from('prospects')
    .select('id, courtier_id, phone, status, score, pause_relances, opted_out_at, last_inbound_at, locale, nom')
    .eq('id', prospectId)
    .single();
  return (data as Prospect) ?? null;
}

async function fetchHistory(prospectId: string) {
  const { data } = await admin
    .from('relances')
    .select('step, sent_at, status')
    .eq('prospect_id', prospectId)
    .not('sent_at', 'is', null);
  return (data ?? []).map(r => ({
    type: `inactif_${r.step}`,
    sent_at: r.sent_at as string,
    status: r.status as string,
  }));
}

async function isBlacklisted(phone: string | null): Promise<boolean> {
  if (!phone) return false;
  const { data } = await admin
    .from('blacklist')
    .select('phone')
    .eq('phone', phone)
    .maybeSingle();
  return data !== null;
}

async function isQuebecHoliday(now: Date): Promise<boolean> {
  const date = now.toISOString().slice(0, 10);
  const { data } = await admin
    .from('holidays_qc')
    .select('date')
    .eq('date', date)
    .maybeSingle();
  return data !== null;
}

async function twilioMonthlyCost(): Promise<number> {
  // Approximate via local relances count × 0.01 CAD (Twilio CA-CA SMS rate).
  // Replace with Twilio API usage endpoint for prod accuracy.
  const firstOfMonth = new Date();
  firstOfMonth.setDate(1);
  firstOfMonth.setHours(0, 0, 0, 0);
  const { count } = await admin
    .from('relances')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'sent')
    .gte('sent_at', firstOfMonth.toISOString());
  return (count ?? 0) * 0.01;
}

async function twilioSenderScore(): Promise<number> {
  // TODO: integrate Twilio Trust Hub Brand Score API.
  // Stub returns 99 — replace before prod load test.
  return 99;
}

function templateExists(type: string, canal: string, lang: string): boolean {
  return TEMPLATES.has(`${type}|${canal}|${lang}`);
}

const TEMPLATES = new Map<string, string>([
  ['inactif_j2|sms|fr-CA',
   "Bonjour {{PRENOM}}! C'est l'assistante de {{NOM_COURTIER}}. On attend toujours vos documents pour la pré-qualification. Besoin d'aide avec ça? STOP pour arrêter."],
  ['inactif_j5|sms|fr-CA',
   "Bonjour {{PRENOM}}! Juste un rappel amical pour les documents. Si questions, {{NOM_COURTIER}} est disponible. STOP pour arrêter."],
  ['rdv_rappel_j1|sms|fr-CA',
   "Bonjour {{PRENOM}}! Petit rappel: votre rencontre avec {{NOM_COURTIER}} est demain à {{HEURE}} à {{LIEU}}. À demain! STOP."],
  ['post_rdv_feedback|sms|fr-CA',
   "Bonjour {{PRENOM}}! Comment s'est passée la visite d'hier? {{NOM_COURTIER}} est dispo si questions. STOP."],
  ['etape_financement|sms|fr-CA',
   "Bonjour! Suivi pour le dossier de {{NOM_CLIENT}} (pré-qualification). {{NOM_COURTIER}} aimerait avancer. Merci! STOP."],
  ['nudge_courtier_chaud|push|fr-CA',
   "[ALERTE] {{NOM_CLIENT}} (score {{SCORE}}/10) attend depuis 24h. Voulez-vous relancer?"],
]);

async function sendSms(prospect: Prospect, relance: Relance): Promise<boolean> {
  if (!prospect.phone) return false;
  const body = relance.content
    ?? TEMPLATES.get(`inactif_${relance.step}|sms|fr-CA`)
    ?? '';
  if (!body) return false;

  const url = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_SID}/Messages.json`;
  const auth = btoa(`${TWILIO_SID}:${TWILIO_TOKEN}`);
  const params = new URLSearchParams({ From: TWILIO_FROM, To: prospect.phone, Body: body });

  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString(),
        signal: AbortSignal.timeout(TWILIO_TIMEOUT_MS),
      });
      if (res.ok) return true;
    } catch (e) {
      console.error(`Twilio send attempt ${attempt} failed:`, e);
    }
    if (attempt === 0) await new Promise(r => setTimeout(r, RETRY_DELAY_MS));
  }
  return false;
}

async function logDecision(relance: Relance, prospect: Prospect | null, d: Decision) {
  await admin.from('relance_decisions').insert({
    prospect_id: relance.prospect_id,
    courtier_id: prospect?.courtier_id ?? null,
    type_relance: `inactif_${relance.step}`,
    action: d.action,
    reason: d.reason,
    retry_at: d.retry_at,
    guards_evaluated: d.guards_evaluated,
    audit_message: d.audit_message,
  });
}

async function updateRelanceStatus(id: string, status: string, sentAt?: Date) {
  const patch: Record<string, unknown> = { status };
  if (sentAt) patch.sent_at = sentAt.toISOString();
  await admin.from('relances').update(patch).eq('id', id);
}

async function deferRelance(id: string, retryAt: string) {
  await admin.from('relances').update({ scheduled_for: retryAt }).eq('id', id);
}

async function updateSchedulerState(s: {
  duration_ms: number;
  processed: number; sent: number; blocked: number;
  deferred: number; errors: number;
  error_message: string | null;
}) {
  await admin.from('relances_scheduler_state').upsert({
    id: true,
    last_run_at: new Date().toISOString(),
    last_run_duration_ms: s.duration_ms,
    last_processed: s.processed,
    last_sent: s.sent,
    last_blocked: s.blocked,
    last_deferred: s.deferred,
    last_errors: s.errors,
    last_error_message: s.error_message,
  });
}

async function alertAdmin(message: string) {
  // TODO: Slack webhook integration. For now, console.error.
  console.error(`ADMIN ALERT: ${message}`);
}
