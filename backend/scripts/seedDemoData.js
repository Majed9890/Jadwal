const bcrypt = require('bcryptjs');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ quiet: true });

const { CITY_OPTIONS, CATEGORY_OPTIONS } = require('../src/constants/options');

const DEMO_PASSWORD = 'Jadwal123';
const DEMO_DOMAIN = 'jadwal.test';

if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in backend/.env');
  process.exit(1);
}

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

const eventTemplates = [
  ['Music', 'Riyadh', 'Demo Riyadh Music Night', 120],
  ['Music', 'Jeddah', 'Demo Jeddah Jazz Evening', 90],
  ['Music', 'Dammam', 'Demo Eastern Beats', 70],
  ['Sports', 'Jeddah', 'Demo Jeddah Football Cup', 45],
  ['Sports', 'Riyadh', 'Demo Riyadh Padel League', 80],
  ['Sports', 'Khobar', 'Demo Khobar Fitness Day', 35],
  ['Art', 'Medina', 'Demo Medina Art Walk', 40],
  ['Art', 'Riyadh', 'Demo Riyadh Gallery Night', 100],
  ['Art', 'Jeddah', 'Demo Jeddah Design Fair', 75],
  ['Technology', 'Riyadh', 'Demo Riyadh Tech Summit', 180],
  ['Technology', 'Dhahran', 'Demo Dhahran AI Lab', 60],
  ['Technology', 'Jeddah', 'Demo Startup Weekend', 50],
  ['Food', 'Jeddah', 'Demo Jeddah Food Festival', 55],
  ['Food', 'Riyadh', 'Demo Riyadh Taste Market', 65],
  ['Food', 'Taif', 'Demo Taif Coffee Trail', 30],
  ['Travel', 'Abha', 'Demo Abha Mountain Escape', 150],
  ['Travel', 'Al Ahsa', 'Demo Al Ahsa Heritage Tour', 85],
  ['Travel', 'Tabuk', 'Demo Tabuk Desert Trip', 130],
  ['Fashion', 'Riyadh', 'Demo Riyadh Fashion Week', 200],
  ['Fashion', 'Jeddah', 'Demo Jeddah Style Show', 110],
  ['Fashion', 'Khobar', 'Demo Khobar Boutique Night', 70],
  ['Gaming', 'Riyadh', 'Demo Riyadh Esports Arena', 95],
  ['Gaming', 'Jeddah', 'Demo Jeddah FIFA Challenge', 45],
  ['Gaming', 'Dammam', 'Demo Dammam Gaming Expo', 55]
];

function attendeeEmail(index) {
  return `demo.attendee${String(index).padStart(2, '0')}@${DEMO_DOMAIN}`;
}

function organizerEmail(index) {
  return `demo.organizer${String(index).padStart(2, '0')}@${DEMO_DOMAIN}`;
}

async function findByEmail(table, email) {
  const { data, error } = await supabase
    .from(table)
    .select('*')
    .eq('email', email)
    .maybeSingle();
  if (error) throw new Error(`${table}: ${error.message}`);
  return data;
}

async function insertIfMissing(table, matchColumn, matchValue, row) {
  const { data: existing, error: findError } = await supabase
    .from(table)
    .select('*')
    .eq(matchColumn, matchValue)
    .maybeSingle();
  if (findError) throw new Error(`${table}: ${findError.message}`);
  if (existing) return { row: existing, created: false };

  const { data, error } = await supabase
    .from(table)
    .insert([row])
    .select()
    .single();
  if (error) throw new Error(`${table}: ${error.message}`);
  return { row: data, created: true };
}

async function ensureOrganizer(index, passwordHash) {
  const email = organizerEmail(index);
  const existing = await findByEmail('Organizer', email);
  if (existing) return { row: existing, created: false };

  const { data, error } = await supabase
    .from('Organizer')
    .insert([{
      entity_name: `Demo Organizer ${index}`,
      email,
      password: passwordHash,
      phone_number: `05510000${String(index).padStart(2, '0')}`,
      license_num: `DEMO-LIC-${String(index).padStart(3, '0')}`,
      address: `${CITY_OPTIONS[index % CITY_OPTIONS.length]} Demo District`,
      contact_name: `Demo Contact ${index}`,
      otp_code: null,
      expired_at: null,
      verify_status: 'approved'
    }])
    .select()
    .single();
  if (error) throw new Error(`Organizer: ${error.message}`);
  return { row: data, created: true };
}

async function ensureAttendee(index, passwordHash) {
  const email = attendeeEmail(index);
  const existing = await findByEmail('Attendee', email);
  if (existing) return { row: existing, created: false };

  const { data, error } = await supabase
    .from('Attendee')
    .insert([{
      name: `Demo Attendee ${index}`,
      email,
      password: passwordHash,
      phone_number: `05520000${String(index).padStart(2, '0')}`,
      date_of_birth: `199${index % 10}-0${(index % 9) + 1}-15`,
      gender: index % 2 === 0 ? 'female' : 'male',
      city: CITY_OPTIONS[(index * 2) % CITY_OPTIONS.length],
      otp_code: null,
      expired_at: null
    }])
    .select()
    .single();
  if (error) throw new Error(`Attendee: ${error.message}`);
  return { row: data, created: true };
}

async function ensureInterests(attendee, interests) {
  const { data: existing, error: findError } = await supabase
    .from('Attendee_Interests')
    .select('*')
    .eq('attendee_id', attendee.attendee_id);
  if (findError) throw new Error(`Attendee_Interests: ${findError.message}`);

  const existingSet = new Set((existing || []).map((row) => row.interests));
  const missing = interests
    .filter((interest) => !existingSet.has(interest))
    .map((interest) => ({ attendee_id: attendee.attendee_id, interests: interest }));

  if (!missing.length) return 0;
  const { error } = await supabase.from('Attendee_Interests').insert(missing);
  if (error) throw new Error(`Attendee_Interests: ${error.message}`);
  return missing.length;
}

async function ensureEvent(template, organizer, index) {
  const [category, city, eventName, price] = template;
  const capacity = 120 + (index % 4) * 30;
  const sold = 10 + (index % 6) * 3;
  const sales = sold * price;

  return insertIfMissing('Event', 'event_name', eventName, {
    organizer_id: organizer.organizer_id,
    event_name: eventName,
    category,
    description: `${eventName} is a demo ${category.toLowerCase()} event created for Jadwal testing.`,
    location: `${city} Convention Center`,
    city,
    district: 'Demo District',
    road_name: 'Demo Road',
    start_date: '2026-08-15',
    end_date: '2026-08-15',
    time: '20:00:00',
    event_capacity: capacity,
    available_tickets: capacity - sold,
    image_url: 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
    event_status: 'approved',
    ticket_type1_name: 'General',
    ticket_type1_price: price,
    ticket_type1_capacity: capacity,
    ticket_type2_name: price >= 80 ? 'VIP' : null,
    ticket_type2_price: price >= 80 ? price + 100 : null,
    ticket_type2_capacity: price >= 80 ? 30 : null,
    ticket_sold: sold,
    sales
  });
}

async function ensureInteraction(attendeeId, eventId, interactionType, interactionValue) {
  const { data: existing, error: findError } = await supabase
    .from('Interaction')
    .select('*')
    .eq('attendee_id', attendeeId)
    .eq('event_id', eventId)
    .eq('interaction_type', interactionType)
    .maybeSingle();
  if (findError) throw new Error(`Interaction: ${findError.message}`);
  if (existing) return false;

  const { error } = await supabase
    .from('Interaction')
    .insert([{
      attendee_id: attendeeId,
      event_id: eventId,
      interaction_type: interactionType,
      interaction_value: interactionValue
    }]);
  if (error) throw new Error(`Interaction: ${error.message}`);
  return true;
}

async function ensureTicket(attendeeId, event, index) {
  const { data: existing, error: findError } = await supabase
    .from('Ticket')
    .select('*')
    .eq('attendee_id', attendeeId)
    .eq('event_id', event.event_id)
    .maybeSingle();
  if (findError) throw new Error(`Ticket: ${findError.message}`);
  if (existing) return false;

  const { error } = await supabase
    .from('Ticket')
    .insert([{
      attendee_id: attendeeId,
      event_id: event.event_id,
      tier: 'General',
      price: event.ticket_type1_price || 0,
      otp_code: String(400000 + index),
      expired_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      ticket_status: 'active',
      check_in: false
    }]);
  if (error) throw new Error(`Ticket: ${error.message}`);
  return true;
}

function preferredEvents(attendeeIndex, attendee, events) {
  const primary = CATEGORY_OPTIONS[(attendeeIndex - 1) % CATEGORY_OPTIONS.length];
  const secondary = CATEGORY_OPTIONS[(attendeeIndex + 2) % CATEGORY_OPTIONS.length];
  const preferred = events.filter((event) =>
    event.category === primary ||
    event.category === secondary ||
    event.city === attendee.city
  );
  return { primary, secondary, preferred };
}

async function main() {
  console.log('Seeding demo data into Supabase...');
  console.log(`Demo password for seeded accounts: ${DEMO_PASSWORD}`);

  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);
  const stats = {
    organizers: 0,
    attendees: 0,
    events: 0,
    interests: 0,
    likes: 0,
    views: 0,
    tickets: 0
  };

  const organizers = [];
  for (let index = 1; index <= 6; index += 1) {
    const result = await ensureOrganizer(index, passwordHash);
    organizers.push(result.row);
    if (result.created) stats.organizers += 1;
  }

  const events = [];
  for (let index = 0; index < eventTemplates.length; index += 1) {
    const organizer = organizers[index % organizers.length];
    const result = await ensureEvent(eventTemplates[index], organizer, index + 1);
    events.push(result.row);
    if (result.created) stats.events += 1;
  }

  for (let index = 1; index <= 20; index += 1) {
    const attendeeResult = await ensureAttendee(index, passwordHash);
    const attendee = attendeeResult.row;
    if (attendeeResult.created) stats.attendees += 1;

    const { primary, secondary, preferred } = preferredEvents(index, attendee, events);
    stats.interests += await ensureInterests(attendee, [primary, secondary]);

    for (let offset = 0; offset < Math.min(6, preferred.length); offset += 1) {
      const event = preferred[(index + offset) % preferred.length];
      if (offset < 2) {
        if (await ensureTicket(attendee.attendee_id, event, index * 10 + offset)) stats.tickets += 1;
      } else if (offset < 4) {
        if (await ensureInteraction(attendee.attendee_id, event.event_id, 'like', 3)) stats.likes += 1;
      } else if (await ensureInteraction(attendee.attendee_id, event.event_id, 'view', 1)) {
        stats.views += 1;
      }
    }
  }

  console.log('Demo data seed complete.');
  console.table(stats);
  console.log('Example attendee login: demo.attendee01@jadwal.test / Jadwal123');
  console.log('Example organizer login: demo.organizer01@jadwal.test / Jadwal123');
  console.log('Next recommended command: npm run reco:train');
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
