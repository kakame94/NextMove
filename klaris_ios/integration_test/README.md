# Klaris — Integration tests

Tests run on a real iOS simulator against a Supabase test instance.

## Setup

1. Create a `.env.test` and fill with a sandbox Supabase project + seed user:
   ```
   SUPABASE_URL=https://<test>.supabase.co
   SUPABASE_ANON_KEY=<anon>
   TEST_EMAIL=test+integration@klarisapp.ai
   TEST_PASSWORD=ChooseStrong!
   ```
2. Apply migrations 001-005 against the test project + seed minimum data:
   ```sql
   insert into auth.users (...) ...; -- via Supabase auth admin API
   insert into prospects (id, courtier_id, nom, score, status, pre_approuve, created_at)
   values ('test-1', '<user-id>', 'Test M.', 7, 'qualifie', true, now());
   ```

## Run

```bash
flutter test integration_test/login_flow_test.dart
flutter test integration_test/  # all
```

In CI, prefer running on a single emulator:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d "iPhone 16 Pro"
```
