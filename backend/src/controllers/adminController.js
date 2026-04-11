const supabase = require('../config/supabase');

// get all pending organizers
const getPendingOrganizers = async (req, res) => {
    const { data, error } = await supabase
        .from('Organizer')
        .select('*')
        .eq('verify_status', 'pending');

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ organizers: data });
};

// approve or reject organizer
const updateOrganizerStatus = async (req, res) => {
    const { organizer_id, status } = req.body;

    const { data, error } = await supabase
        .from('Organizer')
        .update({ verify_status: status })
        .eq('organizer_id', organizer_id)
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ message: `organizer ${status}`, organizer: data });
};

// get all pending events
const getPendingEvents = async (req, res) => {
    const { data, error } = await supabase
        .from('Event')
        .select('*')
        .eq('event_status', 'pending');

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ events: data });
};

// approve or reject event
const updateEventStatus = async (req, res) => {
    const { event_id, status } = req.body;

    const { data, error } = await supabase
        .from('Event')
        .update({ event_status: status })
        .eq('event_id', event_id)
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ message: `event ${status}`, event: data });
};
// global analytics
const getGlobalAnalytics = async (req, res) => {
    const { data: attendees, error: attendeeError } = await supabase
        .from('Attendee')
        .select('attendee_id');

    const { data: organizers, error: organizerError } = await supabase
        .from('Organizer')
        .select('organizer_id');

    const { data: tickets, error: ticketError } = await supabase
        .from('Ticket')
        .select('price');

    if (attendeeError || organizerError || ticketError) {
        return res.status(500).json({ error: 'error fetching analytics' });
    }

    const totalRevenue = tickets.reduce((sum, ticket) => sum + ticket.price, 0);

    res.json({
        total_attendees: attendees.length,
        total_organizers: organizers.length,
        total_tickets_sold: tickets.length,
        total_revenue: totalRevenue
    });
};

module.exports = { getPendingOrganizers, updateOrganizerStatus, getPendingEvents, updateEventStatus, getGlobalAnalytics };