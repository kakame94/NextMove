const fs = require('fs');
const path = require('path');

/**
 * Generate console + JSON report from test results
 */
function generateReport(results) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);

  // Console output
  console.log('\n=== CONVERSATION QUALITY TEST REPORT ===');
  console.log(`Date: ${new Date().toISOString()}`);
  console.log(`Model: ${process.env.CLAUDE_MODEL || 'claude-sonnet-4-6'}\n`);

  console.log('Scenario                               Turns  Score    Pass');
  console.log('─'.repeat(65));

  let totalScore = 0;
  let passCount = 0;
  let criticalCount = 0;

  results.forEach(r => {
    const score = r.evaluation?.scoreGlobal ?? '??';
    const pass = r.evaluation?.pass ?? false;
    const criticals = r.evaluation?.criticalFailures?.length || 0;

    const name = r.scenarioName.padEnd(40).slice(0, 40);
    const turns = String(r.turns).padStart(5);
    const scoreStr = typeof score === 'number' ? `${score.toFixed(1)}%` : score;
    const passStr = pass ? '\x1b[32mPASS\x1b[0m' : '\x1b[31mFAIL\x1b[0m';

    console.log(`${name} ${turns}  ${scoreStr.padStart(7)}  ${passStr}`);

    if (typeof score === 'number') totalScore += score;
    if (pass) passCount++;
    criticalCount += criticals;
  });

  const avg = results.length > 0 ? (totalScore / results.length).toFixed(1) : 0;
  console.log('─'.repeat(65));
  console.log(`OVERALL: ${passCount}/${results.length} passed (${avg}% average)`);
  console.log(`Critical failures: ${criticalCount}`);

  // Estimate cost (~$0.048/scenario)
  const cost = (results.length * 0.048).toFixed(2);
  console.log(`API cost estimate: ~$${cost}`);

  // JSON report
  const reportPath = path.resolve(__dirname, '../output', `report-${timestamp}.json`);
  const report = {
    timestamp: new Date().toISOString(),
    model: process.env.CLAUDE_MODEL || 'claude-sonnet-4-6',
    results,
    summary: {
      totalScenarios: results.length,
      passed: passCount,
      failed: results.length - passCount,
      averageScore: parseFloat(avg),
      criticalFailures: criticalCount,
      estimatedCost: parseFloat(cost)
    }
  };

  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  console.log(`\nDetailed report: ${reportPath}`);

  return report;
}

module.exports = { generateReport };
