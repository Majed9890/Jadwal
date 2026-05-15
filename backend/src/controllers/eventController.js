const supabase = require('../config/supabase');
const { recommendWithLightFM } = require('../../scripts/lightfmRecommendations');
const { recommendWithNodeFallback } = require('../../scripts/nodeRecommendationFallback');
const { isValidCategory, isValidCity } = require('../constants/options');

const createEvent = async (req, res) => {
    const { event_name, category, description, location, city, district, road_name, start_date, end_date, time, event_capacity, image_url, ticket_type1_name, ticket_type1_price, ticket_type1_capacity, ticket_type2_name, ticket_type2_price, ticket_type2_capacity } = req.body;

    if (!isValidCategory(category)) {
        return res.status(400).json({ error: 'please select a valid category' });
    }
    if (!isValidCity(city)) {
        return res.status(400).json({ error: 'please select a valid city' });
    }

    const { data, error } = await supabase.from('Event').insert([{
        organizer_id: req.user.id, event_name, category, description, location, city, district, road_name, start_date, end_date, time, event_capacity, available_tickets: event_capacity, image_url, event_status: 'pending',
        ticket_type1_name: ticket_type1_name || null, ticket_type1_price: ticket_type1_price || null, ticket_type1_capacity: ticket_type1_capacity || null,
        ticket_type2_name: ticket_type2_name || null, ticket_type2_price: ticket_type2_price || null, ticket_type2_capacity: ticket_type2_capacity || null
    }]).select().single();

    if (error) return res.status(500).json({ error: error.message });
    res.status(201).json({ message: 'event created and waiting for admin approval', event: data });
};

const getOrganizerEvents = async (req, res) => {
    const { data, error } = await supabase.from('Event').select('*').eq('organizer_id', req.user.id);
    if (error) return res.status(500).json({ error: error.message });
    res.json({ events: data });
};

const getOrganizerDashboard = async (req, res) => {
    const { event_id } = req.query;
    let query = supabase.from('Event').select('event_name, ticket_sold, sales, event_capacity, available_tickets, event_status').eq('organizer_id', req.user.id);
    if (event_id) query = query.eq('event_id', event_id);
    const { data, error } = await query;
    if (error) return res.status(500).json({ error: error.message });
    res.json({ dashboard: data });
};

const getOrganizerProfile = async (req, res) => {
    const { data, error } = await supabase.from('Organizer').select('entity_name, phone_number, address, contact_name, email').eq('organizer_id', req.user.id).single();
    if (error) return res.status(500).json({ error: error.message });
    res.json({ organizer: data });
};

const editOrganizerProfile = async (req, res) => {
    const { entity_name, phone_number, address, contact_name } = req.body;
    const { data, error } = await supabase.from('Organizer').update({ entity_name, phone_number, address, contact_name }).eq('organizer_id', req.user.id).select().single();
    if (error) return res.status(500).json({ error: error.message });
    res.json({ message: 'profile updated', organizer: data });
};

const searchEvents = async (req, res) => {
    const { keyword } = req.query;
    const { data, error } = await supabase.from('Event').select('*').eq('event_status', 'approved').ilike('event_name', `%${keyword}%`);
    if (error) return res.status(500).json({ error: error.message });
    res.json({ events: data });
};

const filterEvents = async (req, res) => {
    const { category, city, min_price, max_price } = req.query;
    let query = supabase.from('Event').select('*').eq('event_status', 'approved');
    if (category) query = query.eq('category', category);
    if (city) query = query.eq('city', city);
    if (min_price) query = query.gte('ticket_type1_price', min_price);
    if (max_price) query = query.lte('ticket_type1_price', max_price);
    const { data, error } = await query;
    if (error) return res.status(500).json({ error: error.message });
    res.json({ events: data });
};

const getRecommendedEvents = async (req, res) => {
    const attendee_id = req.user.id;
    const limit = req.query.limit ? Number(req.query.limit) : undefined;

    try {
        const result = recommendWithLightFM(attendee_id, limit);
        return res.json(result);
    } catch (lightfmError) {
        try {
            const fallback = await recommendWithNodeFallback(attendee_id, limit);
            return res.json({
                ...fallback,
                source: 'fallback',
                warning: lightfmError.message
            });
        } catch (fallbackError) {
            return res.status(500).json({ error: fallbackError.message });
        }
    }
};

const getEventStats = async (req, res) => {
    const { event_id } = req.params;
    const organizer_id = req.user.id;

    const { data: event, error: eventError } = await supabase
        .from('Event')
        .select('*')
        .eq('event_id', event_id)
        .eq('organizer_id', organizer_id)
        .single();

    if (eventError || !event) return res.status(404).json({ error: 'event not found' });

    const { data: tickets, error: ticketError } = await supabase
        .from('Ticket')
        .select('tier, price')
        .eq('event_id', event_id);

    if (ticketError) return res.status(500).json({ error: ticketError.message });

    const tierStats = {};
    tickets.forEach(ticket => {
        if (!tierStats[ticket.tier]) {
            tierStats[ticket.tier] = { count: 0, revenue: 0 };
        }
        tierStats[ticket.tier].count += 1;
        tierStats[ticket.tier].revenue += ticket.price;
    });

    const capacityStats = {
        total_capacity: event.event_capacity,
        tickets_sold: event.ticket_sold || 0,
        available_tickets: event.available_tickets || 0,
        total_sales: event.sales || 0
    };

    const revenuePerTier = Object.keys(tierStats).map(tier => ({
        tier,
        count: tierStats[tier].count,
        revenue: tierStats[tier].revenue
    }));

    res.json({
        event_name: event.event_name,
        capacity_stats: capacityStats,
        tier_stats: revenuePerTier
    });
};

const getEventGenderStats = async (req, res) => {
    const { event_id } = req.params;
    const organizer_id = req.user.id;

    const { data: event, error: eventError } = await supabase
        .from('Event')
        .select('event_id, event_name, organizer_id')
        .eq('event_id', event_id)
        .eq('organizer_id', organizer_id)
        .single();

    if (eventError || !event) return res.status(404).json({ error: 'event not found' });

    const { data: tickets, error: ticketError } = await supabase
        .from('Ticket')
        .select('attendee_id, Attendee(gender)')
        .eq('event_id', event_id);

    if (ticketError) return res.status(500).json({ error: ticketError.message });

    let male = 0;
    let female = 0;

    tickets.forEach(ticket => {
        const gender = ticket.Attendee?.gender;
        if (gender === 'male') male += 1;
        else if (gender === 'female') female += 1;
    });

    res.json({
        event_name: event.event_name,
        male,
        female,
        total: male + female
    });
};

module.exports = { createEvent, getOrganizerEvents, getOrganizerDashboard, getOrganizerProfile, editOrganizerProfile, searchEvents, filterEvents, getRecommendedEvents, getEventStats, getEventGenderStats };
