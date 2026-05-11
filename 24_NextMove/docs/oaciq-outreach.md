# OACIQ — Stratégie d'engagement & première prise de contact

> **Action 5 du plan post-challenge BMC.** Ouvrir le dialogue avec l'OACIQ avant M6 pour faire de la conformité réglementaire un *moat* compétitif (cf. `business-canvas-challenge.md` §3.8 + Risque #5 Ch5 livre).
> **Statut :** brouillon à valider par l'équipe avant envoi.
> **Owner suggéré :** Eliot (porte-parole BD).
> Date : 2026-05-08

---

## 1 — Pourquoi maintenant

**Verbatim JP (persona #4, deck slide 09 + Risque #5 Top-7) :**
> *« Si vous utilisez un outil et que cet outil fait des choses à votre place, vous êtes imputable. »*
> *« Les outils non-conformes vont être bannis. »*

**Conséquence stratégique.** Sans engagement formel avec l'OACIQ :
- Adoption agence (segment #4 JP, 99 courtiers) bloquée par scepticisme conformité.
- Risque amende Loi 25 jusqu'à 10 M CAD (cf. [business-constraints-checklist.md:24](./business-constraints-checklist.md#L24)).
- Aucun argument différenciant face à un futur entrant US/EU non-conforme.

**Avec engagement formel :**
- Mention « En dialogue avec l'OACIQ » utilisable dès M6 dans le deck.
- Premier acteur IA-broker certifié = barrière à l'entrée durable.

---

## 2 — Cibles de contact OACIQ

| Personne / fonction | Pourquoi | Source |
|----------------------|----------|--------|
| **Direction de l'inspection professionnelle** | Valide la conformité d'outils utilisés par les courtiers | oaciq.com → À propos → Direction |
| **Direction de l'encadrement** | Émet les normes professionnelles | oaciq.com → Encadrement |
| **Comité d'inspection** | Vérifie en pratique l'usage d'outils par courtier | oaciq.com → Inspection |
| **Service à la clientèle / Information** | Premier filtre, oriente vers la bonne direction | info@oaciq.com (à confirmer) |

**Approche recommandée :** ne pas démarcher directement la Direction. Passer par le Service à la clientèle avec une demande explicite de réorientation.

---

## 3 — Email type — première prise de contact

### Version FR (à envoyer)

```
Objet : Outil IA assistant SMS pour courtiers — demande d'orientation conformité

Bonjour,

Je m'appelle Eliot Alanmanou, cofondateur de Klaris (klaris.app), un outil
d'assistance par SMS destiné aux courtiers immobiliers du Québec.

Notre produit est utilisé par un courtier pilote au Grand Montréal depuis
mars 2026. Il qualifie les prospects par SMS au nom du courtier (avec sa
signature : « Je suis l'assistante de [Nom] »), prend les premières
informations (secteur, budget, statut hypothécaire) et remet une fiche
prête au courtier humain qui prend ensuite le relais.

Avant d'élargir l'usage à d'autres courtiers, nous souhaitons :

  1. Présenter notre architecture (audit log de chaque conversation IA,
     1-clic reprise humaine, hébergement Canada — Loi 25 / PIPEDA) à
     l'OACIQ pour validation préventive de conformité.

  2. Nous assurer qu'aucun élément de notre flux ne contrevient aux normes
     professionnelles — notamment l'article 14 (devoir de conseil), la
     gestion documentaire, et le consentement explicite des prospects.

  3. Comprendre les attentes de l'OACIQ vis-à-vis des outils d'IA
     utilisés par ses membres, dans le sillage de la Loi 25.

Pourriez-vous m'indiquer la personne ou la direction à laquelle adresser
cette demande de rencontre (en visio ou en présentiel à Brossard) ?

Je peux fournir en amont :
  • un résumé d'architecture (2 pages),
  • une transcription anonymisée d'une conversation pilote,
  • notre checklist de conformité Loi 25 / CASL / OACIQ.

Merci pour votre orientation.

Cordialement,
Eliot Alanmanou
Cofondateur — Klaris (Next Move)
alanmanou.consulting@gmail.com · klaris.app
```

### Version EN (réserve)

```
Subject: AI SMS assistant for real estate brokers — compliance guidance request

Hello,

I'm Eliot Alanmanou, cofounder of Klaris (klaris.app), an SMS-based
assistant for Quebec real estate brokers.

We have one pilot broker in Greater Montreal since March 2026. Klaris
qualifies prospects via SMS on the broker's behalf (signed "I'm [Name]'s
assistant"), gathers initial information (area, budget, mortgage status),
and hands a ready prospect record to the human broker who then takes over.

Before expanding to other brokers, we would like to:

  1. Present our architecture (audit log of each AI conversation, 1-click
     human takeover, Canada hosting — Law 25 / PIPEDA) to OACIQ for
     preventive compliance review.

  2. Ensure no part of our flow conflicts with professional standards —
     particularly Article 14 (duty to advise), records management, and
     explicit prospect consent.

  3. Understand OACIQ's expectations regarding AI tools used by members,
     in light of Law 25.

Could you indicate the person or division to address this meeting
request to (video or in-person at Brossard)?

I can share upfront:
  • a 2-page architecture summary,
  • an anonymized transcript of a pilot conversation,
  • our Law 25 / CASL / OACIQ compliance checklist.

Thank you for your guidance.

Best regards,
Eliot Alanmanou
Cofounder — Klaris (Next Move)
alanmanou.consulting@gmail.com · klaris.app
```

---

## 4 — Pièces jointes à préparer avant envoi

| # | Document | État | Owner |
|---|----------|------|-------|
| PJ-1 | Résumé architecture 2 pages (extrait `architecture.md` + diagramme flux) | À rédiger | Dennis |
| PJ-2 | Transcription anonymisée 1 conversation pilote Joanel (depuis `transcripts/`) | À sélectionner + anonymiser | Eliot |
| PJ-3 | Checklist conformité (depuis `business-constraints-checklist.md`) | ✅ Existe | — |
| PJ-4 | One-pager produit (PDF deck slide 04 + 05 + 06) | Export PDF du deck | Walkens |

---

## 5 — Plan de relance

| Jour | Action |
|------|--------|
| J+0 | Envoi email à info@oaciq.com (à confirmer adresse) |
| J+5 | Si pas de réponse : appel téléphonique OACIQ (1 800 440-7170) |
| J+10 | Si pas d'orientation : LinkedIn → directeur(trice) inspection |
| J+15 | Bilan, ajustement stratégie (escalade Conseil d'administration ?) |
| J+30 | Si dialogue ouvert : envoi PJ-1 à PJ-4 + proposition de date |
| M+1 | Premier rendez-vous (visio ou Brossard) |
| M+3 | Compte-rendu intégré au BMC + deck slide 09 (« En dialogue OACIQ ») |

---

## 6 — Risques & angles morts de cette démarche

| Risque | Mitigation |
|--------|------------|
| OACIQ refuse tout dialogue avec un éditeur tiers | Passer par un courtier membre (Joanel) qui sollicite l'OACIQ pour son propre usage |
| OACIQ impose des contraintes incompatibles (ex. : interdiction IA générative) | Documenter les contraintes, prioriser celles bloquantes, négocier un POC encadré |
| Dialogue traîne > 3 mois | Pas bloquant pour la commercialisation Solo (segment Joanel) — bloquant uniquement pour l'offre Agence |
| OACIQ exige une certification payante | Budget juridique F11 à doubler dans `business-cost-structure.md` |
| Concurrent obtient la certification avant nous | Surveillance veille via Google Alerts « OACIQ IA », « OACIQ courtier outil » |

---

## 7 — Indicateur de succès

À M6, la slide 09 du deck doit pouvoir afficher l'un des éléments suivants (par ordre de force) :

1. ⭐⭐⭐ « **Outil reconnu par l'OACIQ** » (peu probable à M6, objectif M12)
2. ⭐⭐ « **Audit OACIQ favorable — rapport disponible sur demande** »
3. ⭐ « **En dialogue actif avec l'OACIQ depuis [date]** »
4. (statut actuel) Pas de mention OACIQ dans le deck

Toute progression au minimum vers le niveau 1 ⭐ est un succès.

---

*Document v1.0 — 2026-05-08 — Eliot Alanmanou*
