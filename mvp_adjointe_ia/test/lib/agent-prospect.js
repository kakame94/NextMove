const { loadAgentPrompt } = require('./prompt-loader');

const agentATemplate = loadAgentPrompt('agent-a-prospect.md');

/**
 * Agent A — Prospect Simulator (uses haiku for cost efficiency)
 */
async function callProspect(anthropic, persona, conversationSoFar) {
  const systemPrompt = agentATemplate
    .replace('{{PERSONA_INSTRUCTIONS}}', persona.instructions || '')
    .replace('{{PERSONA_PROFILE}}', JSON.stringify(persona.profile || {}, null, 2))
    .replace('{{LANGUAGE}}', persona.language || 'fr');

  const transcript = conversationSoFar
    .map(m => `${m.role === 'prospect' ? 'Toi' : 'Adjointe'}: ${m.message}`)
    .join('\n');

  const response = await anthropic.messages.create({
    model: 'claude-3-5-haiku-latest',
    max_tokens: 256,
    system: systemPrompt,
    messages: [{
      role: 'user',
      content: transcript
        ? `Voici la conversation jusqu'ici:\n\n${transcript}\n\nQuelle est ta prochaine reponse en tant que prospect?`
        : 'La conversation commence. Envoie ton premier message.'
    }]
  });

  return response.content[0].text.trim();
}

module.exports = { callProspect };
