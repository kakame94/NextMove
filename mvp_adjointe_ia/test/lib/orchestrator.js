const { callAdjointe, parseResponse } = require('./agent-adjointe');
const { callProspect } = require('./agent-prospect');
const { evaluateConversation } = require('./agent-evaluator');

/**
 * Format conversation history like sms_handler.js loadConversationHistory()
 */
function formatHistory(conversation) {
  if (conversation.length === 0) return '';
  return conversation.map(m => {
    const role = m.role === 'prospect' ? 'Client' : 'Assistante';
    const time = new Date().toLocaleString('fr-CA');
    return `[${time}] ${role}: ${m.message}`;
  }).join('\n');
}

/**
 * Run a single scenario — the core conversation loop
 */
async function runScenario(anthropic, scenario) {
  const conversation = [];
  const clientData = {
    nom_complet: scenario.persona.name || 'Nouveau prospect',
    telephone: '+15141111111',
    type_client: null,
    statut: 'nouveau'
  };

  let turn = 0;
  let prospectMessage = scenario.persona.openingMessage;
  let lastAction = null;
  let qualified = false;
  const startTime = Date.now();

  console.log(`  Running: ${scenario.name}...`);

  while (turn < (scenario.maxTurns || 20)) {
    // 1. Record prospect message
    conversation.push({ role: 'prospect', message: prospectMessage });

    // 2. Check for STOP scenario
    if (/^(STOP|stop|ARRET|arret)$/i.test(prospectMessage.trim())) {
      // IA should handle STOP — still call it to test behavior
    }

    // 3. Get Agent B (Adjointe IA) response
    const history = formatHistory(conversation.slice(0, -1)); // exclude current message
    const iaRawResponse = await callAdjointe(anthropic, clientData, history, prospectMessage);
    const parsed = parseResponse(iaRawResponse);

    conversation.push({ role: 'adjointe', message: parsed.clientMessage });

    // 4. Check termination conditions
    if (parsed.action?.action === 'creer_fiche') {
      lastAction = parsed.action;
      // Update clientData with extracted info
      if (parsed.action.client) {
        Object.assign(clientData, parsed.action.client);
      }
      break;
    }

    if (parsed.qualified) {
      qualified = true;
      break;
    }

    // Check if IA closed the conversation (inappropriate content, STOP)
    const closurePatterns = [
      /je ne suis pas en mesure/i,
      /vous avez ete desabonne/i,
      /vous etes desabonne/i,
      /unsubscribed/i,
      /je transmets.*rappel/i
    ];
    const isClosed = closurePatterns.some(p => p.test(parsed.clientMessage));
    if (isClosed && turn > 0) break;

    turn++;
    if (turn >= (scenario.maxTurns || 20)) break;

    // 5. Get Agent A (Prospect) next message
    prospectMessage = await callProspect(anthropic, scenario.persona, conversation);
    turn++;
  }

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`  Done: ${conversation.length} messages in ${elapsed}s`);

  // 6. Evaluate with Agent C
  console.log(`  Evaluating...`);
  const evaluation = await evaluateConversation(anthropic, scenario, conversation);

  return {
    scenarioId: scenario.id,
    scenarioName: scenario.name,
    turns: Math.ceil(conversation.length / 2),
    conversation,
    extractedAction: lastAction,
    qualified,
    clientData,
    evaluation,
    elapsedSeconds: parseFloat(elapsed)
  };
}

module.exports = { runScenario };
