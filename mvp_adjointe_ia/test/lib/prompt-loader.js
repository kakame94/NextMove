const fs = require('fs');
const path = require('path');

/**
 * Load the production system prompt from src/prompts/adjointe_systeme.md
 * and inject variables — replicates buildClaudeMessages() from sms_handler.js
 */
function loadSystemPrompt() {
  const promptPath = path.resolve(__dirname, '../../src/prompts/adjointe_systeme.md');
  return fs.readFileSync(promptPath, 'utf-8');
}

function injectPromptVariables(template, { courtierNom, ficheClient, historique }) {
  return template
    .replace(/\{\{NOM_COURTIER\}\}/g, courtierNom || 'Joanel')
    .replace('{{FICHE_CLIENT}}', JSON.stringify(ficheClient || {}, null, 2))
    .replace('{{HISTORIQUE}}', historique || 'Aucun historique — premier contact.');
}

function loadAgentPrompt(promptName) {
  const promptPath = path.resolve(__dirname, '../prompts', promptName);
  return fs.readFileSync(promptPath, 'utf-8');
}

module.exports = { loadSystemPrompt, injectPromptVariables, loadAgentPrompt };
