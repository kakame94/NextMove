/* ═══════════════════════════════════════════════════════════════
   Maison Forge — Netlify Function
   Génère un compte-rendu Phase 1 personnalisé via Claude API.
   Fallback template si pas de clé API configurée.

   Trigger : Netlify Forms `submission-created` event
   OU appel direct depuis le client après submit.

   Env vars requises (Netlify dashboard):
     ANTHROPIC_API_KEY  — clé API Claude (sk-ant-...)
     NOTIFY_EMAIL       — email destinataire compte-rendu (Maison Forge inbox)
     RESEND_API_KEY     — (optionnel) pour envoi email via Resend
   ═══════════════════════════════════════════════════════════════ */

import Anthropic from '@anthropic-ai/sdk';

const SYSTEM_PROMPT = `Tu es l'architecte de la solution chez Maison Forge, agence de rénovation résidentielle à Montréal spécialisée en cuisines et salles de bain.

Ton rôle : générer un compte-rendu de Phase 1 (Découverte) à partir des réponses d'un formulaire web.

Style et ton :
- Voix Maison Forge : sobre, précise, confiante. Pas commerciale. Vocabulaire architectural.
- Pas de jargon construction, pas d'exclamations, pas de superlatifs.
- Utilise le vouvoiement (« Vous », « votre »).
- Phrases courtes. Mots concrets. Chiffres précis.
- Format : Markdown structuré avec sections claires.

Structure du compte-rendu (2-4 pages) :
1. **Lecture du projet** — reformule la demande en 3-5 lignes, comme si tu confirmais avoir compris.
2. **Lecture du besoin réel** — au-delà du brief explicite, identifie 2-3 enjeux sous-jacents (ex: si « cuisine 1985 + 4 personnes » → enjeu = capacité de stockage, ergonomie, valorisation revente).
3. **Hypothèses techniques préliminaires** — 3-5 points à valider en visite (structure, plomberie, électricité, permis Ville de Montréal applicables).
4. **Fourchette budgétaire commentée** — reprends l'estimation calculée et explique pourquoi on est dans cette fourchette. Mentionne ce qui pourrait la faire bouger.
5. **Recommandations Phase 1** — 3 actions concrètes proposées (visite découverte conjointe, validation permis, etc.).
6. **Prochaines étapes** — calendrier proposé pour les 14 prochains jours.

Ne jamais :
- Quoter un prix précis (utilise des fourchettes).
- Promettre un délai exact.
- Conseiller des matériaux spécifiques avant la visite.
- Mentionner des concurrents.

Toujours :
- Citer Avita Pro (RBQ 5873-0946-01) comme partenaire entrepreneur si pertinent.
- Mentionner que le compte-rendu est une lecture initiale, à valider en visite.
- Proposer un suivi humain explicite.

Format de sortie : Markdown brut prêt à insérer dans un email.`;

export async function handler(event) {
  // CORS headers
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  let lead;
  try {
    lead = JSON.parse(event.body || '{}');
  } catch {
    return { statusCode: 400, headers, body: JSON.stringify({ error: 'Invalid JSON' }) };
  }

  // Validation minimale
  if (!lead.email || !lead.projet_type) {
    return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing required fields' }) };
  }

  const apiKey = process.env.ANTHROPIC_API_KEY;

  // ── Fallback template si pas de clé API ──
  if (!apiKey) {
    const fallback = buildFallbackReport(lead);
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        report: fallback,
        source: 'template',
        note: 'Generated from template — set ANTHROPIC_API_KEY env var to enable AI generation.'
      })
    };
  }

  // ── Génération IA via Claude ──
  try {
    const client = new Anthropic({ apiKey });

    const userPrompt = `Voici les réponses du formulaire de demande pour Maison Forge :

**Type de projet** : ${labelize('projet_type', lead.projet_type)}
**Surface** : ${labelize('surface', lead.surface)}
**Niveau de finition** : ${labelize('finition', lead.finition)}
**Délai souhaité** : ${labelize('delai', lead.delai)}
**Budget envisagé** : ${lead.budget_k} 000 $ CAD (${labelize('budget_flex', lead.budget_flex)})
**Occupation pendant travaux** : ${labelize('occupation', lead.occupation)}
**Quartier** : ${lead.quartier || 'non précisé'}
**Adresse** : ${lead.adresse || 'non précisée'}

**Motivation du projet (verbatim client)** :
"${lead.motivation || '(vide)'}"

**Estimation algorithmique** : ${lead.estimation_min} – ${lead.estimation_max} k$ CAD

**Préférence de contact** : ${labelize('canal_pref', lead.canal_pref)}

Génère le compte-rendu Phase 1 en suivant la structure définie dans le prompt système. Ton de Maison Forge.`;

    const message = await client.messages.create({
      model: 'claude-sonnet-4-6',  // Latest Sonnet, optimal cost/quality for this use case
      max_tokens: 2400,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: userPrompt }]
    });

    const report = message.content
      .filter(b => b.type === 'text')
      .map(b => b.text)
      .join('\n\n');

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        report,
        source: 'claude',
        model: message.model,
        usage: message.usage
      })
    };
  } catch (err) {
    console.error('Claude API error:', err);
    // En cas d'erreur API, on retombe sur le template (résilience)
    const fallback = buildFallbackReport(lead);
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        report: fallback,
        source: 'template_fallback',
        error: err.message
      })
    };
  }
}

// ─────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────

function labelize(key, val) {
  const labels = {
    projet_type: { cuisine:'Cuisine', salle_de_bain:'Salle de bain', reconfiguration:'Reconfiguration', conversion_locative:'Conversion locative', ajout_etage:'Agrandissement', autre:'Autre' },
    surface: { petite:'Petite (<80 pi²)', moyenne:'Moyenne (80-150 pi²)', grande:'Grande (150-300 pi²)', tres_grande:'Très grande (>300 pi²)', multi_pieces:'Multi-pièces', incertain:'À valider en visite' },
    finition: { essentiel:'Essentiel', confort:'Confort', premium:'Premium' },
    delai: { urgence:'Asap (<1 mois)', court:'1-3 mois', moyen:'3-6 mois', long:'6-12 mois', ouvert:'Pas pressé', exploration:'En exploration' },
    budget_flex: { ferme:'plafond ferme', souple:'souple ±15%', ouvert:'ouvert si valeur suit' },
    occupation: { oui:'reste sur place', non_relogement:'se reloge', locatif:'locatif vacant', vacant:'acquisition récente vacante' },
    canal_pref: { email:'Email', telephone:'Téléphone', sms:'SMS / WhatsApp', indifferent:'Indifférent' }
  };
  return (labels[key] && labels[key][val]) || val || 'non précisé';
}

function buildFallbackReport(lead) {
  const proj = labelize('projet_type', lead.projet_type);
  const surf = labelize('surface', lead.surface);
  const fin = labelize('finition', lead.finition);
  const del = labelize('delai', lead.delai);
  const occ = labelize('occupation', lead.occupation);
  const min = lead.estimation_min || '?';
  const max = lead.estimation_max || '?';

  return `# Compte-rendu Phase 1 — Lecture initiale

Bonjour${lead.nom ? ' ' + lead.nom.split(' ')[0] : ''},

Merci d'avoir pris le temps de remplir notre formulaire. Voici notre lecture initiale de votre demande, à valider en visite.

## 1 · Lecture du projet

Vous nous contactez pour un projet de **${proj.toLowerCase()}** dans le quartier ${lead.quartier || 'à préciser'}, surface ${surf.toLowerCase()}, niveau de finition visé : **${fin}**. Délai souhaité : ${del.toLowerCase()}. Vous ${occ === 'reste sur place' ? 'restez sur place' : occ.toLowerCase()} pendant les travaux.

${lead.motivation ? `Votre motivation citée : *« ${lead.motivation } »*` : ''}

## 2 · Lecture du besoin réel

À ce stade, nous identifions trois axes à explorer en visite :
- **Usage et ergonomie** — comment vous vivez réellement l'espace au quotidien.
- **Contraintes techniques** — état de la plomberie, de l'électrique, du bâti existant.
- **Horizon de propriété** — garde long terme, revente à 5 ans, ou rendement locatif. Cela change radicalement nos recommandations matériaux.

## 3 · Hypothèses techniques à valider

Sans visite, nous travaillons sous les hypothèses suivantes :
- Aucune intervention structurelle majeure (mur porteur, fondation).
- Plomberie et électricité aux normes RBQ courantes.
- Permis Ville de Montréal à clarifier selon l'arrondissement.
- Délais d'approvisionnement standards (4-8 semaines selon matériaux).

Ces hypothèses seront confirmées ou révisées lors de la visite Phase 1 conjointe avec **Avita Pro (RBQ 5873-0946-01)**.

## 4 · Fourchette budgétaire commentée

Notre algorithme estime votre projet entre **${min} k$ et ${max} k$ CAD**, sur la base des paramètres saisis.

Cette fourchette pourrait monter si :
- L'état du bâti révèle des reprises structurelles, plomberie ou électrique.
- Vous optez pour des matériaux haut de gamme (marbre, sur-mesure complet).

Cette fourchette pourrait baisser si :
- L'espace permet de conserver certains éléments (cabinetterie, plomberie, électrique).
- Vous acceptez des matériaux niveau « Confort » plutôt que « Premium ».

Le devis officiel intervient en **Phase 2 (Design & devis)**, après visite, avec ventilation par lot et trois niveaux de finition chiffrés.

## 5 · Recommandations Phase 1

1. **Visite découverte conjointe** — 60-90 min, Maison Forge + Avita Pro. Lecture du bâti, validation des hypothèses, alignement des objectifs.
2. **Vérification des permis applicables** — selon arrondissement et nature exacte des travaux.
3. **Discussion des trois scénarios** — bon, mieux, meilleur — avec fourchettes et compromis associés.

## 6 · Prochaines étapes

- **Cette semaine** : nous vous proposons 2-3 créneaux pour la visite Phase 1.
- **Sous 48 h après visite** : compte-rendu structuré envoyé par email.
- **Sous 5-7 jours** : si les bases conviennent, devis Phase 2 (forfait 500-1500 $, crédité si vous signez).

---

À bientôt,
**L'équipe Maison Forge**
*9520-5936 Québec Inc. · En collaboration avec Avita Pro*

> *Ce compte-rendu est une lecture initiale automatisée. Une analyse personnalisée par notre équipe vous sera envoyée sous 48 h ouvrables.*`;
}
