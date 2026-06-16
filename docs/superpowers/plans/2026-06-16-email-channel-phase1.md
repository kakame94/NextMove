# Email Channel — Phase 1 (Intake Centris/email) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ingest inbound emails (Centris "Demande d'information" + free-form prospect emails) into Klaris: parse → qualify → create/update prospect → log conversation, via a new Supabase edge function.

**Architecture:** A Deno edge function `email-intake` receives the parsed MIME from an inbound-parse provider (forward-to-parse model), verifies an HMAC signature, unwraps forwarded mail, parses Centris bilingual labels (or treats as free email), qualifies with Claude (Haiku), then upserts a prospect by email and inserts an inbound `conversations` row — all via `service_role` (bypasses RLS, stamps the correct `courtier_id`). Pure logic (unwrap, parser, signature) is isolated into testable modules with dependency-injected DB/Claude/fetch.

**Tech Stack:** Deno, `jsr:@supabase/supabase-js@2`, Web Crypto (HMAC-SHA256), `jsr:@std/assert` for tests, Anthropic API (Haiku), Supabase Postgres (canon schema).

**Scope:** Phase 1 = inbound only (scope A). NO outbound send, NO opt-out enforcement, NO relances, NO IMAP — those are scopes B/C/D, separate plans. Reference: [docs/email-channel-dev-guide.md](../../email-channel-dev-guide.md).

---

## Preconditions (resolve before Task 2 — these gate exact code)

- [ ] **P1 — Confirm the live prod schema.** The repo has a known discrepancy (voicemail-intake writes columns absent from canon — see dev guide §3.2). Run against the prod/staging DB and record the real column list:

  Run: `psql "$SUPABASE_DB_URL" -c "\d public.prospects" -c "\d public.conversations"`
  Expected: confirm `prospects` has `type_projet, statut, score_chaleur, canal_source, langue_preferee, nom, prenom, telephone, email` and `conversations` has `prospect_id, direction, sender, content, sent_at`. **If the live schema differs from canon, stop and reconcile — every task below uses canon column names.**

- [ ] **P2 — Obtain 2 golden Centris `.eml` samples** (1 FR + 1 EN; one listing-attached with `No. Centris`, one generic). Save to `klaris_ios/supabase/functions/email-intake/fixtures/`. These validate the parser in Task 3. If unavailable at start, build the parser against the documented label set (dev guide §6.1) and add a validation step when samples arrive.

- [ ] **P3 — Decision confirmed:** `prospects.type_projet` becomes nullable (dev guide §3.3 option 1). This plan's migration (Task 1) implements that.

---

## File Structure

- `010_email_channel.sql` (repo root) — additive migration (Task 1).
- `klaris_ios/supabase/functions/email-intake/deno.json` — Deno config + tasks (Task 0).
- `klaris_ios/supabase/functions/email-intake/lib/unwrap.ts` — HTML→text + forward unwrap (Task 2).
- `klaris_ios/supabase/functions/email-intake/lib/unwrap.test.ts` — tests (Task 2).
- `klaris_ios/supabase/functions/email-intake/lib/centris.ts` — bilingual label parser (Task 3).
- `klaris_ios/supabase/functions/email-intake/lib/centris.test.ts` — tests (Task 3).
- `klaris_ios/supabase/functions/email-intake/lib/signature.ts` — HMAC-SHA256 verify (Task 4).
- `klaris_ios/supabase/functions/email-intake/lib/signature.test.ts` — tests (Task 4).
- `klaris_ios/supabase/functions/email-intake/lib/qualify.ts` — Claude qualification, injectable fetch (Task 5).
- `klaris_ios/supabase/functions/email-intake/lib/qualify.test.ts` — tests (Task 5).
- `klaris_ios/supabase/functions/email-intake/lib/persist.ts` — DB helpers, injectable client (Task 6).
- `klaris_ios/supabase/functions/email-intake/lib/persist.test.ts` — tests with a fake client (Task 6).
- `klaris_ios/supabase/functions/email-intake/index.ts` — `Deno.serve` handler composing the lib (Task 7).

Each `lib/*.ts` has one responsibility and is pure or dependency-injected so it unit-tests without network/DB. `index.ts` is thin wiring.

---

## Task 0: Test harness + function skeleton

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/deno.json`

- [ ] **Step 1: Create the Deno config**

```json
{
  "tasks": {
    "test": "deno test --allow-env --allow-net"
  },
  "imports": {
    "@std/assert": "jsr:@std/assert@1",
    "@supabase/supabase-js": "jsr:@supabase/supabase-js@2"
  }
}
```

- [ ] **Step 2: Verify Deno runs and finds no tests yet**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test`
Expected: `No test modules found` (exit 0 or "no tests" message) — confirms config parses.

- [ ] **Step 3: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/deno.json
git commit -m "chore(email-intake): deno test harness"
```

---

## Task 1: Migration `010_email_channel.sql`

**Files:**
- Create: `010_email_channel.sql`

- [ ] **Step 1: Write the migration**

```sql
-- 010_email_channel.sql — Phase 1 email intake. Additive, idempotent. Apply after 008/009.
begin;

-- conversations: canal + métadonnées email + idempotence + threading
alter table public.conversations
  add column if not exists channel text not null default 'sms'
    check (channel in ('sms','email','web')),
  add column if not exists metadata jsonb,
  add column if not exists external_message_id text,
  add column if not exists in_reply_to uuid references public.conversations(id) on delete set null;

create unique index if not exists ux_conversations_ext_msg
  on public.conversations (prospect_id, channel, external_message_id)
  where external_message_id is not null;

create index if not exists idx_conversations_in_reply_to
  on public.conversations (in_reply_to) where in_reply_to is not null;

-- prospects: origine, MLS Centris, unicité email, type_projet nullable (cf dev guide §3.3)
alter table public.prospects
  add column if not exists source text
    check (source in ('sms','email','centris','web','manual')),
  add column if not exists centris_mls text;

create unique index if not exists ux_prospects_courtier_email
  on public.prospects (courtier_id, email) where email is not null;

alter table public.prospects alter column type_projet drop not null;

commit;
```

- [ ] **Step 2: Apply to local/staging and verify it is idempotent**

Run:
```bash
psql "$SUPABASE_DB_URL" -f 010_email_channel.sql
psql "$SUPABASE_DB_URL" -f 010_email_channel.sql   # second run must also succeed
psql "$SUPABASE_DB_URL" -c "select column_name from information_schema.columns where table_name='conversations' and column_name in ('channel','metadata','external_message_id','in_reply_to');"
```
Expected: both applies succeed (no error on rerun); the SELECT returns 4 rows.

- [ ] **Step 3: Verify type_projet is now nullable**

Run: `psql "$SUPABASE_DB_URL" -c "select is_nullable from information_schema.columns where table_name='prospects' and column_name='type_projet';"`
Expected: `YES`

- [ ] **Step 4: Commit**

```bash
git add 010_email_channel.sql
git commit -m "feat(db): 010 email channel — conversations.channel/metadata, prospects.source/centris_mls, type_projet nullable"
```

---

## Task 2: Forward unwrap + HTML→text (`lib/unwrap.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/lib/unwrap.ts`
- Test: `klaris_ios/supabase/functions/email-intake/lib/unwrap.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
import { assertEquals, assertStringIncludes } from "@std/assert";
import { htmlToText, stripQuoteMarkers, unwrapForward } from "./unwrap.ts";

Deno.test("htmlToText strips tags and decodes entities", () => {
  assertEquals(htmlToText("<p>Bonjour&nbsp;<b>Jean</b></p>"), "Bonjour Jean");
});

Deno.test("stripQuoteMarkers removes leading > on each line", () => {
  assertEquals(stripQuoteMarkers("> a\n>> b\nc"), "a\nb\nc");
});

Deno.test("unwrapForward returns innermost body for a forwarded message", () => {
  const fwd = [
    "FYI",
    "---------- Forwarded message ---------",
    "From: Centris <no-reply@centris.ca>",
    "Subject: Demande d'information",
    "",
    "> Prénom: Marie",
    "> Courriel: marie@example.com",
  ].join("\n");
  const inner = unwrapForward({ text: fwd, html: null, subject: "Tr: Demande", from: "broker@x.com" });
  assertStringIncludes(inner, "Prénom: Marie");
  assertStringIncludes(inner, "Courriel: marie@example.com");
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/unwrap.test.ts`
Expected: FAIL — `Module not found ./unwrap.ts`.

- [ ] **Step 3: Write the implementation**

```ts
// lib/unwrap.ts — pure helpers: HTML→text, quote stripping, forward unwrap.

export function htmlToText(html: string): string {
  return html
    .replace(/<\s*br\s*\/?>/gi, "\n")
    .replace(/<\/(p|div|tr|li|h[1-6])>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&#39;|&apos;/gi, "'")
    .replace(/&quot;/gi, '"')
    .replace(/[ \t]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

export function stripQuoteMarkers(text: string): string {
  return text
    .split("\n")
    .map((l) => l.replace(/^\s*>+\s?/, ""))
    .join("\n");
}

export interface RawEmail {
  text: string | null;
  html: string | null;
  subject: string;
  from: string;
}

// Returns the innermost human body, HTML-decoded and de-quoted.
export function unwrapForward(email: RawEmail): string {
  let body = email.text ?? (email.html ? htmlToText(email.html) : "");
  body = stripQuoteMarkers(body);
  // drop everything up to and including a "Forwarded message" / "Message transféré" marker
  const marker = /(-+\s*(forwarded message|message transféré)\s*-+)/i;
  const m = body.match(marker);
  if (m && m.index !== undefined) body = body.slice(m.index + m[0].length);
  return body.trim();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/unwrap.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/lib/unwrap.ts klaris_ios/supabase/functions/email-intake/lib/unwrap.test.ts
git commit -m "feat(email-intake): forward unwrap + html→text helpers"
```

---

## Task 3: Centris bilingual parser (`lib/centris.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/lib/centris.ts`
- Test: `klaris_ios/supabase/functions/email-intake/lib/centris.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
import { assertEquals } from "@std/assert";
import { parseLead } from "./centris.ts";

Deno.test("parses a French listing-attached Centris RFI", () => {
  const body = [
    "Prénom: Marie",
    "Nom: Tremblay",
    "Courriel: marie.tremblay@example.com",
    "Téléphone: 514-555-0142",
    "No. Centris: 12345678",
    "Message: Bonjour, je veux visiter cette propriété.",
  ].join("\n");
  const lead = parseLead(body);
  assertEquals(lead.prenom, "Marie");
  assertEquals(lead.nom, "Tremblay");
  assertEquals(lead.courriel, "marie.tremblay@example.com");
  assertEquals(lead.telephone, "514-555-0142");
  assertEquals(lead.centrisMls, "12345678");
  assertEquals(lead.message, "Bonjour, je veux visiter cette propriété.");
  assertEquals(lead.isCentris, true);
});

Deno.test("parses an English generic broker RFI (no MLS)", () => {
  const body = [
    "First name: John",
    "Last name: Smith",
    "Email: john@example.com",
    "Phone: 438-555-0199",
    "Message: I'd like more information about your services.",
  ].join("\n");
  const lead = parseLead(body);
  assertEquals(lead.prenom, "John");
  assertEquals(lead.courriel, "john@example.com");
  assertEquals(lead.centrisMls, null);
  assertEquals(lead.isCentris, true);
});

Deno.test("free-form email with no labels is not Centris", () => {
  const lead = parseLead("Hi, is the condo on Rue Saint-Denis still available?");
  assertEquals(lead.isCentris, false);
  assertEquals(lead.message, "Hi, is the condo on Rue Saint-Denis still available?");
  assertEquals(lead.courriel, null);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/centris.test.ts`
Expected: FAIL — `Module not found ./centris.ts`.

- [ ] **Step 3: Write the implementation**

```ts
// lib/centris.ts — bilingual label parser for Centris RFI emails (dev guide §6).
// Anchors on body labels (FR/EN), never on From/subject (mail is often forwarded).

export interface Lead {
  prenom: string | null;
  nom: string | null;
  courriel: string | null;
  telephone: string | null;
  centrisMls: string | null;
  message: string;
  isCentris: boolean;
}

// each field: list of accepted labels (case/accent-insensitive), FR + EN
const LABELS: Record<string, string[]> = {
  prenom: ["prénom", "prenom", "first name"],
  nom: ["nom", "last name"],
  courriel: ["courriel", "email", "courrier électronique"],
  telephone: ["téléphone", "telephone", "phone", "tél"],
  centrisMls: ["no. centris", "no centris", "n° centris", "mls", "no. mls"],
  message: ["message"],
};

function norm(s: string): string {
  return s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
}

function findLabel(line: string): { key: string; value: string } | null {
  const idx = line.indexOf(":");
  if (idx === -1) return null;
  const label = norm(line.slice(0, idx).trim());
  const value = line.slice(idx + 1).trim();
  for (const [key, variants] of Object.entries(LABELS)) {
    if (variants.some((v) => label === norm(v))) return { key, value };
  }
  return null;
}

export function parseLead(body: string): Lead {
  const out: Lead = {
    prenom: null, nom: null, courriel: null, telephone: null,
    centrisMls: null, message: "", isCentris: false,
  };
  const lines = body.split("\n");
  const messageParts: string[] = [];
  let labelHits = 0;
  for (const line of lines) {
    const hit = findLabel(line);
    if (hit) {
      labelHits++;
      if (hit.key === "message") messageParts.push(hit.value);
      else (out as Record<string, unknown>)[hit.key] = hit.value || null;
    }
  }
  // Centris if we matched at least 2 distinct field labels (robust to forwarding noise)
  out.isCentris = labelHits >= 2 && (out.courriel !== null || out.prenom !== null);
  out.message = out.isCentris ? messageParts.join("\n").trim() : body.trim();
  return out;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/centris.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: (When P2 samples available) Add a fixture-validation test**

```ts
Deno.test("parses the golden FR Centris sample", async () => {
  const raw = await Deno.readTextFile(new URL("../fixtures/centris_fr.eml", import.meta.url));
  const lead = parseLead(raw); // pipe through unwrapForward in real flow; raw body here
  assertEquals(lead.isCentris, true);
  assertEquals(lead.courriel !== null, true);
});
```

Run: `deno task test lib/centris.test.ts` — Expected: PASS once `fixtures/centris_fr.eml` exists. If a real label differs from the `LABELS` table, add the variant and rerun.

- [ ] **Step 6: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/lib/centris.ts klaris_ios/supabase/functions/email-intake/lib/centris.test.ts
git commit -m "feat(email-intake): bilingual Centris RFI label parser"
```

---

## Task 4: HMAC signature verification (`lib/signature.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/lib/signature.ts`
- Test: `klaris_ios/supabase/functions/email-intake/lib/signature.test.ts`

> Provider-neutral HMAC-SHA256 over the raw body, compared to a header (name configurable per provider). This is the mandatory gate the SMS webhook lacks (dev guide §9). For a provider using a different scheme (e.g. Postmark Basic-Auth URL), swap this module — the interface stays.

- [ ] **Step 1: Write the failing test**

```ts
import { assert, assertEquals } from "@std/assert";
import { signBody, verifySignature } from "./signature.ts";

const SECRET = "test-secret";

Deno.test("verifySignature accepts a correctly signed body", async () => {
  const body = '{"from":"a@b.com"}';
  const sig = await signBody(body, SECRET);
  assert(await verifySignature(body, sig, SECRET));
});

Deno.test("verifySignature rejects a tampered body", async () => {
  const sig = await signBody('{"from":"a@b.com"}', SECRET);
  assertEquals(await verifySignature('{"from":"evil@b.com"}', sig, SECRET), false);
});

Deno.test("verifySignature rejects wrong secret", async () => {
  const body = "x";
  const sig = await signBody(body, SECRET);
  assertEquals(await verifySignature(body, sig, "other"), false);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/signature.test.ts`
Expected: FAIL — `Module not found ./signature.ts`.

- [ ] **Step 3: Write the implementation**

```ts
// lib/signature.ts — HMAC-SHA256(raw body) hex, constant-time compare. Web Crypto only.

async function hmac(body: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export const signBody = hmac;

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

export async function verifySignature(body: string, provided: string, secret: string): Promise<boolean> {
  if (!provided || !secret) return false;
  const expected = await hmac(body, secret);
  return timingSafeEqual(expected, provided.trim().toLowerCase());
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/signature.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/lib/signature.ts klaris_ios/supabase/functions/email-intake/lib/signature.test.ts
git commit -m "feat(email-intake): HMAC-SHA256 webhook signature verification"
```

---

## Task 5: Claude qualification (`lib/qualify.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/lib/qualify.ts`
- Test: `klaris_ios/supabase/functions/email-intake/lib/qualify.test.ts`

> Injectable `fetch` so the test runs offline. Output uses **canon** field names (`type_projet`, `score_chaleur`, `langue_preferee`) — NOT voicemail's column names (dev guide §3.2).

- [ ] **Step 1: Write the failing test**

```ts
import { assertEquals } from "@std/assert";
import { qualify } from "./qualify.ts";

function fakeFetch(jsonText: string): typeof fetch {
  return ((_url: string | URL | Request, _init?: RequestInit) =>
    Promise.resolve(new Response(JSON.stringify({
      content: [{ type: "text", text: jsonText }],
    }), { status: 200 }))) as typeof fetch;
}

Deno.test("qualify maps Claude JSON to canon fields", async () => {
  const f = fakeFetch('{"type_projet":"acheteur","langue":"fr","score_chaleur":7}');
  const q = await qualify("Je veux acheter un condo", { apiKey: "k", fetchImpl: f });
  assertEquals(q.type_projet, "acheteur");
  assertEquals(q.langue, "fr");
  assertEquals(q.score_chaleur, 7);
});

Deno.test("qualify degrades gracefully on unparseable response", async () => {
  const q = await qualify("hi", { apiKey: "k", fetchImpl: fakeFetch("not json") });
  assertEquals(q.type_projet, null);
  assertEquals(q.score_chaleur, 0);
  assertEquals(q.langue, "fr");
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/qualify.test.ts`
Expected: FAIL — `Module not found ./qualify.ts`.

- [ ] **Step 3: Write the implementation**

```ts
// lib/qualify.ts — classify an inbound email with Claude Haiku. Injectable fetch for tests.

export interface Qualif {
  type_projet: "acheteur" | "vendeur" | null;
  langue: "fr" | "en";
  score_chaleur: number; // 0..10
}

interface Opts { apiKey: string; fetchImpl?: typeof fetch; model?: string }

const PROMPT = `Tu qualifies un courriel entrant pour un courtier immobilier québécois.
Réponds UNIQUEMENT en JSON: {"type_projet":"acheteur"|"vendeur"|null,"langue":"fr"|"en","score_chaleur":0-10}.
score_chaleur: 0 froid, 10 prêt à transiger.`;

export async function qualify(message: string, opts: Opts): Promise<Qualif> {
  const fetchImpl = opts.fetchImpl ?? fetch;
  const fallback: Qualif = { type_projet: null, langue: "fr", score_chaleur: 0 };
  try {
    const res = await fetchImpl("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": opts.apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: opts.model ?? "claude-haiku-4-5-20251001",
        max_tokens: 256,
        system: PROMPT,
        messages: [{ role: "user", content: message.slice(0, 2000) }],
      }),
    });
    if (!res.ok) return fallback;
    const data = await res.json();
    const text: string = data?.content?.[0]?.text ?? "";
    const json = JSON.parse(text.slice(text.indexOf("{"), text.lastIndexOf("}") + 1));
    return {
      type_projet: json.type_projet === "acheteur" || json.type_projet === "vendeur" ? json.type_projet : null,
      langue: json.langue === "en" ? "en" : "fr",
      score_chaleur: Math.max(0, Math.min(10, Number(json.score_chaleur) || 0)),
    };
  } catch {
    return fallback;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/qualify.test.ts`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/lib/qualify.ts klaris_ios/supabase/functions/email-intake/lib/qualify.test.ts
git commit -m "feat(email-intake): Claude Haiku qualification (canon fields, injectable fetch)"
```

---

## Task 6: DB persistence helpers (`lib/persist.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/lib/persist.ts`
- Test: `klaris_ios/supabase/functions/email-intake/lib/persist.test.ts`

> Accepts a minimal injected client interface so tests use a fake (no live DB). Uses **canon** column names. `alreadyIngested` provides idempotency on `external_message_id`.

- [ ] **Step 1: Write the failing test**

```ts
import { assert, assertEquals } from "@std/assert";
import { alreadyIngested, findOrCreateByEmail, type DbLike } from "./persist.ts";

function fakeDb(existingMsgIds: string[], existingProspect: { id: string } | null): DbLike {
  return {
    selectConversationByMsgId: (id) => Promise.resolve(existingMsgIds.includes(id) ? { id: "c1" } : null),
    selectProspectByEmail: (_email, _courtier) => Promise.resolve(existingProspect),
    insertProspect: (row) => Promise.resolve({ id: "p-new", ...row }),
  } as unknown as DbLike;
}

Deno.test("alreadyIngested true when message id seen", async () => {
  assertEquals(await alreadyIngested(fakeDb(["m1"], null), "m1", "email"), true);
  assertEquals(await alreadyIngested(fakeDb(["m1"], null), "m2", "email"), false);
});

Deno.test("findOrCreateByEmail returns existing prospect", async () => {
  const p = await findOrCreateByEmail(fakeDb([], { id: "p-old" }), {
    courtier_id: "co", email: "a@b.com", prenom: "A", nom: "B",
    telephone: null, source: "centris", centris_mls: "1", type_projet: null,
    score_chaleur: 5, langue_preferee: "fr",
  });
  assertEquals(p.id, "p-old");
});

Deno.test("findOrCreateByEmail inserts when absent", async () => {
  const p = await findOrCreateByEmail(fakeDb([], null), {
    courtier_id: "co", email: "new@b.com", prenom: "N", nom: "B",
    telephone: null, source: "email", centris_mls: null, type_projet: null,
    score_chaleur: 0, langue_preferee: "fr",
  });
  assertEquals(p.id, "p-new");
  assert((p as Record<string, unknown>).email === "new@b.com");
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/persist.test.ts`
Expected: FAIL — `Module not found ./persist.ts`.

- [ ] **Step 3: Write the implementation**

```ts
// lib/persist.ts — DB helpers over a small injected interface (real impl wraps supabase-js).

export interface ProspectInsert {
  courtier_id: string;
  email: string;
  prenom: string | null;
  nom: string | null;
  telephone: string | null;
  source: "sms" | "email" | "centris" | "web" | "manual";
  centris_mls: string | null;
  type_projet: "acheteur" | "vendeur" | null;
  score_chaleur: number;
  langue_preferee: "fr" | "en";
}

export interface DbLike {
  selectConversationByMsgId(externalMessageId: string, channel: string): Promise<{ id: string } | null>;
  selectProspectByEmail(email: string, courtierId: string): Promise<{ id: string } | null>;
  insertProspect(row: ProspectInsert & { canal_source: string; statut: string }): Promise<{ id: string }>;
}

export async function alreadyIngested(db: DbLike, externalMessageId: string, channel: string): Promise<boolean> {
  if (!externalMessageId) return false;
  return (await db.selectConversationByMsgId(externalMessageId, channel)) !== null;
}

export async function findOrCreateByEmail(db: DbLike, p: ProspectInsert): Promise<{ id: string }> {
  const existing = await db.selectProspectByEmail(p.email, p.courtier_id);
  if (existing) return existing;
  return await db.insertProspect({ ...p, canal_source: "email", statut: "nouveau" });
}

// Real adapter built from a supabase-js client (used by index.ts, not unit-tested here).
// deno-lint-ignore no-explicit-any
export function supabaseDb(supabase: any): DbLike {
  return {
    async selectConversationByMsgId(id, channel) {
      const { data } = await supabase.from("conversations").select("id")
        .eq("external_message_id", id).eq("channel", channel).maybeSingle();
      return data ?? null;
    },
    async selectProspectByEmail(email, courtierId) {
      const { data } = await supabase.from("prospects").select("id")
        .eq("email", email).eq("courtier_id", courtierId).is("deleted_at", null).maybeSingle();
      return data ?? null;
    },
    async insertProspect(row) {
      const { data, error } = await supabase.from("prospects").insert(row).select("id").single();
      if (error) throw error;
      return data;
    },
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test lib/persist.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/lib/persist.ts klaris_ios/supabase/functions/email-intake/lib/persist.test.ts
git commit -m "feat(email-intake): DB helpers (idempotency + find/create by email, canon columns)"
```

---

## Task 7: Compose the handler (`index.ts`)

**Files:**
- Create: `klaris_ios/supabase/functions/email-intake/index.ts`

> Thin wiring of the tested modules. No new logic worth unit-testing here; validated end-to-end in Task 8.

- [ ] **Step 1: Write the handler**

```ts
import { createClient } from "@supabase/supabase-js";
import { unwrapForward, type RawEmail } from "./lib/unwrap.ts";
import { parseLead } from "./lib/centris.ts";
import { verifySignature } from "./lib/signature.ts";
import { qualify } from "./lib/qualify.ts";
import { alreadyIngested, findOrCreateByEmail, supabaseDb } from "./lib/persist.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SIG_SECRET = Deno.env.get("EMAIL_WEBHOOK_SECRET")!;
const SIG_HEADER = Deno.env.get("EMAIL_SIG_HEADER") ?? "x-klaris-signature";
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const COURTIER_ID = Deno.env.get("DEFAULT_COURTIER_ID")!; // mono-tenant Phase 1 (dev guide §3.5)

const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { "content-type": "application/json" } });

Deno.serve(async (req: Request) => {
  const raw = await req.text();

  // 1. signature — before any DB op (dev guide §9). Bare 401, no PII.
  if (!(await verifySignature(raw, req.headers.get(SIG_HEADER) ?? "", SIG_SECRET))) {
    return json({ ok: false }, 401);
  }

  // 2. provider payload → RawEmail. Adjust field mapping to the chosen provider's shape.
  const p = JSON.parse(raw);
  const email: RawEmail & { messageId: string; date?: string } = {
    text: p.text ?? p.TextBody ?? null,
    html: p.html ?? p.HtmlBody ?? null,
    subject: p.subject ?? p.Subject ?? "",
    from: p.from ?? p.From ?? "",
    messageId: p.message_id ?? p.MessageID ?? p.messageId ?? crypto.randomUUID(),
    date: p.date ?? p.Date,
  };

  const supabase = createClient(SUPABASE_URL, SERVICE_KEY);
  const db = supabaseDb(supabase);

  // 3. idempotency
  if (await alreadyIngested(db, email.messageId, "email")) return json({ ok: true, dedup: true });

  // 4. unwrap + parse
  const body = unwrapForward(email);
  const lead = parseLead(body);
  const senderEmail = lead.courriel ?? email.from;

  // 5. qualify
  const q = await qualify(lead.message, { apiKey: ANTHROPIC_KEY });

  // 6. find/create prospect (canon columns)
  const prospect = await findOrCreateByEmail(db, {
    courtier_id: COURTIER_ID,
    email: senderEmail,
    prenom: lead.prenom, nom: lead.nom, telephone: lead.telephone,
    source: lead.centrisMls ? "centris" : "email",
    centris_mls: lead.centrisMls,
    type_projet: q.type_projet,
    score_chaleur: q.score_chaleur,
    langue_preferee: q.langue,
  });

  // 7. insert inbound conversation
  await supabase.from("conversations").insert({
    prospect_id: prospect.id,
    direction: "inbound",
    sender: "prospect",
    channel: "email",
    content: lead.message,
    external_message_id: email.messageId,
    metadata: { from: email.from, subject: email.subject, centris_mls: lead.centrisMls },
    sent_at: email.date ?? new Date().toISOString(),
  });

  // 8. audit
  await supabase.from("audit_log").insert({
    prospect_id: prospect.id,
    action: "email_qualified",
    payload: { message_id: email.messageId, is_centris: lead.isCentris, score: q.score_chaleur },
  });

  return json({ ok: true, prospect_id: prospect.id, score: q.score_chaleur });
});
```

- [ ] **Step 2: Type-check the function**

Run: `cd klaris_ios/supabase/functions/email-intake && deno check index.ts`
Expected: no type errors.

- [ ] **Step 3: Run the full module test suite**

Run: `cd klaris_ios/supabase/functions/email-intake && deno task test`
Expected: PASS — all unit tests across lib/ (unwrap 3, centris 3, signature 3, qualify 2, persist 3).

- [ ] **Step 4: Commit**

```bash
git add klaris_ios/supabase/functions/email-intake/index.ts
git commit -m "feat(email-intake): compose handler (signature→unwrap→parse→qualify→persist)"
```

---

## Task 8: Deploy + staging end-to-end verification

**Files:** none (ops).

- [ ] **Step 1: Set secrets and deploy to staging**

```bash
supabase secrets set EMAIL_WEBHOOK_SECRET=<gen> EMAIL_SIG_HEADER=x-klaris-signature DEFAULT_COURTIER_ID=<uuid>
supabase functions deploy email-intake
```
Expected: deploy succeeds; function URL printed.

- [ ] **Step 2: Send a signed synthetic Centris payload**

```bash
BODY='{"from":"broker@x.com","subject":"Tr: Demande","text":"Prénom: Marie\nNom: Tremblay\nCourriel: marie@example.com\nTéléphone: 514-555-0142\nNo. Centris: 12345678\nMessage: Test visite","message_id":"<test-1@klaris>"}'
SIG=$(deno run --allow-env - <<'EOF'
// compute hmac for the body using the same secret
EOF
)
curl -s -X POST "$FN_URL" -H "x-klaris-signature: $SIG" -H "content-type: application/json" -d "$BODY"
```
Expected: `{"ok":true,"prospect_id":"...","score":<n>}`.

- [ ] **Step 3: Verify rows landed with correct columns**

```bash
psql "$SUPABASE_DB_URL" -c "select source, centris_mls, email, type_projet from prospects where email='marie@example.com';"
psql "$SUPABASE_DB_URL" -c "select channel, direction, sender, external_message_id from conversations order by created_at desc limit 1;"
```
Expected: prospect `source='centris'`, `centris_mls='12345678'`; conversation `channel='email'`, `direction='inbound'`, `external_message_id='<test-1@klaris>'`.

- [ ] **Step 4: Verify idempotency**

Run the same curl from Step 2 again.
Expected: `{"ok":true,"dedup":true}` and no second conversation row.

- [ ] **Step 5: Verify signature rejection**

Run: `curl -s -o /dev/null -w "%{http_code}" -X POST "$FN_URL" -H "x-klaris-signature: bad" -d "$BODY"`
Expected: `401`.

- [ ] **Step 6: (When P2 available) Replay a real forwarded Centris `.eml`** through the provider's inbound parse into staging; confirm a prospect + conversation are created and fields are correct. Adjust `LABELS` / provider field mapping if needed.

---

## Self-Review (completed during authoring)

- **Spec coverage (scope A only):** migration §4 → Task 1; intake edge fn §5 → Tasks 0,2–7; Centris parser §6 → Task 3; signature gate §9 → Task 4; idempotency §9 → Tasks 6/8; canon-column correctness §3.2 → Tasks 5/6 use canon names; type_projet nullable §3.3 → Task 1. Scopes B/C/D intentionally deferred (separate plans).
- **Placeholders:** none — every code/test step contains real content. The only deferred items are P2-gated fixture steps (real `.eml` unavailable until provided) and the Step-2 HMAC helper in Task 8 (ops one-liner), both explicitly flagged, not silent TODOs.
- **Type consistency:** `Lead`, `RawEmail`, `Qualif`, `ProspectInsert`, `DbLike` are defined once and reused; `parseLead`/`unwrapForward`/`verifySignature`/`qualify`/`findOrCreateByEmail`/`alreadyIngested` signatures match across tasks and `index.ts`.

---

## Open items carried from the dev guide (do not block Phase 1, but track)

- Provider final choice + exact inbound payload field mapping (Task 7 Step 2 maps both Postmark `TitleCase` and lowercase shapes defensively).
- Multi-tenant `courtier_id` resolution (Phase 1 uses `DEFAULT_COURTIER_ID`).
- Outbound send + `email_optout` + `is_email_optout` + CASL footer → Phase 2 plan.
- `relances.channel` → coordinate with PR #26 (Phase 2/3).
