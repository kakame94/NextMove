#!/usr/bin/env bash
# Validation jetable de 010_relances_system.sql (cf. revue PR #26).
# Rejoue les DEUX chemins de convergence dans un Postgres Docker :
#   A. chemin prod (forme legacy)  : 001 -> 002 -> seed -> 010 -> 010
#   B. chemin 008 (forme iOS)      : 001 -> 002 -> seed -> 008* -> rows iOS -> 010 -> 010
# (*) 008 est patche a la volee : son UPDATE de dedup est ambigu
#     ("column reference telephone is ambiguous") et ne tourne pas tel quel —
#     raison pour laquelle la prod est restee en forme legacy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HERE="$(cd "$(dirname "$0")" && pwd)"
C=nm-test-relances

cleanup() { docker rm -f "$C" >/dev/null 2>&1 || true; }
trap cleanup EXIT
cleanup

docker run -d --name "$C" -e POSTGRES_PASSWORD=test postgres:15 >/dev/null
until docker exec "$C" pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done

psql_db() { docker exec -i "$C" psql -U postgres -d "$1" -v ON_ERROR_STOP=1 -q; }

run_chain() { # $1 = db, fichiers ensuite
  local db="$1"; shift
  docker exec "$C" psql -U postgres -qc "CREATE DATABASE $db"
  for f in "$@"; do
    echo "  -> $(basename "$f")"
    psql_db "$db" < "$f" >/dev/null
  done
}

echo "== TEST A : chemin legacy (prod) =="
run_chain test_legacy \
  "$HERE/00_stub_supabase.sql" \
  "$ROOT/001_create_next_move_schema.sql" \
  "$ROOT/002_add_rls_policies.sql" \
  "$HERE/01_seed_legacy.sql" \
  "$ROOT/010_relances_system.sql" \
  "$ROOT/010_relances_system.sql"
psql_db test_legacy < "$HERE/02_assertions.sql"

echo "== TEST B : chemin 008 (forme iOS) =="
if [ -f "$ROOT/008_convergence_canonical_schema.sql" ]; then
  sed 's/set telephone = telephone ||/set telephone = p.telephone ||/' \
    "$ROOT/008_convergence_canonical_schema.sql" > /tmp/008_patched.sql
  run_chain test_008 \
    "$HERE/00_stub_supabase.sql" \
    "$ROOT/001_create_next_move_schema.sql" \
    "$ROOT/002_add_rls_policies.sql" \
    "$HERE/01_seed_legacy.sql" \
    /tmp/008_patched.sql
  psql_db test_008 << 'EOF' >/dev/null
INSERT INTO public.relances (prospect_id, step, status, scheduled_for, content, sent_at) VALUES
  ('00000000-0000-0000-0000-000000000001','j2','pending', now()+interval '1 day','ios j2',NULL),
  ('00000000-0000-0000-0000-000000000002','j5','awaiting_approval', now()+interval '2 days','ios j5',NULL),
  ('00000000-0000-0000-0000-000000000003','j10','sent', now()-interval '1 day','ios j10',now()-interval '1 day'),
  ('00000000-0000-0000-0000-000000000004','j2','sent', now()-interval '2 days','ios j2 sans ts',NULL);
EOF
  psql_db test_008 < "$ROOT/010_relances_system.sql" >/dev/null
  psql_db test_008 < "$ROOT/010_relances_system.sql" >/dev/null
  psql_db test_008 << 'EOF'
DO $$
DECLARE v INT;
BEGIN
  SELECT count(*) INTO v FROM public.relances;
  IF v <> 4 THEN RAISE EXCEPTION 'B1: % relances au lieu de 4', v; END IF;
  SELECT count(*) INTO v FROM public.relances WHERE type_relance IN ('inactif_j2','inactif_j5','reactivation_longterme');
  IF v <> 4 THEN RAISE EXCEPTION 'B2: mapping step incomplet (%)', v; END IF;
  SELECT count(*) INTO v FROM public.relances WHERE status='sent' AND sent_at IS NULL;
  IF v <> 0 THEN RAISE EXCEPTION 'B3: sent sans sent_at'; END IF;
  SELECT count(*) INTO v FROM public.relances_enriched WHERE step IN ('j2','j5','j10');
  IF v <> 4 THEN RAISE EXCEPTION 'B4: alias step vue casse (%)', v; END IF;
  SELECT count(*) INTO v FROM public.relances WHERE courtier_id IS NULL;
  IF v <> 0 THEN RAISE EXCEPTION 'B5: courtier_id non backfille'; END IF;
  RAISE NOTICE 'ASSERTIONS B PASSENT';
END $$;
EOF
else
  echo "  (008 absent de cette branche — chemin B saute)"
fi

echo "== OK : les deux chemins de convergence passent =="
