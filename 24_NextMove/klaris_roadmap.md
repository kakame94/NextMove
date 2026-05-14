# Klaris — Roadmap technique

> **Statut** : v1.0 · Q3 2026 · post-call cofondateurs 2026-05-13
> **Audience** : Dennis (tech lead) · Eliot · Walkens · Seydou
> **Cadence** : sync hebdo lundi 10h · revue sprint chaque 2 semaines
> **Lien étude** : Étude de marché v3 §7.1 (séquence) + §7.4 (KPI)

---

## Vue d'ensemble

```
SPRINTS LIVRÉS (1-6)
├─ Sprint 1 : SMS intake + qualification + scoring
├─ Sprint 2 : Conversations + Relances UI + Settings + Push + Drift cache
├─ Sprint 3 : Briefing 7h30 + Create prospect + Filtres + Stats + Demo seed + Tests
├─ Sprint 4 : Search + Calendrier + Voicemail + Templates + Agence + Rapport PDF
├─ Sprint 5 : Local notifs + Offline sync + Carte + Voice memos + Centris + Onboarding + A11y
└─ Sprint 6 : Apple Sign In + iOS Widget + Watch + Live Activities + es-MX + Sentry + Patrol

SPRINT 7 — VOICE ACTION + RELANCES PRECISES (4 semaines · M3-M4)
├─ Voice prompt → action (Calendly RDV créé)
├─ Relances scheduler n8n / Edge Function (cron 15min)
├─ Reconciliation drift J+2/J+5 (retirer J+10 modèle + templates)
└─ Tests intégration relances + voice E2E

SPRINT 8 — DASHBOARD WEB + INSTAGRAM (4 semaines · M4-M5)
├─ Klaris web /threads + /calendar + /settings (parité iOS)
├─ Instagram DM intake (canal nouveau pour Maxime)
└─ Performance + observabilité Sentry réelle

SPRINT 9 — INTEGRATIONS CRM EXTERNES (4 semaines · M5-M6)
├─ API Follow Up Boss (push lead qualifié → CRM)
├─ API Centiva RE/MAX (compat banner Belma)
└─ Webhooks bidirectionnels
```

---

## Sprint 7 — Voice action + Relances précises

> **Durée** : 4 semaines (M3-M4)
> **Owner** : Dennis (backend) + Eliot (relances spec / Claude prompts)
> **Objectif** : démo vendredi → produit livrable. Voice = vraie Action Layer.

### Module A — Voice qui exécute (Action Layer)

#### Contexte
Demo cofondateurs : voice répond aux questions ("combien de prospects chauds"). Next step = voice qui **exécute actions** (créer RDV, déclencher relance, marquer perdu).

#### User stories
- **US-V1** : Courtier dit *« Organise un RDV avec Patrick Côté demain 14h »* → événement créé dans Calendar + SMS confirmation envoyée au prospect.
- **US-V2** : Courtier dit *« Relance Marie Dubois maintenant »* → relance immédiate envoyée (override scheduler).
- **US-V3** : Courtier dit *« Marque Karim S. comme perdu »* → status prospect changé + audit log.

#### Tech stack
| Couche | Décision |
|---|---|
| Voice → Text | Whisper FR (déjà déployé pour voicemail intake / notes vocales) |
| Intent + entities | Claude Sonnet · tool use · function calling structuré |
| Calendar | Calendly API (priorité 1) · fallback iOS EventKit (déjà câblé) |
| Actions catalog | `create_appointment` · `send_relance_now` · `mark_lost` · `query_prospects` |
| Confirmation | Push notif iOS *« Voulez-vous valider l'action ? »* avant exécution si destructive |

#### Acceptance criteria
- [ ] Whisper transcript < 3 sec pour 30 sec voice
- [ ] Claude Sonnet retourne tool call JSON valide
- [ ] Calendly event créé via API + invité envoyé
- [ ] SMS confirmation prospect avec lien Calendly
- [ ] Audit log entrée par action (OACIQ compliance)
- [ ] Human-in-the-Loop : action destructive (mark_lost, send_relance) demande swipe-to-approve sur app iOS

#### Risques
| Risque | Mitigation |
|---|---|
| Hallucination Claude (mauvais prospect ciblé) | Tool call avec UUID strict · échec si UUID inexistant · pas inférence |
| Latence voice cumulée > 8 sec | Stream Whisper + Claude · feedback UI « j'écoute / je traite » |
| Calendly rate limit | Cache disponibilités 15 min · queue Supabase Edge si limite atteinte |

---

### Module B — Relances précises (dates + scheduler vivant)

#### Contexte
Spec décision matrix v1.1 existe (508 lignes). Implémentation partielle :
- ✅ Modèle Flutter `Relance` (model + repository + UI iOS)
- ✅ Templates SMS rédigés (FR-CA)
- ❌ Scheduler cron 15 min qui appelle `can_send_relance()`
- ❌ Edge Function Supabase qui orchestre fetch → guard → send Twilio
- ⚠️ Drift à réconcilier : modèle iOS a `J+10` mais spec v1.1 dit J+2/J+5 seulement

#### Drift à résoudre
| Fichier | État actuel | Action |
|---|---|---|
| `klaris_ios/lib/data/models/relance.dart` | enum `RelanceStep { j2, j5, j10 }` | Retirer `j10` |
| `mvp_adjointe_ia/src/prompts/relances.md` | Templates J+10 | Retirer · garder J+2 + J+5 + RDV J-1 + Post-visite J+1 |
| `docs/relances/relances-decision-matrix.md` pseudo-code | `inactif_7j/14j/21j` constants | Renommer en `inactif_j2/inactif_j5` |
| Spec v1.1 doc | Mention "T3 retiré" mais pseudo-code pas aligné | Mettre à jour pseudo-code |

#### Tasks
- [ ] T1 — Refactor model `Relance` (retire J+10 enum + tests)
- [ ] T2 — Update templates FR-CA (purger J+10, ajouter EN-CA si Persona bilingue)
- [ ] T3 — Update spec `relances-decision-matrix.md` pseudo-code (drift v1.0 → v1.1)
- [ ] T4 — Edge Function `relances-scheduler/index.ts` Deno · cron 15 min
- [ ] T5 — Migration SQL `relances_scheduler_state` (last_run, processed_count, errors)
- [ ] T6 — Tests scheduler (idempotence, FOR UPDATE lock, retry Twilio 1x)
- [ ] T7 — Page Klaris web `/relances` (parité iOS) parking lot voir Sprint 8
- [ ] T8 — Audit log toutes relances envoyées (OACIQ + Loi 25 export)

#### Acceptance criteria
- [ ] Cron 15 min identifie prospects triggers armés
- [ ] `can_send_relance()` applique 13 garde-fous séquentiels (G1-G13)
- [ ] STOP CASL block définitif (test : envoyer STOP → tentative relance → BLOCK log)
- [ ] Fenêtre 8h-20h heure locale Québec respectée (DEFER si hors plage)
- [ ] Jours fériés QC 2026 chargés (config Supabase)
- [ ] Twilio retry 1× après 2 sec si HTTP ≠ 200
- [ ] Lock `FOR UPDATE` sur `prospects.id` pour idempotence cron qui se chevauche
- [ ] Audit log entry par envoi (Loi 25 export possible)

#### KPI Sprint 7
- Démo vendredi : 5 prospects fictifs avec dates J+2/J+5 réelles, scheduler tournant
- Latence voice → action : < 5 sec end-to-end
- Couverture tests : > 80 % `can_send_relance()` (chaque guard testé)

---

## Sprint 8 — Dashboard web + Instagram (M4-M5)

### Module A — Klaris web parité

Pages manquantes vs iOS :
- `/threads` — conversations SMS plein écran
- `/calendar` — agenda + Calendly sync
- `/settings` — theme + langue + opt-out Loi 25 + data export
- `/relances` — liste cards triées par échéance (mirror iOS Sprint 2)

Stack : Next.js 15 App Router (déjà en place) · Supabase SSR · réutilisation hooks iOS via shared business logic.

### Module B — Instagram DM intake

#### Contexte
Maxime Belma cite : « plein de contenu Instagram, gens DM, leur TikTok plus compliqué pour stats ». Klaris doit capturer leads Instagram.

#### Tech
| Couche | Décision |
|---|---|
| Channel | Meta Business Suite API (Instagram DM webhook) |
| Auth | Facebook Graph API OAuth |
| Routing | n8n webhook → Claude Sonnet qualification (même flow que SMS) |
| Storage | Table `conversations.channel = 'instagram'` + `external_message_id` |
| Display | iOS app + web app threads avec icône canal |

#### Tasks
- [ ] Setup Meta Business Verification (peut prendre 2-3 semaines)
- [ ] Webhook Instagram DM → Supabase Edge Function
- [ ] Routing dans Claude Sonnet (même prompt qualif que SMS, contexte canal)
- [ ] UI tag canal dans threads (SMS / Instagram / Email future)

---

## Sprint 9 — Intégrations CRM externes (M5-M6)

### Module A — Follow Up Boss API

#### Pourquoi
GTM §6.5 — pas remplacer FUB, **interface avec**. Klaris qualifie lead, push dans FUB du courtier qui utilise déjà FUB.

#### Tasks
- [ ] OAuth FUB par courtier (settings page)
- [ ] Endpoint push lead qualifié : `POST /people` FUB API
- [ ] Sync bidirectionnel statuts (FUB stage ↔ Klaris status)
- [ ] Templates FUB déclenchent quand status update

### Module B — Centiva RE/MAX bridge

#### Pourquoi
Maxime Belma utilise Centiva (banner RE/MAX). Klaris doit cohabiter (Action Layer) pas remplacer.

#### Tasks (recherche d'abord)
- [ ] Audit Centiva API publique ou demande syndication
- [ ] Si pas API : webhook outbound Centiva (si supporté)
- [ ] Sinon : fallback CSV import / email digest

---

## Backlog (M6+)

| Item | Priorité | Note |
|---|---|---|
| Plex Manager intégration (Jérémy Cameroun) | P3 | Décision holding/partenariat préalable |
| EN-CA i18n complète templates relances | P2 | Persona bilingue requiert |
| Score Stories (LLM résumé hebdo perf courtier) | P3 | Marketing content idea Walkens |
| Analytics dashboard agence | P2 | Persona 4 Manager Dashboard |
| Live chat web embed (widget courtier site) | P3 | Capture lead web site courtier |

---

## Décisions binaires ouvertes (à trancher Q3)

1. **Calendly vs Cal.com** — Calendly mature mais payant ; Cal.com open-source + self-host possible
2. **Voice always-on vs push-to-talk** — UX risque facturation Whisper massive si streaming continu
3. **Holding model Plex Manager** — Eliot pour, Walkens contre. Bloque partenariat Sprint 9+.
4. **VP Sales** — pas tranché. Bloque pipeline outbound agences.

---

> **Cadence livraison cible** : démo vendredi (Sprint 7 module A partial) → Sprint 7 fin M4 → 50 clients M6 → 100 clients M12.
