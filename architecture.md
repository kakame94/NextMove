# Next Move — Architecture

## System Flow

```
Prospect SMS
    ↓
Twilio (inbound webhook)
    ↓
n8n TwilioTrigger → Wait node → AI Agent
    ↓                              ↕
    ↓                    Anthropic Chat Model (Claude Sonnet)
    ↓                    Postgres Chat Memory (Supabase)
    ↓
IF "QUALIFIED" in response?
    ├── YES → Query chat history → Summarize → SMS notification to broker
    └── NO  → Send AI response via Twilio SMS → Wait for next message
```

## Key Decisions

1. **SMS as primary channel** — Brokers and prospects in Quebec communicate via SMS. No app install needed.
2. **n8n AI Agent node** — Uses native AI Agent with Postgres Chat Memory for conversation persistence. Each phone number gets its own session.
3. **Supabase (ca-central-1)** — PostgreSQL with RLS, hosted in Canada for Loi 25 / PIPEDA compliance.
4. **Connection Pooler** — n8n connects via `aws-1-ca-central-1.pooler.supabase.com:5432` (IPv4) since direct connection is IPv6-only.
5. **Claude Sonnet** — Used for both qualification conversations and transcript summarization.
6. **No accents in SMS** — System prompt instructs Claude to avoid accented characters to prevent SMS encoding issues.
7. **QUALIFIED keyword** — Agent adds "QUALIFIED" to final message to trigger the summary/notification flow.

## Credentials Required

| Service | Credential Type | n8n Type |
|---------|----------------|----------|
| Twilio | Account SID + Auth Token | `twilioApi` |
| Anthropic | API Key | `anthropicApi` |
| Supabase Postgres | Host + User + Password | `postgres` |

## Cost Estimate (Monthly)

| Service | Cost |
|---------|------|
| Supabase (free tier) | $0 |
| Twilio SMS (~500 msgs) | ~$15 |
| Anthropic API (~1000 calls) | ~$15 |
| n8n (self-hosted) | $0 (server cost only) |
| **Total** | **~$30-50** |
