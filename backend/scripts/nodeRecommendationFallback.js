const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ quiet: true });

function normalize(value) {
  return value == null ? '' : String(value).trim().toLowerCase();
}

function priceFor(event) {
  const prices = [event.ticket_type1_price, event.ticket_type2_price]
    .filter((value) => typeof value === 'number');
  return prices.length ? Math.min(...prices) : 0;
}

async function fetchAll(supabase, table, columns = '*') {
  const rows = [];
  const pageSize = 1000;
  let start = 0;

  while (true) {
    const { data, error } = await supabase
      .from(table)
      .select(columns)
      .range(start, start + pageSize - 1);

    if (error) {
      throw new Error(`${table}: ${error.message}`);
    }

    rows.push(...(data || []));
    if (!data || data.length < pageSize) {
      return rows;
    }

    start += pageSize;
  }
}

async function recommendWithNodeFallback(attendeeId, limit = 10) {
  if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in backend/.env');
  }

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);
  const [attendees, events, interactions, tickets, interests] = await Promise.all([
    fetchAll(supabase, 'Attendee'),
    fetchAll(supabase, 'Event'),
    fetchAll(supabase, 'Interaction'),
    fetchAll(supabase, 'Ticket'),
    fetchAll(supabase, 'Attendee_Interests')
  ]);

  const chosenAttendeeId = attendeeId || attendees[0]?.attendee_id;
  if (!chosenAttendeeId) {
    throw new Error('No attendees found in Supabase.');
  }

  const attendee = attendees.find((row) => row.attendee_id === chosenAttendeeId) || {};
  const userInterests = new Set(
    interests
      .filter((row) => row.attendee_id === chosenAttendeeId)
      .map((row) => normalize(row.interests))
      .filter(Boolean)
  );
  const purchased = new Set(
    tickets
      .filter((row) => row.attendee_id === chosenAttendeeId)
      .map((row) => row.event_id)
      .filter(Boolean)
  );

  const likeCounts = new Map();
  for (const row of interactions) {
    if (normalize(row.interaction_type) !== 'like' || !row.event_id) continue;
    likeCounts.set(row.event_id, (likeCounts.get(row.event_id) || 0) + 1);
  }

  const purchaseCounts = new Map();
  for (const row of tickets) {
    if (!row.event_id) continue;
    purchaseCounts.set(row.event_id, (purchaseCounts.get(row.event_id) || 0) + 1);
  }

  const attendeeCity = normalize(attendee.city);
  const ranked = events
    .filter((event) => normalize(event.event_status) === 'approved')
    .filter((event) => !purchased.has(event.event_id))
    .map((event) => {
      const category = normalize(event.category);
      const city = normalize(event.city);
      let score = 0;

      if (userInterests.has(category)) score += 50;
      if (attendeeCity && attendeeCity === city) score += 10;
      score += (purchaseCounts.get(event.event_id) || 0) * 5;
      score += (likeCounts.get(event.event_id) || 0) * 3;
      score += Number(event.ticket_sold || 0) * 2;
      score += Number(event.sales || 0) / 1000;

      return { event, score };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, Number(limit));

  return {
    attendeeId: chosenAttendeeId,
    source: 'fallback',
    recommendations: ranked.map(({ event, score }, index) => ({
      ...event,
      rank: index + 1,
      price: priceFor(event),
      score: Number(score.toFixed(4))
    }))
  };
}

module.exports = { recommendWithNodeFallback };
