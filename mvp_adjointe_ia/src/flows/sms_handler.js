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

async function updateClientFromAction(supabase, clientId, actionData) {
  if (actionData.action !== 'creer_fiche') return;

  const clientUpdate = actionData.client;

  await supabase
    .from('clients')
    .update({
      nom_complet: clientUpdate.nom_complet || undefined,
      type_client: clientUpdate.type_client || undefined,
      secteur_recherche: clientUpdate.secteur_recherche || undefined,
      budget_min: clientUpdate.budget_min || undefined,
      budget_max: clientUpdate.budget_max || undefined,
      pre_qualification: clientUpdate.pre_qualification,
      montant_pre_qualif: clientUpdate.montant_pre_qualif || undefined,
      type_propriete: clientUpdate.type_propriete || undefined,
      nb_chambres_min: clientUpdate.nb_chambres_min || undefined,
      delai_souhaite: clientUpdate.delai_souhaite || undefined,
      disponibilites: clientUpdate.disponibilites || undefined,
      premier_achat: clientUpdate.premier_achat,
      score_chaleur: clientUpdate.score_chaleur || 'tiede',
      statut: 'en_qualification'
    })
    .eq('id', clientId);
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
  buildCourtierNotification,
  scheduleInitialFollowUps
};
