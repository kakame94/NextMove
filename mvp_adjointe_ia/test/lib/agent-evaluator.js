const { loadAgentPrompt } = require('./prompt-loader');

const agentCTemplate = loadAgentPrompt('agent-c-evaluator.md');

/**
 * Agent C — QA Evaluator (uses sonnet for nuanced judgment)
 */
async function evaluateConversation(anthropic, scenario, conversation) {
  const systemPrompt = agentCTemplate
    .replace('{{SCENARIO_ID}}', scenario.id)
    .replace('{{SCENARIO_NAME}}', scenario.name)
    .replace('{{PROSPECT_TYPE}}', scenario.persona?.type || 'inconnu')
    .replace('{{EXPECTED_LANGUAGE}}', scenario.persona?.language || 'fr')
    .replace('{{EXPECTED_SCORE}}', scenario.expectations?.expectedScore || 'N/A')
    .replace('{{PROSPECT_PROFILE}}', JSON.stringify(scenario.persona?.profile || {}, null, 2));

  const transcript = conversation
    .map((m, i) => `[Tour ${Math.floor(i/2) + 1}] ${m.role === 'prospect' ? 'Prospect' : 'Adjointe IA'}: ${m.message}`)
    .join('\n\n');

  const response = await anthropic.messages.create({
    model: process.env.CLAUDE_MODEL || 'claude-sonnet-4-6',
    max_tokens: 2048,
    system: systemPrompt,
    messages: [{
      role: 'user',
      content: `Voici la conversation complete a evaluer:\n\n${transcript}\n\nEvalue selon la rubrique. Reponds UNIQUEMENT en JSON.`
    }]
  });

  const text = response.content[0].text;
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    return jsonMatch ? JSON.parse(jsonMatch[0]) : { error: 'No JSON found', raw: text };
  } catch (e) {
    return { error: 'JSON parse failed', raw: text };
  }
}

module.exports = { evaluateConversation };
