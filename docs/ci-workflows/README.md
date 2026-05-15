# GitHub Actions — Workflows à activer manuellement

Les 3 workflows ci-dessous sont **prêts à activer**. Ils sont stockés en `.yml.txt`
ici plutôt qu'à `.github/workflows/` car l'agent qui a généré le PR n'a pas
le scope OAuth `workflow` requis pour pousser sous `.github/workflows/`.

## Activation manuelle

Depuis un terminal local (utilisateur avec scope `workflow`) :

```bash
mkdir -p .github/workflows
cp docs/ci-workflows/web-ci.yml.txt .github/workflows/web-ci.yml
cp docs/ci-workflows/ios-ci.yml.txt .github/workflows/ios-ci.yml
cp docs/ci-workflows/sql-lint.yml.txt .github/workflows/sql-lint.yml
git add .github/workflows/
git commit -m "ci: activate web/ios/sql-lint workflows"
git push
```

Une fois pushé, les 3 workflows tournent automatiquement sur push `main` et PR.

## Workflows fournis

| Fichier | Trigger | Job |
|---------|---------|-----|
| `web-ci.yml.txt` | PR/push touchant `klaris_web/**` | lint + typecheck + vitest + next build |
| `ios-ci.yml.txt` | PR/push touchant `klaris_ios/**` | flutter analyze + flutter test --coverage |
| `sql-lint.yml.txt` | PR/push touchant `*.sql` | sqlfluff sur migrations |

## Notes

- Le `web-ci.yml` accepte `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  en placeholder pour permettre le build. Pour des tests E2E réels, ajouter les
  secrets dans Settings → Secrets and variables → Actions.
- Le `ios-ci.yml` tourne sur `macos-14` runner — coût ~$0.08/minute, 25 min max.
- Le `sql-lint.yml` exclut volontairement les règles de style verbeuses pour
  ne flagger que les erreurs de syntaxe.
