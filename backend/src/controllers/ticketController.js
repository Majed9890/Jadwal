const supabase = require('../config/supabase');
const QRCode = require('qrcode');

// purchase ticket
const purchaseTicket = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id, tier, quantity } = req.body;

    // check if tickets are available
    const { data: event, error: eventError } = await supabase
        .from('Event')
        .select('available_tickets, base_price')
        .eq('event_id', event_id)
        .single();

    if (eventError) {
        return res.status(500).json({ error: eventError.message });
    }

    if (event.available_tickets < quantity) {
        return res.status(400).json({ error: 'not enough tickets available' });
    }

    // calculate price
    const price = event.base_price * quantity;

    // generate otp for qr code access
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 10);

    // create ticket
    const { data: ticket, error: ticketError } = await supabase
        .from('Ticket')
        .insert([{
            attendee_id: attendee_id,
            event_id: event_id,
            tier: tier,
            price: price,
            otp_code: otp,
            expired_at: expiry,
            ticket_status: 'active'
        }])
        .select()
        .single();

    if (ticketError) {
        return res.status(500).json({ error: ticketError.message });
    }

    // subtract available tickets
    await supabase
        .from('Event')
        .update({ available_tickets: event.available_tickets - quantity })
        .eq('event_id', event_id);

    res.status(201).json({ message: 'ticket purchased successfully', ticket: ticket, otp: otp });
};

// view my tickets
const viewTickets = async (req, res) => {
    const attendee_id = req.user.id;

    const { data, error } = await supabase
        .from('Ticket')
        .select('*')
        .eq('attendee_id', attendee_id);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ tickets: data });
};

// view qr code
const viewQRCode = async (req, res) => {
    const { ticket_id, otp_code } = req.body;
    const attendee_id = req.user.id;

    // get the ticket
    const { data: ticket, error } = await supabase
        .from('Ticket')
        .select('*')
        .eq('ticket_id', ticket_id)
        .eq('attendee_id', attendee_id)
        .single();

    if (error || !ticket) {
        return res.status(404).json({ error: 'ticket not found' });
    }

    // check otp
    if (ticket.otp_code !== otp_code) {
        return res.status(400).json({ error: 'wrong otp' });
    }

    // check otp expiry
    const now = new Date();
    const expiry = new Date(ticket.expired_at);
    if (now > expiry) {
        return res.status(400).json({ error: 'otp has expired' });
    }

    // generate qr code with timestamp
    const qrData = JSON.stringify({
        ticket_id: ticket.ticket_id,
        event_id: ticket.event_id,
        attendee_id: ticket.attendee_id,
        timestamp: new Date().toISOString()
    });

    const qrCode = await QRCode.toDataURL(qrData);

    res.json({ message: 'qr code generated', qr_code: qrCode });
};

module.exports = { purchaseTicket, viewTickets, viewQRCode };