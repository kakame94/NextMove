// Klaris — relances-scheduler tests
//
// Run:
//   deno test --allow-env supabase/functions/relances-scheduler/index.test.ts
//
// Covers all 13 guards (G1-G13) + 5 nominal SEND cases.
// Pure-function tests via evaluateGuards(); no DB IO.

import { assertEquals } from 'jsr:@std/assert@1';
import { evaluateGuards, type GuardContext } from './index.ts';

// -----------------------------------------------------------------------------
// Fixtures
// -----------------------------------------------------------------------------

const NOW = new Date('2026-05-13T14:00:00Z'); // Mer 14h UTC = 10h Toronto

function baseProspect(overrides: Record<string, unknown> = {}) {
  return {
    id: 'uuid-prospect-1',
    courtier_id: 'uuid-courtier-1',
    phone: '+15145551234',
    status: 'actif',
    score: 6,
    pause_relances: false,
    opted_out_at: null as string | null,
    last_inbound_at: null as string | null,
    locale: 'America/Toronto',
    nom: 'Marie Tremblay',
    ...overrides,
  };
}

function passingCtx(overrides: Partial<GuardContext> = {}): GuardContext {
  return {
    blacklisted: false,
    isHoliday: false,
    monthlyCostCAD: 100,
    senderScore: 99,
    templateExists: true,
    ...overrides,
  };
}

// =============================================================================
// 13 GUARD TESTS (G1 → G13)
// =============================================================================

Deno.test('G1 — blacklist BLOCKS', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ blacklisted: true }),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'blacklist_phone');
});

Deno.test('G2 — opt-out STOP < 90 days BLOCKS', () => {
  const d = evaluateGuards(
    baseProspect({ opted_out_at: '2026-05-10T14:00:00Z' }), // 3 days ago
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'opted_out_stop');
});

Deno.test('G2 — opt-out STOP > 90 days does NOT block reactivation type', () => {
  // 100 days ago
  const optedOutAt = new Date(NOW.getTime() - 100 * 86_400_000).toISOString();
  const d = evaluateGuards(
    baseProspect({ opted_out_at: optedOutAt, status: 'perdu' }),
    'reactivation_longterme',
    NOW,
    [],
    passingCtx({ templateExists: true }),
  );
  // G2 passes; G3 passes (reactivation type); should NOT be BLOCK on G2/G3.
  // (May fail later on missing template, that's fine — verifies G2 logic.)
  assertEquals(d.reason !== 'opted_out_stop', true);
  assertEquals(d.reason !== 'pipeline_closed', true);
});

Deno.test('G3 — status=perdu BLOCKS non-reactivation types', () => {
  const d = evaluateGuards(
    baseProspect({ status: 'perdu' }),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'pipeline_closed');
});

Deno.test('G4 — human active (inbound < 24h) BLOCKS', () => {
  const recent = new Date(NOW.getTime() - 2 * 3_600_000).toISOString(); // 2h ago
  const d = evaluateGuards(
    baseProspect({ last_inbound_at: recent }),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'human_active');
});

Deno.test('G5 — courtier pause BLOCKS', () => {
  const d = evaluateGuards(
    baseProspect({ pause_relances: true }),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'courtier_override');
});

Deno.test('G6 — cadence not elapsed BLOCKS', () => {
  const recentSend = new Date(NOW.getTime() - 2 * 86_400_000).toISOString(); // 2j ago
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [{ type: 'inactif_j2', sent_at: recentSend, status: 'sent' }],
    passingCtx(),
  );
  // cadence min = 5j; only 2j elapsed → BLOCK
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason.startsWith('cadence_not_elapsed'), true);
});

Deno.test('G7 — max attempts reached BLOCKS', () => {
  // inactif_j2 max=1; if 1 already in history with any status → BLOCK
  const oldSend = new Date(NOW.getTime() - 60 * 86_400_000).toISOString(); // 60j ago (cadence OK)
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [{ type: 'inactif_j2', sent_at: oldSend, status: 'sent' }],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'max_attempts_reached');
});

Deno.test('G13 — global anti-spam 48h BLOCKS', () => {
  // 2 different-type relances within 48h
  const recent1 = new Date(NOW.getTime() - 12 * 3_600_000).toISOString();
  const recent2 = new Date(NOW.getTime() - 24 * 3_600_000).toISOString();
  const d = evaluateGuards(
    baseProspect(),
    'etape_financement', // different type to avoid G6/G7 first
    NOW,
    [
      { type: 'inactif_j2',           sent_at: recent1, status: 'sent' },
      { type: 'nudge_courtier_chaud', sent_at: recent2, status: 'sent' },
    ],
    passingCtx(),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'global_spam_guard_48h');
});

Deno.test('G8 — outside business hours (2 AM Toronto) DEFERS', () => {
  const earlyMorning = new Date('2026-05-13T06:00:00Z'); // 02h Toronto
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    earlyMorning,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'DEFER');
  assertEquals(d.reason, 'outside_business_hours');
  assertEquals(d.retry_at !== null, true);
});

Deno.test('G9 — Quebec holiday DEFERS', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ isHoliday: true }),
  );
  assertEquals(d.action, 'DEFER');
  assertEquals(d.reason, 'quebec_holiday');
});

Deno.test('G11 — budget exceeded BLOCKS', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ monthlyCostCAD: 600 }), // > 500 max
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'budget_exceeded');
});

Deno.test('G12 — degraded sender score DEFERS 2h', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ senderScore: 90 }),
  );
  assertEquals(d.action, 'DEFER');
  assertEquals(d.reason, 'sender_score_degraded');
  const retryDate = new Date(d.retry_at!);
  const expectedRetry = new Date(NOW.getTime() + 2 * 3_600_000);
  assertEquals(
    Math.abs(retryDate.getTime() - expectedRetry.getTime()) < 60_000,
    true,
    'retry_at should be ~2h from now',
  );
});

Deno.test('G10 — missing template BLOCKS', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ templateExists: false }),
  );
  assertEquals(d.action, 'BLOCK');
  assertEquals(d.reason, 'no_template_available');
});

// =============================================================================
// 5 NOMINAL SEND CASES
// =============================================================================

Deno.test('SEND #1 — clean prospect inactif_j2 in golden hour', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
  assertEquals(d.reason, 'all_guards_passed');
});

Deno.test('SEND #2 — opt-out > 90 days, reactivation_longterme allowed', () => {
  const oldOptOut = new Date(NOW.getTime() - 100 * 86_400_000).toISOString();
  const d = evaluateGuards(
    baseProspect({ opted_out_at: oldOptOut, status: 'perdu' }),
    'reactivation_longterme',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
});

Deno.test('SEND #3 — second inactif_j5 after cadence 30j elapsed', () => {
  const oldSend = new Date(NOW.getTime() - 45 * 86_400_000).toISOString(); // 45j
  // history shows ONE prior j5 — max_attempts for inactif_j5 = 1, so this still blocks G7.
  // Use a fresh type without prior attempts.
  const d = evaluateGuards(
    baseProspect(),
    'nudge_courtier_chaud', // max=3
    NOW,
    [{ type: 'nudge_courtier_chaud', sent_at: oldSend, status: 'sent' }],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
});

Deno.test('SEND #4 — last_inbound > 24h ago', () => {
  const yesterday = new Date(NOW.getTime() - 26 * 3_600_000).toISOString();
  const d = evaluateGuards(
    baseProspect({ last_inbound_at: yesterday }),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
});

Deno.test('SEND #5 — different type, no cadence/attempt conflict', () => {
  const oldInactif = new Date(NOW.getTime() - 60 * 86_400_000).toISOString();
  const d = evaluateGuards(
    baseProspect(),
    'rdv_rappel_j1',
    NOW,
    [{ type: 'inactif_j2', sent_at: oldInactif, status: 'sent' }],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
});

// =============================================================================
// Bonus — guard ORDER assertion
// =============================================================================

Deno.test('Guards evaluated in correct order — blacklist beats opted_out', () => {
  // Both G1 and G2 conditions met; G1 should win.
  const d = evaluateGuards(
    baseProspect({ opted_out_at: '2026-05-10T14:00:00Z' }),
    'inactif_j2',
    NOW,
    [],
    passingCtx({ blacklisted: true }),
  );
  assertEquals(d.reason, 'blacklist_phone');
  assertEquals(d.guards_evaluated.length, 1, 'Should stop at G1');
});

Deno.test('Guards evaluated in correct order — all 13 evaluated on SEND', () => {
  const d = evaluateGuards(
    baseProspect(),
    'inactif_j2',
    NOW,
    [],
    passingCtx(),
  );
  assertEquals(d.action, 'SEND');
  assertEquals(d.guards_evaluated.length, 13, 'All 13 guards run on SEND');
});
