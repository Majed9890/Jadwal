const supabase = require('../config/supabase');

// create event
const createEvent = async (req, res) => {
    const { event_name, category, description, location, city, start_date, end_date, time, base_price, event_capacity, image_url } = req.body;

    const { data, error } = await supabase
        .from('Event')
        .insert([{
            organizer_id: req.user.id,
            event_name: event_name,
            category: category,
            description: description,
            location: location,
            city: city,
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

// get organizer events
const getOrganizerEvents = async (req, res) => {
    const { data, error } = await supabase
        .from('Event')
        .select('*')
        .eq('organizer_id', req.user.id);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ events: data });
};

// organizer dashboard
const getOrganizerDashboard = async (req, res) => {
    const { data, error } = await supabase
        .from('Event')
        .select('event_name, ticket_sold, sales, event_capacity, available_tickets')
        .eq('organizer_id', req.user.id);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ dashboard: data });
};

module.exports = { createEvent, getOrganizerEvents, getOrganizerDashboard };