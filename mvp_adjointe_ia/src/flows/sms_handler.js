/**
 * SMS Handler — Logique principale du flux n8n
 *
 * Ce fichier contient les fonctions JS a utiliser dans les noeuds
 * "Code" de n8n pour le flux SMS Entrant → Reponse IA.
 */

// === NOEUD 1: Chercher ou creer le client ===

async function findOrCreateClient(supabase, phoneNumber) {
  // Chercher le client par telephone
  const { data: existing } = await supabase
    .from('clients')
    .select('*')
    .eq('telephone', phoneNumber)
    .single();

  if (existing) return existing;

  // Creer un nouveau client avec juste le telephone
  const { data: newClient } = await supabase
    .from('clients')
    .insert({
      nom_complet: 'Nouveau prospect',
      telephone: phoneNumber,
      canal_contact: 'sms',
      statut: 'nouveau'
    })
    .select()
    .single();

  return newClient;
}

// === NOEUD 2: Charger l'historique de conversation ===

async function loadConversationHistory(supabase, clientId, limit = 20) {
  const { data: messages } = await supabase
    .from('conversations')
    .select('*')
    .eq('client_id', clientId)
    .order('created_at', { ascending: true })
    .limit(limit);

  if (!messages || messages.length === 0) return '';

  return messages.map(m => {
    const role = m.direction === 'entrant' ? 'Client' : 'Assistante';
    const time = new Date(m.created_at).toLocaleString('fr-CA');
    return `[${time}] ${role}: ${m.message}`;
  }).join('\n');
}

// === NOEUD 3: Construire le prompt pour Claude ===

function buildClaudeMessages(systemPrompt, history, clientData, newMessage, courtierNom) {
  // Remplacer les variables dans le prompt systeme
  let prompt = systemPrompt
    .replace(/\{\{NOM_COURTIER\}\}/g, courtierNom)
    .replace('{{FICHE_CLIENT}}', JSON.stringify(clientData, null, 2))
    .replace('{{HISTORIQUE}}', history || 'Aucun historique — premier contact.');

  return {
    model: process.env.CLAUDE_MODEL || 'claude-sonnet-4-6',
    max_tokens: 1024,
    temperature: parseFloat(process.env.CLAUDE_TEMPERATURE || '0.35'),
    system: prompt,
    messages: [
      { role: 'user', content: newMessage }
    ]
  };
}

// === NOEUD 4: Parser la reponse Claude ===

function parseClaudeResponse(responseText) {
  const result = {
    clientMessage: responseText,
    action: null
  };

  // Extraire le bloc JSON si present
  const jsonMatch = responseText.match(/```json\n([\s\S]*?)\n```/);
  if (jsonMatch) {
    try {
      result.action = JSON.parse(jsonMatch[1]);
      // Retirer le bloc JSON du message client
      result.clientMessage = responseText
        .replace(/```json\n[\s\S]*?\n```/, '')
        .trim();
    } catch (e) {
      // JSON invalide, ignorer
    }
  }

  return result;
}

// === NOEUD 5: Sauvegarder un message ===

async function saveMessage(supabase, clientId, canal, direction, message) {
  await supabase
    .from('conversations')
    .insert({
      client_id: clientId,
      canal,
      direction,
      message
    });
}

// === NOEUD 6: Mettre a jour la fiche client ===

// Actions qui portent un etat de fiche a persister. On accumule les slots a
// CHAQUE tour (ledger), pas seulement a la fin — sinon {{FICHE_CLIENT}} reste
// vide mid-flow et l'IA redemande des infos deja donnees.
const FICHE_ACTIONS = ['creer_fiche', 'fiche_partielle', 'mise_a_jour_fiche', 'alerte_urgente'];

// Le CHECK de la colonne n'accepte que ces valeurs.
const SCORE_DB = { chaud_urgent: 'chaud', chaud: 'chaud', tiede: 'tiede', froid: 'froid' };
const TYPE_CLIENT_DB = new Set(['acheteur', 'vendeur']); // pas de 'acheteur_vendeur' en colonne

// Enregistre le consentement EXPRES de mise en relation (finalite marketplace,
// distincte du consentement implicite et du STOP/CASL). N'ecrit QUE sur un OUI
// explicite, de maniere idempotente, dans le journal auditable lead_consents.
// Best-effort : n'interrompt jamais le flux SMS si la table est absente du
// deploiement courant. NB: en schema canonique, prospectId = prospects.id.
async function persistMarketplaceConsent(supabase, prospectId, actionData, sourceMessageId) {
  const c = (actionData && actionData.client) || {};
  if (c.consentement_mise_en_relation !== true) return; // seulement un OUI explicite
  try {
    const { data: existing } = await supabase
      .from('lead_consents')
      .select('id')
      .eq('prospect_id', prospectId)
      .eq('purpose', 'broker_match')
      .is('revoked_at', null)
      .limit(1);
    if (existing && existing.length) return; // consentement vivant deja enregistre
    await supabase.from('lead_consents').insert({
      prospect_id: prospectId,
      purpose: 'broker_match',
      capture_channel: 'sms',
      source_message_id: sourceMessageId || null,
      consent_text_version: 'v1'
    });
  } catch (e) {
    console.error('persistMarketplaceConsent failed:', e && e.message);
  }
}

async function updateClientFromAction(supabase, clientId, actionData) {
  if (!actionData || !FICHE_ACTIONS.includes(actionData.action)) return;

  const c = actionData.client || {};

  // `|| undefined` => on n'ecrase jamais un champ deja rempli avec un null/vide.
  await supabase
    .from('clients')
    .update({
      nom_complet: c.nom_complet || undefined,
      courriel: c.courriel || undefined,
      type_client: TYPE_CLIENT_DB.has(c.type_client) ? c.type_client : undefined,
      secteur_recherche: c.secteur_recherche || undefined,
      budget_max: c.budget_max || undefined,
      pre_qualification: typeof c.pre_qualification === 'boolean' ? c.pre_qualification : undefined,
      montant_pre_qualif: c.montant_pre_qualif || undefined,
      type_propriete: c.type_propriete || undefined,
      nb_chambres_min: c.nb_chambres_min || undefined,
      delai_souhaite: c.delai_souhaite || undefined,
      disponibilites: c.disponibilites || undefined,
      premier_achat: typeof c.premier_achat === 'boolean' ? c.premier_achat : undefined,
      score_chaleur: SCORE_DB[c.score_chaleur] || undefined,
      notes: c.notes || undefined,
      statut: actionData.action === 'creer_fiche' ? 'qualifie' : 'en_qualification'
    })
    .eq('id', clientId);

  // Journaliser le consentement de mise en relation (marketplace) s'il a ete donne.
  await persistMarketplaceConsent(supabase, clientId, actionData, actionData.source_message_id);
}

// === NOEUD 7: Generer la notification courtier ===

function buildCourtierNotification(clientData) {
  const score = (clientData.score_chaleur || 'TIEDE').toUpperCase();

  return `NOUVEAU PROSPECT [${score}]

Nom: ${clientData.nom_complet}
Type: ${clientData.type_client || 'Non precise'}
Secteur: ${clientData.secteur_recherche || 'Non precise'}
Budget: ${clientData.budget_max ? clientData.budget_max + '$' : 'Non precise'}
Pre-qualifie: ${clientData.pre_qualification ? 'Oui' + (clientData.montant_pre_qualif ? ' (' + clientData.montant_pre_qualif + '$)' : '') : 'Non'}
Type: ${clientData.type_propriete || 'Non precise'}
Delai: ${clientData.delai_souhaite || 'Non precise'}
Disponible: ${clientData.disponibilites || 'Non precise'}

Prochaine action: Planifier premiere rencontre`;
}

// === NOEUD 8: Planifier les relances initiales ===

async function scheduleInitialFollowUps(supabase, clientId, clientData) {
  const now = new Date();
  const relances = [];

  // Si pas pre-qualifie → relance documents a J+2 et J+5
  if (!clientData.pre_qualification) {
    relances.push({
      client_id: clientId,
      type_relance: 'documents_pre_qualif',
      date_prevue: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000).toISOString(),
      statut: 'planifiee'
    });
    relances.push({
      client_id: clientId,
      type_relance: 'documents_pre_qualif_rappel',
      date_prevue: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000).toISOString(),
      statut: 'planifiee'
    });
  }

  // Relance post-premier-contact a J+1 si pas de rdv planifie
  relances.push({
    client_id: clientId,
    type_relance: 'suivi_premier_contact',
    date_prevue: new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000).toISOString(),
    statut: 'planifiee'
  });

  if (relances.length > 0) {
    await supabase.from('relances').insert(relances);
  }
}

module.exports = {
  findOrCreateClient,
  loadConversationHistory,
  buildClaudeMessages,
  parseClaudeResponse,
  saveMessage,
  updateClientFromAction,
  persistMarketplaceConsent,
  buildCourtierNotification,
  scheduleInitialFollowUps
};
