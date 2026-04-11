# Next Move — Copilote IA du Courtier Immobilier

> AI-powered administrative assistant for independent real estate brokers in Greater Montreal.

## Vision

Next Move replaces the need for a human administrative assistant by automating client intake, qualification, follow-ups, and 24/7 communication — freeing brokers to focus on showings, negotiations, and closings.

**Key insight:** _"The difference between me and brokers doing $40M/year is just the size of the admin team."_ — Joanel, independent broker

## Architecture

```
Prospect SMS → Twilio → n8n (AI Agent) → Claude API → Supabase → Dashboard
                                ↕
                    Postgres Chat Memory
```

### Stack
- **Orchestration:** n8n (self-hosted)
- **Database:** Supabase (PostgreSQL)
- **AI Model:** Claude Sonnet (Anthropic API)
- **SMS Channel:** Twilio
- **Frontend:** React (planned)

### Estimated cost: ~$35-50/month

## MVP Features (Sprint 1)

- [x] AI conversational agent via SMS (French Canadian)
- [x] Progressive lead qualification (buyer/seller)
- [x] Conversation memory per phone number (Postgres Chat Memory)
- [x] Auto-detection of qualification completion (QUALIFIED keyword)
- [x] SMS notification to broker when lead is qualified
- [x] Conversation transcript & summary generation
- [ ] Dashboard to visualize client files
- [ ] Follow-up reminders (J+2, J+5, J+10)
- [ ] Daily briefing email at 7:30 AM

## Project Structure

```
next-move-mvp/
├── n8n/
│   └── workflows/
│       └── next_move_intake_agent.json    # Main intake workflow (credentials stripped)
├── supabase/
│   └── migrations/
│       ├── 001_create_next_move_schema.sql # 6 tables: courtiers, prospects, besoins_*, conversations, relances
│       └── 002_add_rls_policies.sql        # RLS policies + helper functions
├── docs/
│   ├── architecture.md                     # System architecture & decisions
│   └── schema.md                           # Database schema documentation
├── .env.example                            # Template for environment variables
├── .gitignore
└── README.md
```

## Setup

### 1. Supabase
1. Create a new Supabase project in `ca-central-1`
2. Run the SQL migrations in order:
   ```bash
   # Apply via Supabase Dashboard → SQL Editor
   # Or via CLI: supabase db push
   ```
3. Copy your project URL, anon key, and service role key

### 2. Twilio
1. Create a Twilio account and purchase a phone number with SMS
2. Configure the webhook to point to your n8n TwilioTrigger endpoint

### 3. n8n
1. Import `n8n/workflows/next_move_intake_agent.json`
2. Configure credentials:
   - **Twilio API** (Account SID + Auth Token)
   - **Anthropic API** (API Key)
   - **Postgres** (Supabase connection pooler)
3. Update the `from` phone number in Twilio nodes
4. Activate the workflow

### 4. Environment
1. Copy `.env.example` to `.env`
2. Fill in all values

## Database Schema

### Tables (6)
| Table | Description |
|-------|-------------|
| `courtiers` | Broker profiles |
| `prospects` | Lead records with scoring |
| `besoins_acheteur` | Buyer requirements (28 columns) |
| `besoins_vendeur` | Seller requirements (23 columns) |
| `conversations` | Message history per prospect |
| `relances` | Follow-up schedule tracking |

### Lead Scoring Grid
| Criteria | Points |
|----------|--------|
| Pre-approved financing | +3 |
| Timeline < 3 months | +2 |
| Budget defined | +2 |
| Location specified | +1 |
| First-time buyer | +1 |
| Down payment available | +1 |

Score 7-10 = Hot | 4-6 = Warm | 0-3 = Cold

## Team

- **Dennis** — Co-founder, technical lead (n8n, Claude API, Supabase)
- **Eliot** — Co-founder
- **Walkens** — Co-founder
- **Seydou** — Co-founder

## Beta Testers
- Maxime Belma (RE/MAX, Anjou)
- Joanel (independent broker)

## License

Private — All rights reserved.

## Conventions

- Code/comments: English
- AI agent (client-facing): French Canadian
- n8n workflows: `snake_case`
- Sensitive values: n8n Credentials, never hardcoded
