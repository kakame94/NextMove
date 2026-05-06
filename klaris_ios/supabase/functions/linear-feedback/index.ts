// Klaris — In-app feedback → Linear issue.
// Body: { kind: 'bug'|'feature'|'praise', title, body, app_version, device_model }
// Auth: user JWT — caller email + courtier_id are tagged onto the issue.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const LINEAR_API_KEY = Deno.env.get('LINEAR_API_KEY')!;
const LINEAR_TEAM_ID = Deno.env.get('LINEAR_TEAM_ID')!;

interface FeedbackBody {
  kind: 'bug' | 'feature' | 'praise';
  title: string;
  body: string;
  app_version?: string;
  device_model?: string;
}

Deno.serve(async (req: Request) => {
  try {
    const auth = req.headers.get('authorization') ?? '';
    const supabase = createClient(SUPABASE_URL, ANON_KEY, { global: { headers: { Authorization: auth } } });
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return json({ error: 'unauthorized' }, 401);

    const f = await req.json() as FeedbackBody;
    if (!f.title || !f.body) return json({ error: 'title + body required' }, 400);

    const labels: string[] = [`klaris-ios`, `feedback-${f.kind}`];
    const description = [
      f.body,
      '',
      '---',
      `**Reporter:** ${user.email ?? user.id}`,
      `**App version:** ${f.app_version ?? '—'}`,
      `**Device:** ${f.device_model ?? '—'}`,
      `**Submitted:** ${new Date().toISOString()}`,
    ].join('\n');

    const mutation = `
      mutation IssueCreate($input: IssueCreateInput!) {
        issueCreate(input: $input) {
          success
          issue { id identifier url }
        }
      }
    `;

    const res = await fetch('https://api.linear.app/graphql', {
      method: 'POST',
      headers: {
        'Authorization': LINEAR_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: mutation,
        variables: {
          input: {
            teamId: LINEAR_TEAM_ID,
            title: `[${f.kind.toUpperCase()}] ${f.title}`.slice(0, 240),
            description,
            labelIds: [], // resolved separately if you want auto-labelling
          },
        },
      }),
    });

    const out = await res.json();
    if (out.errors || !out.data?.issueCreate?.success) {
      console.error('linear-create-fail', out);
      return json({ error: 'linear create failed', detail: out }, 502);
    }

    return json({ ok: true, issue: out.data.issueCreate.issue, labels });
  } catch (e) {
    console.error('linear-feedback-fail', e);
    return json({ error: String(e) }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });
}
