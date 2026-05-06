// Klaris — Voicemail Intake
// Twilio webhook → Whisper transcription → Claude qualification → upsert prospect.
//
// Twilio webhook URL (configure in Twilio Console):
//   POST https://<project>.supabase.co/functions/v1/voicemail-intake
//
// Twilio request fields used:
//   From (caller phone), CallSid, RecordingUrl, RecordingDuration

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const OPENAI_KEY = Deno.env.get('OPENAI_API_KEY')!;
const ANTHROPIC_KEY = Deno.env.get('ANTHROPIC_API_KEY')!;
const TWILIO_SID = Deno.env.get('TWILIO_ACCOUNT_SID')!;
const TWILIO_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN')!;
const COURTIER_ID = Deno.env.get('DEFAULT_COURTIER_ID')!;  // single-broker pilot; agency lookup later.

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

interface QualifResult {
  type: 'acheteur' | 'vendeur' | null;
  secteur: string | null;
  budget: number | null;
  delai: string | null;
  pre_approuve: boolean;
  summary: string;
}

Deno.serve(async (req: Request) => {
  try {
    const form = await req.formData();
    const from = (form.get('From') as string) || '';
    const callSid = (form.get('CallSid') as string) || '';
    const recordingUrl = (form.get('RecordingUrl') as string) || '';
    const duration = parseInt((form.get('RecordingDuration') as string) || '0', 10);

    if (!recordingUrl || duration < 3) {
      return twiml('<Response><Say language="fr-CA">Message trop court. Merci.</Say></Response>');
    }

    // 1. Fetch the recording (Twilio audio URL needs Basic auth with SID/Token).
    const audioRes = await fetch(`${recordingUrl}.mp3`, {
      headers: { Authorization: `Basic ${btoa(`${TWILIO_SID}:${TWILIO_TOKEN}`)}` },
    });
    if (!audioRes.ok) throw new Error(`recording fetch failed ${audioRes.status}`);
    const audioBlob = await audioRes.blob();

    // 2. Transcribe via Whisper.
    const fd = new FormData();
    fd.append('file', audioBlob, 'voicemail.mp3');
    fd.append('model', 'whisper-1');
    fd.append('language', 'fr');
    const whisperRes = await fetch('https://api.openai.com/v1/audio/transcriptions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${OPENAI_KEY}` },
      body: fd,
    });
    if (!whisperRes.ok) throw new Error(`whisper failed ${whisperRes.status}`);
    const { text: transcript } = await whisperRes.json() as { text: string };

    // 3. Qualify with Claude.
    const qualif = await qualifyWithClaude(transcript);

    // 4. Compute heat score (same coefficients as web/iOS).
    const score = computeScore(qualif);

    // 5. Upsert prospect (matched by phone).
    const { data: existing } = await supabase
      .from('prospects')
      .select('id')
      .eq('telephone', from)
      .eq('courtier_id', COURTIER_ID)
      .maybeSingle();

    let prospectId: string;
    if (existing) {
      prospectId = existing.id;
      await supabase.from('prospects').update({
        type: qualif.type,
        secteur: qualif.secteur,
        budget: qualif.budget,
        delai: qualif.delai,
        pre_approuve: qualif.pre_approuve,
        score,
        status: 'qualifie',
      }).eq('id', prospectId);
    } else {
      const { data: ins } = await supabase.from('prospects').insert({
        courtier_id: COURTIER_ID,
        telephone: from,
        type: qualif.type,
        secteur: qualif.secteur,
        budget: qualif.budget,
        delai: qualif.delai,
        pre_approuve: qualif.pre_approuve,
        score,
        status: 'qualifie',
      }).select('id').single();
      prospectId = ins!.id as string;
    }

    // 6. Log the transcript as a conversation message.
    await supabase.from('conversations').insert({
      prospect_id: prospectId,
      direction: 'inbound',
      sender: 'prospect',
      content: `📞 Voicemail (${duration}s) :\n\n${transcript}\n\n— Résumé Klaris —\n${qualif.summary}`,
      sent_at: new Date().toISOString(),
    });

    // 7. Audit trail (OACIQ).
    await supabase.from('audit_log').insert({
      user_id: COURTIER_ID,
      prospect_id: prospectId,
      action: 'voicemail_qualified',
      payload: { call_sid: callSid, score, duration },
    });

    return twiml('<Response><Say language="fr-CA">Merci. Le courtier vous rappellera bientot.</Say></Response>');
  } catch (e) {
    console.error('voicemail-intake-fail', e);
    return twiml('<Response><Say language="fr-CA">Une erreur est survenue. Merci de rappeler.</Say></Response>');
  }
});

async function qualifyWithClaude(transcript: string): Promise<QualifResult> {
  const sys = `Tu es Klaris, l'adjointe IA d'un courtier immobilier québécois. À partir d'un transcript vocal, retourne UNIQUEMENT un JSON valide avec ces champs :
  - type: "acheteur" | "vendeur" | null
  - secteur: string | null (ex: "Verdun", "Plateau")
  - budget: int | null (en CAD)
  - delai: string | null (un parmi "<1 mois", "1-3 mois", "3-6 mois", "6-12 mois", ">12 mois")
  - pre_approuve: bool
  - summary: string (résumé en 1-2 phrases en français québécois naturel)

  Si une info n'est pas mentionnée, mets null. Pas de markdown, pas d'explication, juste le JSON.`;

  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': ANTHROPIC_KEY,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 500,
      system: sys,
      messages: [{ role: 'user', content: transcript }],
    }),
  });
  const json = await res.json();
  const text = (json.content?.[0]?.text as string) || '{}';
  // Strip any code fences just in case.
  const clean = text.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '').trim();
  return JSON.parse(clean) as QualifResult;
}

function computeScore(q: QualifResult): number {
  let s = 0;
  if (q.pre_approuve) s += 3;
  if (q.delai === '<1 mois' || q.delai === '1-3 mois') s += 2;
  if (q.budget && q.budget > 0) s += 2;
  if (q.secteur) s += 1;
  if (q.type) s += 1;
  return Math.max(0, Math.min(10, s));
}

function twiml(body: string): Response {
  return new Response(body, {
    status: 200,
    headers: { 'content-type': 'text/xml' },
  });
}
