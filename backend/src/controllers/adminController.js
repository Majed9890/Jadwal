const supabase = require('../config/supabase');
const { sendNotification } = require('./notificationController');

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

    if (status === 'approved') {
        await sendNotification(organizer_id, 'Your organizer account has been approved. You can now create events.');
    } else if (status === 'rejected') {
        await sendNotification(organizer_id, 'Your organizer account registration has been rejected.');
    }

    res.json({ message: `organizer ${status}`, organizer: data });
};

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

    if (data && data.organizer_id) {
        if (status === 'approved') {
            await sendNotification(data.organizer_id, `Your event "${data.event_name}" has been approved and is now live.`);
        } else if (status === 'rejected') {
            await sendNotification(data.organizer_id, `Your event "${data.event_name}" has been rejected.`);
        }
    }

    res.json({ message: `event ${status}`, event: data });
};

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