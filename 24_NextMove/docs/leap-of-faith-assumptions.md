# Klaris — Leap-of-Faith Assumptions

> **Action L1 du plan post-challenge Lean Startup.** Documenter explicitement les 3 hypothèses critiques qui doivent tenir pour que Klaris devienne une entreprise viable. Si l'une casse, **pivot**.
> **Source méthodologique :** *The Lean Startup* (Eric Ries, Crown Business 2011, Ch4 Experiment + Ch7 Measure).
> **Owner :** Eliot (suivi mensuel) · revue trimestrielle équipe.
> Date : 2026-05-08

---

## Définition

> *« Leap-of-faith assumptions are the most risky elements of a startup's plan, the parts on which everything else depends. »* — Eric Ries (Ch4)

Une leap-of-faith assumption = hypothèse non prouvée, critique, dont l'invalidation force un **pivot** (pas une optimisation produit).

Klaris a **3 leap-of-faith assumptions** : Value · Growth · Compliance.

---

## LF1 — Value Hypothesis

> Un courtier immobilier solo au Québec **paiera 100 CAD/mois** si Klaris lui sauve **2-3 heures/jour d'admin** (équivalent ~50 CAD/h × 22 jours ouvrables).

### Pourquoi critique
- Cost structure marge brute 91.5 % suppose ce prix tenu.
- Si solo refuse 100 CAD/mois → bascule freemium ou pricing < 50 CAD → marge ≤ 80 % → seuil rentabilité ×3.
- Si solo paie mais < 100 CAD → recalibrer toute la projection MRR.

### Test (Sprint 9-12, M3)
| Étape | Action | Owner |
|-------|--------|-------|
| 1 | Onboarder 10 courtiers solo (segment Joanel) en mode **trial 14 jours gratuit** | Eliot + Joanel referrals |
| 2 | À J+14, présenter facture 100 CAD/mois auto-débit Stripe | Klaris in-app |
| 3 | Mesurer **conversion trial → paid** + **temps gagné déclaré** (NPS sub-question) | Métriques cohort |

### Critère GO (persevere)
- ≥ **3/10** trial → paid conversion (30%)
- ET temps gagné déclaré médian ≥ **2h/jour** sur cohort
- ET au moins 1 courtier dit explicitement « j'aurais payé 150 CAD »

### Critère NO-GO (pivot)
- ≤ **1/10** trial → paid (10%)
- OU temps gagné déclaré médian < 1h/jour
- → **Customer need pivot** (Ch8) : peut-être que ce n'est pas l'admin SMS, c'est autre chose. Refaire JTBD interview.

### Critère AMBER (recalibrer, pas pivot)
- 2/10 trial → paid (20%)
- → Tester pricing 75 CAD/mois sur cohort 2 (M4) avant pivot.

---

## LF2 — Growth Hypothesis

> Le réseau **referrals courtier ↔ courtier** produit naturellement un **viral coefficient k ≥ 1** (chaque courtier payant génère ≥ 1 nouveau courtier qualifié).

### Pourquoi critique
- BMC actuel : 100% referrals → CAC ≈ 0.
- Si k < 1 → growth s'éteint après le réseau Joanel (M6-M9).
- Si k = 0 → besoin canal payant (Google Ads, OACIQ events, partenariat Centris) → CAC ↑ → seuil rentabilité ↑.

### Test (Sprint 8-12, M6)
| Étape | Action | Owner |
|-------|--------|-------|
| 1 | Activer feature « Inviter un confrère » in-app (Sprint 9) | Dennis |
| 2 | Tracker `referral_invitations_sent` + `referral_signup_completed` par courtier source | Supabase events |
| 3 | À M6, calculer k pour les 5 premiers courtiers payants (excl. Joanel) | Eliot |

### Formule
```
k = (nb invitations envoyées / courtier) × (taux conversion invitation → signup payant)
Exemple : 4 invitations × 0.25 conversion = k = 1.0 ✅
```

### Critère GO (persevere)
- **k ≥ 1.0** sur cohort 5 premiers payants
- ET au moins 2 courtiers ont généré ≥ 2 referrals chacun

### Critère NO-GO (pivot)
- **k < 0.5** sur cohort 5 premiers payants
- → **Channel pivot** (Ch8) : activer Google Ads ($500-1000/mois M6) + démarrer démarchage OACIQ events
- → Re-projeter cost structure avec CAC = 50-100 CAD/courtier (vs 0)

### Critère AMBER (boost)
- 0.5 ≤ k < 1.0
- → Doubler incentive referral (1 mois gratuit pour chaque referral signé) avant de basculer paid

---

## LF3 — Compliance Hypothesis

> L'OACIQ (régulateur courtage immobilier QC) **acceptera** un outil IA SMS si **audit log + 1-clic reprise humaine** sont implémentés (pas de bannissement réglementaire dans les 12 mois).

### Pourquoi critique
- Verbatim JP (persona #4) : *« Si vous utilisez un outil et que cet outil fait des choses à votre place, vous êtes imputable »*.
- Risque amende Loi 25 : jusqu'à **10 M CAD**.
- Si OACIQ bannit → Klaris devient illégal → 0 revenu QC.

### Test (Sprint 9-12, M6)
| Étape | Action | Owner |
|-------|--------|-------|
| 1 | Envoyer email OACIQ (cf. [oaciq-outreach.md](./oaciq-outreach.md)) | Eliot |
| 2 | Si réponse → préparer dossier (architecture + transcript + checklist conformité) | Dennis + Eliot |
| 3 | Demander RDV (visio ou Brossard) | Eliot |
| 4 | Recueillir feedback formel ou informel par écrit | Eliot |

### Critère GO (persevere)
- Réponse écrite OACIQ (même informelle) confirmant approche **acceptable** ou **à clarifier sur point X mineur**
- Pas de demande de modification structurelle (audit log + reprise humaine validés tels quels)

### Critère NO-GO (pivot)
- OACIQ exige certification payante > 50k CAD avant lancement
- OU OACIQ refuse l'IA générative en SMS prospect direct
- → **Technology pivot** (Ch8) :
  - Option A : passer à des « recommandations courtier-validées » (IA suggère, courtier envoie chaque message manuellement)
  - Option B : pivoter vers marché France (RGPD adressé, CNIL plus permissive sur IA conversationnelle)

### Critère AMBER (négocier)
- OACIQ demande modifications majeures (ex. : disclosure « AI-generated » dans chaque SMS)
- → Implémenter conformément + retester acceptation marché courtier (peut casser UX promise « son assistante »)

---

## Tableau de bord — décision globale

| Hypothèse | Status M3 | Status M6 | Status M9 | Status M12 |
|-----------|-----------|-----------|-----------|------------|
| LF1 Value | À mesurer | Décision GO/NO-GO | Recalibrer si AMBER | Validée si GO |
| LF2 Growth | N/A (pas assez de payants) | À mesurer | Décision GO/NO-GO | Plan B activé si NO-GO |
| LF3 Compliance | Dialogue ouvert | Décision GO/NO-GO | Dossier OACIQ déposé si pertinent | Certification ou pivot |

**Règle de décision globale (Ch8 Pivot or Persevere) :**
- 3/3 GO → persevere full
- 2/3 GO + 1 AMBER → persevere avec mitigations
- 2/3 GO + 1 NO-GO → pivot ciblé sur la dimension qui casse
- 1/3 GO ou moins → pivot stratégique global (refaire JTBD + redéfinir produit)

---

## Suivi

- [ ] Sprint 9 : feature « Inviter un confrère » + tracking referrals (LF2)
- [ ] Sprint 9 : email OACIQ envoyé (LF3)
- [ ] M3 : 1er Pivot/Persevere meeting → revoir LF1 sur 10 trial
- [ ] M6 : 2e Pivot/Persevere → décision LF1, LF2, LF3
- [ ] M9 : 3e Pivot/Persevere → activer plan B paid si LF2 NO-GO
- [ ] M12 : audit final 3 hypothèses

---

*Document v1.0 — 2026-05-08 — basé sur* The Lean Startup *— Eric Ries, Crown Business 2011, ISBN 978-0-307-88791-7*
