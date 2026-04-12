#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const Anthropic = require('@anthropic-ai/sdk');
const { runScenario } = require('./lib/orchestrator');
const { generateReport } = require('./lib/report');

async function main() {
  // Check API key
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('ERROR: ANTHROPIC_API_KEY is required.');
    console.error('Usage: ANTHROPIC_API_KEY=sk-ant-xxx npm test');
    process.exit(1);
  }

  const anthropic = new Anthropic();

  // Load scenarios
  const scenariosDir = path.resolve(__dirname, 'scenarios');
  let scenarioFiles = fs.readdirSync(scenariosDir)
    .filter(f => f.endsWith('.yaml'))
    .sort();

  // Filter by --scenario flag if provided
  const scenarioArg = process.argv.find(a => !a.startsWith('-') && a !== process.argv[0] && a !== process.argv[1]);
  const hasScenarioFlag = process.argv.includes('--scenario');

  if (hasScenarioFlag && scenarioArg) {
    scenarioFiles = scenarioFiles.filter(f => f.includes(scenarioArg));
    if (scenarioFiles.length === 0) {
      console.error(`No scenario matching: ${scenarioArg}`);
      console.error('Available:', fs.readdirSync(scenariosDir).filter(f => f.endsWith('.yaml')).join(', '));
      process.exit(1);
    }
  }

  console.log(`\nLoading ${scenarioFiles.length} scenario(s)...\n`);

  const results = [];

  for (const file of scenarioFiles) {
    const scenarioPath = path.join(scenariosDir, file);
    const scenario = yaml.load(fs.readFileSync(scenarioPath, 'utf-8'));

    try {
      const result = await runScenario(anthropic, scenario);
      results.push(result);
    } catch (err) {
      console.error(`  ERROR in ${file}: ${err.message}`);
      results.push({
        scenarioId: scenario.id || file,
        scenarioName: scenario.name || file,
        turns: 0,
        conversation: [],
        evaluation: { scoreGlobal: 0, pass: false, criticalFailures: [`Runtime error: ${err.message}`] },
        error: err.message
      });
    }
  }

  // Generate report
  const report = generateReport(results);

  // Exit with code based on results
  const allPassed = report.summary.failed === 0;
  process.exit(allPassed ? 0 : 1);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
