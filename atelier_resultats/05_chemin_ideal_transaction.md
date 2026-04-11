# Chemin Ideal de la Transaction

## Resultat de l'atelier JTBD — Mars 2026

### Legende

```
[IA]       = automatisable par IA
[COURTIER] = legal/humain requis
[MIXTE]    = partiellement automatisable
```

### Flux de la transaction

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   [0] MARKETING / REFERENCE                                        [IA]     │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA                                                           │
│   "IA peut repondre aux premiers messages"                                  │
│   Tout vient par reference — pas de pub, pas de prospection active.         │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [1] PREMIER CONTACT + COLLECTE INFO                              [IA]     │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA / Assistante                                              │
│   Collecte: nom, adresse, type de bien, situation financiere,               │
│   documents requis, motivations.                                            │
│   "80-90% des taches de l'assistante pourraient etre automatisees"          │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [2] QUALIFICATION HYPOTHECAIRE                                   [MIXTE]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: Assistante / IA                                              │
│   Fait le pont avec courtier hypothecaire, verifie pre-qualification.       │
│   "Pas de visibilite sur le cote hypothecaire — c'est le trou noir"         │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [3] PLANIFICATION VISITES                                        [IA]     │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA                                                           │
│   Gere le calendrier, calcule les temps de deplacement,                     │
│   optimise les trajets entre visites.                                       │
│   "Si l'IA pouvait gerer mon calendrier, ca serait enorme"                  │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [4] VISITES                                                   [COURTIER]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: Courtier en personne                                         │
│   LEGAL — obligation de presence physique du courtier.                      │
│   "La loi ne me permet pas de deleguer les visites"                         │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [5] COMPARABLES + ANALYSE                                        [IA]     │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA                                                           │
│   Fait les comparables dans Matrix, analyse de marche.                      │
│   "Les comparables c'est mecanique — l'IA peut faire ca"                    │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [6] OFFRE D'ACHAT                                                [MIXTE]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA genere l'offre, Courtier valide + negocie.               │
│   "Imagine — l'offre d'achat generee en secondes"                           │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [7] INSPECTION                                                   [MIXTE]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: Assistante/IA planifie, Courtier negocie si problemes.      │
│   Coordination avec inspecteur de confiance.                                │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [8] SUIVI FINANCEMENT                                            [MIXTE]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: IA + Courtier hypothecaire                                   │
│   Visibilite sur dossier hypotheque, anticipation des blocages.             │
│   "On perd des deals parce que le financement tombe"                        │
│                         │                                                    │
│                         v                                                    │
│                                                                              │
│   [9] CLOTURE                                                   [COURTIER]  │
│   ─────────────────────────────────────────────────────────────────────      │
│   Responsable: Courtier + Notaire                                           │
│   Documents finaux, signature chez le notaire.                              │
│   "La signature electronique — tout se fait en 2-3 minutes"                 │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Tableau recapitulatif

| Etape | Responsable | Automatisable? | Verbatim cle |
|-------|-------------|----------------|--------------|
| [0] Marketing / Reference | IA | Oui | "IA peut repondre aux premiers messages" |
| [1] Premier contact + Collecte | IA / Assistante | Oui | "80-90% des taches pourraient etre automatisees" |
| [2] Qualification hypothecaire | Assistante / IA | Partiel | "Pas de visibilite — c'est le trou noir" |
| [3] Planification visites | IA | Oui | "Si l'IA pouvait gerer mon calendrier..." |
| [4] Visites | Courtier | Non (legal) | "La loi ne me permet pas de deleguer" |
| [5] Comparables + Analyse | IA | Oui | "Les comparables c'est mecanique" |
| [6] Offre d'achat | IA + Courtier | Partiel | "L'offre d'achat generee en secondes" |
| [7] Inspection | Assistante / IA + Courtier | Partiel | Coordination avec inspecteur de confiance |
| [8] Suivi financement | IA + Courtier hypothecaire | Partiel | "On perd des deals — le financement tombe" |
| [9] Cloture | Courtier + Notaire | Non (legal) | "Signature electronique — 2-3 minutes" |

## Synthese automatisation

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   AUTOMATISABLE (IA)          4 etapes   [0] [1] [3] [5]       │
│   MIXTE (IA + humain)         4 etapes   [2] [6] [7] [8]       │
│   HUMAIN REQUIS (legal)       2 etapes   [4] [9]               │
│                                                                  │
│   >>> 80% du parcours peut etre assiste ou automatise par IA    │
│   >>> Seules les visites et la cloture notariale restent        │
│       100% humaines (contrainte legale OACIQ)                   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```
