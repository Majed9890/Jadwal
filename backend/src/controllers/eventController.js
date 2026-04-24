const supabase = require('../config/supabase');

const createEvent = async (req, res) => {
    const {
        event_name, category, description, location, city, district, road_name,
        start_date, end_date, time, event_capacity, image_url,
        ticket_type1_name, ticket_type1_price, ticket_type1_capacity,
        ticket_type2_name, ticket_type2_price, ticket_type2_capacity
    } = req.body;

    const { data, error } = await supabase
        .from('Event')
        .insert([{
            organizer_id: req.user.id,
            event_name: event_name,
            category: category,
            description: description,
            location: location,
            city: city,
            district: district,
            road_name: road_name,
            start_date: start_date,
            end_date: end_date,
            time: time,
            event_capacity: event_capacity,
            available_tickets: event_capacity,
            image_url: image_url,
            event_status: 'pending',
            ticket_type1_name: ticket_type1_name || null,
            ticket_type1_price: ticket_type1_price || null,
            ticket_type1_capacity: ticket_type1_capacity || null,
            ticket_type2_name: ticket_type2_name || null,
            ticket_type2_price: ticket_type2_price || null,
            ticket_type2_capacity: ticket_type2_capacity || null
        }])
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.status(201).json({ message: 'event created and waiting for admin approval', event: data });
};

const getOrganizerEvents = async (req, res) => {
    const { data, error } = await supabase
        .from('Event')
        .select('*')
        .eq('organizer_id', req.user.id);

    if (error) return res.status(500).json({ error: error.message });

    res.json({ events: data });
};

const getOrganizerDashboard = async (req, res) => {
    const { event_id } = req.query;

    let query = supabase
        .from('Event')
        .select('event_name, ticket_sold, sales, event_capacity, available_tickets, event_status')
        .eq('organizer_id', req.user.id);

    if (event_id) {
        query = query.eq('event_id', event_id);
    }

    const { data, error } = await query;

    if (error) return res.status(500).json({ error: error.message });

    res.json({ dashboard: data });
};

const getOrganizerProfile = async (req, res) => {
    const organizer_id = req.user.id;

    const { data, error } = await supabase
        .from('Organizer')
        .select('entity_name, phone_number, address, contact_name, email')
        .eq('organizer_id', organizer_id)
        .single();

    if (error) return res.status(500).json({ error: error.message });

    res.json({ organizer: data });
};

const editOrganizerProfile = async (req, res) => {
    const organizer_id = req.user.id;
    const { entity_name, phone_number, address, contact_name } = req.body;

    const { data, error } = await supabase
        .from('Organizer')
        .update({
            entity_name: entity_name,
            phone_number: phone_number,
            address: address,
            contact_name: contact_name
        })
        .eq('organizer_id', organizer_id)
        .select()
        .single();

    if (error) return res.status(500).json({ error: error.message });

    res.json({ message: 'profile updated', organizer: data });
};

const searchEvents = async (req, res) => {
    const { keyword } = req.query;

    const { data, error } = await supabase
        .from('Event')
        .select('*')
        .eq('event_status', 'approved')
        .ilike('event_name', `%${keyword}%`);

    if (error) return res.status(500).json({ error: error.message });

    res.json({ events: data });
};

const filterEvents = async (req, res) => {
    const { category, city, min_price, max_price } = req.query;

    let query = supabase
        .from('Event')
        .select('*')
        .eq('event_status', 'approved');

    if (category) query = query.eq('category', category);
    if (city) query = query.eq('city', city);
    if (min_price) query = query.gte('ticket_type1_price', min_price);
    if (max_price) query = query.lte('ticket_type1_price', max_price);

    const { data, error } = await query;

    if (error) return res.status(500).json({ error: error.message });

    res.json({ events: data });
};

module.exports = { createEvent, getOrganizerEvents, getOrganizerDashboard, getOrganizerProfile, editOrganizerProfile, searchEvents, filterEvents };