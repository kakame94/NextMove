# Repository Cleanup Plan

> Audit du 2026-05-15 a identifié 4 défauts d'organisation. Ce document décrit
> les actions appliquées + les actions à confirmer par l'humain.

## Défauts identifiés

1. **3 noms produit** dans le même repo : NextMove (repo) · Klaris (code) · Cléa (branding stale)
2. **`24_NextMove/maison-forge/`** — projet rénovation **sans rapport** avec Klaris (180 KB)
3. **BMAD scaffolding** dupliqué : `/_bmad/` (1.9 MB) ET `/24_NextMove/_bmad/` (1.9 MB)
4. **`_bmad-output/`** (84 KB) — artefacts générés à exclure du versioning

## Actions appliquées (cet apport)

✅ **Renommé** `24_NextMove/clea-brand/` → `24_NextMove/klaris-brand/` (git mv, historique préservé)
✅ **Mis à jour** références dans `klaris-roadmap-onepager.html` + `klaris-tech-roadmap-onepager.html`
✅ Politique de marque documentée dans la mémoire Claude Code (cf. `~/.claude/projects/.../memory/brand_klaris.md`)

## Actions à confirmer par l'humain

### 1. Extraire Maison Forge

Maison Forge est un **projet de rénovation distinct**, sans lien produit avec Klaris.

**Recommandation :** créer un nouveau repo `kakame94/maison-forge` et déplacer le dossier :

```bash
# Depuis le worktree
git mv 24_NextMove/maison-forge /tmp/maison-forge-temp
cd /tmp/maison-forge-temp
git init && git add . && git commit -m "init: extracted from NextMove repo"
gh repo create kakame94/maison-forge --private --source=. --push
# Puis dans NextMove :
git rm -r 24_NextMove/maison-forge
git commit -m "chore: extract maison-forge to separate repo"
```

### 2. Dédupliquer BMAD

Deux copies identiques de `_bmad/`. Garder une seule à la racine, supprimer celle sous `24_NextMove/` :

```bash
git rm -r 24_NextMove/_bmad 24_NextMove/_bmad-output
git commit -m "chore: dedup BMAD scaffolding (root copy is canonical)"
```

### 3. Versionner `.gitignore` pour exclure outputs générés

Créer un `.gitignore` à la racine :

```gitignore
# Generated artifacts
_bmad-output/
*.pdf
!klaris-cost-structure.xlsx
!klaris-cost-structure.pdf

# Local secrets / env
.env
.env.local
*.local

# IDE / OS
.DS_Store
.idea/
.vscode/
*.swp

# Node / Next.js
node_modules/
.next/
out/
*.tsbuildinfo

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
.packages
.pub-cache/
.pub/
coverage/
**/.gradle/
**/Pods/

# Python build
__pycache__/
*.pyc
.pytest_cache/

# n8n credentials (devraient JAMAIS être committé)
*.credentials.json
```

### 4. Mise à jour README racine

Le README racine décrit "Next Move" comme produit principal. À mettre à jour :

```markdown
# NextMove — Repository monorepo

Repository contenant les composants de la suite Klaris (par Next Move) :

- `klaris_ios/` — App iOS Flutter
- `klaris_web/` — Web dashboard Next.js (mirror iOS)
- `next_move_intake_agent_v2.json` — Workflow n8n principal
- `001_create_next_move_schema.sql` → `008_convergence_canonical_schema.sql` — Migrations Supabase
- `24_NextMove/` — Documentation produit, brand assets, recherche UX, roadmaps
- `mvp_adjointe_ia/` — MVP prédécesseur (à archiver une fois Klaris stable en prod)

**Marque utilisateur final :** Klaris
**Entité légale :** Next Move
```

### 5. Archiver `mvp_adjointe_ia/`

Le dossier `mvp_adjointe_ia/` contient l'ancien MVP avec un schéma DB **incompatible** (table `clients` vs `prospects` canonique). Ne plus le maintenir une fois Klaris stable :

```bash
# Quand Klaris en prod + Joanel migré
git mv mvp_adjointe_ia _archived/mvp_adjointe_ia
git commit -m "chore: archive mvp_adjointe_ia (replaced by Klaris)"
```

## Pourquoi pas tout faire automatiquement

Les actions 1-2-4-5 sont **destructives** (suppression de dossiers, modification du README racine). Politique d'agent : on confirme avec l'humain avant action destructive irréversible.

L'action 3 (.gitignore) est ajoutable dans le PR courant si tu veux.

## Validation post-cleanup

```bash
# Vérifier aucune référence morte
grep -rln "clea-brand" --include="*.html" --include="*.md" --include="*.py" .
# Devrait retourner uniquement des fichiers historiques sous git history

# Vérifier que la migration 008 s'applique sans erreur
psql "$SUPABASE_DB_URL" -f 008_convergence_canonical_schema.sql --dry-run

# Vérifier que klaris_web build
cd klaris_web && npm install && npm run typecheck && npm run test && npm run build
```

---

**Klaris** — une marque **Next Move** · 2026
