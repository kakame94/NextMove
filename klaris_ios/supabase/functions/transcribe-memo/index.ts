// Klaris — transcribe a voice memo via Whisper, summarize via Claude.
// Triggered by client right after upload to Storage `memos/`.
//
// Body: { memo_id: <uuid> }
// Auth: user JWT — RLS confines memo lookup to caller.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const OPENAI_KEY = Deno.env.get('OPENAI_API_KEY')!;
const ANTHROPIC_KEY = Deno.env.get('ANTHROPIC_API_KEY')!;

Deno.serve(async (req: Request) => {
  try {
    const auth = req.headers.get('authorization') ?? '';
    const { memo_id } = await req.json() as { memo_id?: string };
    if (!memo_id) return json({ error: 'memo_id required' }, 400);

    // Auth-scoped client validates ownership. Service client persists the result.
    const userClient = createClient(SUPABASE_URL, ANON_KEY, { global: { headers: { Authorization: auth } } });
    const svc = createClient(SUPABASE_URL, SERVICE_KEY);

    const { data: memo, error: memoErr } = await userClient.from('voice_memos').select('id, audio_path, courtier_id').eq('id', memo_id).single();
    if (memoErr || !memo) return json({ error: 'not_found' }, 404);

    const { data: signed } = await svc.storage.from('memos').createSignedUrl(memo.audio_path as string, 60);
    const url = signed?.signedUrl;
    if (!url) throw new Error('signed_url_failed');

    const audio = await fetch(url).then((r) => r.blob());

    // 1. Whisper.
    const fd = new FormData();
    fd.append('file', audio, 'memo.m4a');
    fd.append('model', 'whisper-1');
    fd.append('language', 'fr');
    const whisperRes = await fetch('https://api.openai.com/v1/audio/transcriptions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${OPENAI_KEY}` },
      body: fd,
    });
    if (!whisperRes.ok) throw new Error(`whisper ${whisperRes.status}`);
    const { text: transcript } = await whisperRes.json() as { text: string };

    // 2. Summary via Claude.
    const summary = await summarize(transcript);

    // 3. Persist.
    await svc.from('voice_memos').update({ transcript, summary, status: 'ready' }).eq('id', memo_id);

    return json({ ok: true, memo_id, transcript_chars: transcript.length });
  } catch (e) {
    console.error('transcribe-memo-fail', e);
    // Best-effort failure record.
    try {
      const svc = createClient(SUPABASE_URL, SERVICE_KEY);
      const body = await req.clone().json().catch(() => ({}));
      if (body.memo_id) {
        await svc.from('voice_memos').update({ status: 'failed' }).eq('id', body.memo_id);
      }
    } catch (_) {}
    return json({ error: String(e) }, 500);
  }
});

async function summarize(transcript: string): Promise<string> {
  const sys = `Tu es l'adjointe d'un courtier immobilier. Resume en UNE phrase la note vocale du courtier, ton naturel quebecois. Pas de prefixe, juste la phrase.`;
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': ANTHROPIC_KEY,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 200,
      system: sys,
      messages: [{ role: 'user', content: transcript }],
    }),
  });
  const j = await res.json();
  return ((j.content?.[0]?.text as string) ?? '').trim();
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });
}
