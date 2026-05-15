const path = require('path');
const { runPython } = require('./pythonRunner');

function recommendWithLightFM(attendeeId, limit) {
  const backendDir = path.resolve(__dirname, '..');
  const recommendScript = path.join(backendDir, 'recommender', 'recommend.py');
  const args = [attendeeId || ''];
  if (limit) args.push(String(limit));
  const { result, attempts } = runPython(recommendScript, args, { cwd: backendDir });

  if (!result) {
    const details = attempts.map((attempt) => `${attempt.command}: ${attempt.error}`).join('\n');
    throw new Error(`Could not run LightFM recommender.\n${details}`);
  }

  let payload;
  try {
    payload = JSON.parse((result.stdout || '').trim());
  } catch (error) {
    throw new Error(`LightFM returned non-JSON output: ${result.stdout || result.stderr || 'empty output'}`);
  }

  if (!payload.ok) {
    throw new Error(payload.error || 'LightFM recommender failed.');
  }

  return {
    attendeeId: payload.attendee_id,
    source: payload.source,
    recommendations: payload.recommendations
  };
}

module.exports = { recommendWithLightFM };
