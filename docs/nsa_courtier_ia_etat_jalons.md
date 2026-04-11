# Projet NSA — Courtier immobilier / Adjointe IA — État et jalons

> **Auteur** : Eliot Alanmanou (9520-5936 Québec Inc.)
> **Date** : 9 mars 2026
> **Source de vérité** : dépôt `CascadeProjects` (chemins relatifs ci-dessous)

---

## 1. Périmètre et dénomination

**NSA** est utilisé ici comme **code projet interne** pour l’initiative produit **courtier immobilier + agent IA (adjointe administrative)**. Aucun dossier nommé `NSA` n’existe dans le dépôt ; le périmètre est **cartographié** via les artefacts sous `_bmad-output/` et la spécification MVP sous `_bmad-output/mvp_adjointe_ia_courtier/`.

Si le code projet doit désigner un autre livrable (ex. renommage), mettre à jour ce fichier et les références dans [`00_INDEX_CONTEXTES.md`](../00_INDEX_CONTEXTES.md).

---

## 2. Cartographie des artefacts (où ça vit)

| Zone | Contenu | Rôle |
|------|---------|------|
| [`_bmad-output/atelier_courtier_resultats/`](../../../_bmad-output/atelier_courtier_resultats/) | `01_*.md` … `09_*.md` + scripts `gen_*.py`, `generer_pdf_consolidation.py` | Atelier découverte / JTBD (mars 2026) : empathie, journée type, douleurs/gains, forces de progrès, chemin idéal, segmentation, confort client IA, arcs narratifs, vision « baguette magique » |
| [`_bmad-output/miro_atelier_courtier_immobilier.md`](../../../_bmad-output/miro_atelier_courtier_immobilier.md) | Structure de board Miro | Gabarit d’animation atelier (cadres 1–5) |
| [`_bmad-output/mvp_adjointe_ia_courtier/SPEC_MVP.md`](../../../_bmad-output/mvp_adjointe_ia_courtier/SPEC_MVP.md) | Spécification fonctionnelle MVP | Cas d’usage, flux SMS, contraintes (Loi 25, pas Matrix v1, etc.) |
| [`_bmad-output/mvp_adjointe_ia_courtier/GUIDE_DEPLOIEMENT.md`](../../../_bmad-output/mvp_adjointe_ia_courtier/GUIDE_DEPLOIEMENT.md) | Pré-requis cloud | Twilio, Supabase (région Canada), n8n, clés API |
| [`_bmad-output/mvp_adjointe_ia_courtier/src/`](../../../_bmad-output/mvp_adjointe_ia_courtier/src/) | `db/schema.sql`, `flows/`, `prompts/` | Squelette technique (schéma, workflow n8n, prompts) |

**Notes :**

- Les exports **PNG** homonymes des livrables (ex. `01_carte_empathie.png`) peuvent exister sur le poste de travail ; ils ne sont pas listés dans ce dépôt au moment de la rédaction.
- Les **seules** occurrences littérales du sigle « NSA » ailleurs dans le dépôt relèvent d’autres contextes (ex. références pédagogiques sécurité) et ne constituent pas ce projet.

---

## 3. État d’avancement (synthèse)

| Volet | Statut | Commentaire |
|-------|--------|-------------|
| Découverte / problème | **Terminé (côté documentation)** | Synthèses structurées en `01`–`09` ; thèmes récurrents : visibilité transversale transaction, admin, adoption tech si valeur immédiate. |
| Vision produit | **Documentée** | Vision « offre en secondes », signature électronique, adjointe 24/7 (`09_baguette_magique_vision.md`). |
| MVP cible | **Spécifié** | `SPEC_MVP.md` — Sprint 1 « répond et collecte » (SMS, collecte structurée, rappels). |
| Implémentation | **Partielle** | Schéma DB, prompts, export workflow n8n ; déploiement end-to-end **non validé** dans ce dépôt (checklist `GUIDE_DEPLOIEMENT.md`). |
| Conformité / données | **À valider en exécution** | Loi 25, hébergement CA, politiques de rétention : prérequis listés, pas d’audit de conformité formalisé ici. |

---

## 4. Jalons prochains (tangibles)

1. **Gel du périmètre MVP Sprint 1** — Valider avec le pilote courtier : canaux (SMS seul vs email), ton, transfert vers humain.
2. **Environnement** — Exécuter `GUIDE_DEPLOIEMENT.md` sur un compte de test (Supabase `ca-central-1`, Twilio, n8n) et tracer les secrets hors Git (`.env` / coffre).
3. **Intégration** — Importer `n8n_workflow_sms.json`, brancher webhook Twilio, tester scénario « premier contact » de bout en bout.
4. **Données** — Appliquer `schema.sql`, jeu de données fictif, tests de suppression / export (Loi 25).
5. **Produit** — Mesurer une métrique pilote (ex. délai de première réponse, taux de complétion questionnaire) avant d’élargir le scope (ex. relances avancées, email).

---

## 5. Risques et dépendances

- **Dépendance outils** : coût et disponibilité Twilio / n8n / cloud — documentés, pas garantis par ce repo.
- **Gap atelier ↔ MVP** : l’atelier met l’accent sur la **visibilité dossier hypothécaire** et l’**offre rapide** ; le MVP documenté se concentre sur **réception client et collecte**. Un backlog explicite de rapprochement (ou périmètre volontairement réduit) évite l’attente implicite.
- **Absence de code applicatif** front dédié dans ce dossier MVP : l’orchestration repose sur n8n + services — documenter toute évolution (API custom, UI courtier).

---

## 6. Fichiers clés à ouvrir en premier

1. [`_bmad-output/mvp_adjointe_ia_courtier/SPEC_MVP.md`](../../../_bmad-output/mvp_adjointe_ia_courtier/SPEC_MVP.md)
2. [`_bmad-output/atelier_courtier_resultats/`](../../../_bmad-output/atelier_courtier_resultats/) (synthèses `01`–`09`)
3. [`_bmad-output/mvp_adjointe_ia_courtier/GUIDE_DEPLOIEMENT.md`](../../../_bmad-output/mvp_adjointe_ia_courtier/GUIDE_DEPLOIEMENT.md)

---

## 7. Historique documentaire

| Version | Date | Changement |
|---------|------|------------|
| 1.0 | 2026-03-09 | Création — état repo, jalons, risques |
