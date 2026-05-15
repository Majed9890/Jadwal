const path = require('path');
const { printPythonHelp } = require('./pythonRunner');
const { recommendWithNodeFallback } = require('./nodeRecommendationFallback');
const { recommendWithLightFM } = require('./lightfmRecommendations');

const attendeeId = process.argv[2];
const limit = process.argv[3] || '10';

try {
  const payload = recommendWithLightFM(attendeeId, limit);
  printRecommendations(payload);
} catch (error) {
  console.error(error.message);
  console.error('Running Node fallback recommender instead...');
  runNodeFallback(attendeeId, limit).catch((fallbackError) => {
    console.error(`Node fallback failed: ${fallbackError.message}`);
    process.exit(1);
  });
}

async function runNodeFallback(requestedAttendeeId, requestedLimit) {
  const payload = await recommendWithNodeFallback(requestedAttendeeId, requestedLimit);
  printRecommendations(payload);
}

function printRecommendations(payload) {
  console.log(`Recommended events for attendee ${payload.attendeeId}`);
  console.log(`Source: ${payload.source}`);
  console.log('');

  if (!payload.recommendations.length) {
    console.log('No recommendable approved events found.');
    return;
  }

  for (const event of payload.recommendations) {
    const price = Number(event.price || 0);
    console.log(`${event.rank}. ${event.event_name || '(Untitled event)'}`);
    console.log(`   ${event.category || 'Unknown category'} | ${event.city || 'Unknown city'} | SAR ${price}`);
    console.log(`   score: ${event.score} | event_id: ${event.event_id}`);
  }
}
