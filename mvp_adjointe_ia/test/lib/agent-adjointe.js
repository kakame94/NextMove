const { loadSystemPrompt, injectPromptVariables } = require('./prompt-loader');

const systemPromptTemplate = loadSystemPrompt();

/**
 * Agent B — Adjointe IA (uses the REAL production prompt)
 * Replicates the exact call pattern from sms_handler.js buildClaudeMessages()
 */
async function callAdjointe(anthropic, clientData, history, newMessage, courtierNom = 'Joanel') {
  const systemPrompt = injectPromptVariables(systemPromptTemplate, {
    courtierNom,
    ficheClient: clientData,
    historique: history || 'Aucun historique — premier contact.'
  });

  const response = await anthropic.messages.create({
    model: process.env.CLAUDE_MODEL || 'claude-sonnet-4-6',
    max_tokens: 1024,
    system: systemPrompt,
    messages: [{ role: 'user', content: newMessage }]
  });

  return response.content[0].text;
}

/**
 * Parse IA response — replicates parseClaudeResponse() from sms_handler.js
 */
function parseResponse(responseText) {
  const result = { clientMessage: responseText, action: null, qualified: false };

  // Check for JSON action block
  const jsonMatch = responseText.match(/```json\n([\s\S]*?)\n```/);
  if (jsonMatch) {
    try {
      result.action = JSON.parse(jsonMatch[1]);
      result.clientMessage = responseText.replace(/```json\n[\s\S]*?\n```/, '').trim();
    } catch (e) { /* invalid JSON, ignore */ }
  }

  // Check for QUALIFIED keyword
  if (/QUALIFIED\s*$/i.test(responseText)) {
    result.qualified = true;
    result.clientMessage = result.clientMessage.replace(/\n?QUALIFIED\s*$/i, '').trim();
  }

  return result;
}

module.exports = { callAdjointe, parseResponse };
