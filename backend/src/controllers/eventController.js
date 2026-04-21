const supabase = require('../config/supabase');

const createEvent = async (req, res) => {
    const { event_name, category, description, location, city, district, road_name, start_date, end_date, time, base_price, event_capacity, image_url } = req.body;

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
            base_price: base_price,
            event_capacity: event_capacity,
            available_tickets: event_capacity,
            image_url: image_url,
            event_status: 'pending'
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
    const { data, error } = await supabase
        .from('Event')
        .select('event_name, ticket_sold, sales, event_capacity, available_tickets')
        .eq('organizer_id', req.user.id);

    if (error) return res.status(500).json({ error: error.message });

    res.json({ dashboard: data });
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
    if (min_price) query = query.gte('base_price', min_price);
    if (max_price) query = query.lte('base_price', max_price);

    const { data, error } = await query;

    if (error) return res.status(500).json({ error: error.message });

    res.json({ events: data });
};

module.exports = { createEvent, getOrganizerEvents, getOrganizerDashboard, searchEvents, filterEvents };