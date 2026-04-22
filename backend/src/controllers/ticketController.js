const supabase = require('../config/supabase');
const QRCode = require('qrcode');
const nodemailer = require('nodemailer');

// email transporter
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// send otp via email
const sendOTPEmail = async (email, otp) => {
    await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Jadwal - Your OTP Code',
        text: `Your OTP code is: ${otp}. It expires in 2 minutes.`
    });
};

// purchase ticket
const purchaseTicket = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id, tier, quantity } = req.body;

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

    const price = event.base_price * quantity;

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 2);

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

    await supabase
        .from('Event')
        .update({ available_tickets: event.available_tickets - quantity })
        .eq('event_id', event_id);

    const { data: attendee } = await supabase
        .from('Attendee')
        .select('email')
        .eq('attendee_id', attendee_id)
        .single();

    if (attendee) {
        await sendOTPEmail(attendee.email, otp);
    }

    res.status(201).json({ message: 'ticket purchased successfully', ticket: ticket });
};

// view my tickets
const viewTickets = async (req, res) => {
    const attendee_id = req.user.id;

    const { data, error } = await supabase
        .from('Ticket')
        .select('*, Event(event_name)')
        .eq('attendee_id', attendee_id);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ tickets: data });
};

// refresh otp when ticket is clicked
const refreshOTP = async (req, res) => {
    const { ticket_id } = req.body;
    const attendee_id = req.user.id;

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 2);

    const { data: ticket, error } = await supabase
        .from('Ticket')
        .update({ otp_code: otp, expired_at: expiry })
        .eq('ticket_id', ticket_id)
        .eq('attendee_id', attendee_id)
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    const { data: attendee } = await supabase
        .from('Attendee')
        .select('email')
        .eq('attendee_id', attendee_id)
        .single();

    if (attendee) {
        await sendOTPEmail(attendee.email, otp);
    }

    res.json({ message: 'otp sent to your email' });
};

// view qr code
const viewQRCode = async (req, res) => {
    const { ticket_id, otp_code } = req.body;
    const attendee_id = req.user.id;

    const { data: ticket, error } = await supabase
        .from('Ticket')
        .select('*')
        .eq('ticket_id', ticket_id)
        .eq('attendee_id', attendee_id)
        .single();

    if (error || !ticket) {
        return res.status(404).json({ error: 'ticket not found' });
    }

    if (ticket.otp_code !== otp_code) {
        return res.status(400).json({ error: 'wrong otp' });
    }

    const now = new Date();
    const expiry = new Date(ticket.expired_at);
    if (now > expiry) {
        return res.status(400).json({ error: 'otp has expired' });
    }

    const timestamp = new Date().toISOString();

    // save timestamp to ticket
    await supabase
        .from('Ticket')
        .update({ qr_timestamp: timestamp })
        .eq('ticket_id', ticket_id);

    const qrData = JSON.stringify({
        ticket_id: ticket.ticket_id,
        event_id: ticket.event_id,
        attendee_id: ticket.attendee_id,
        timestamp: timestamp
    });

    const qrCode = await QRCode.toDataURL(qrData);

    res.json({ message: 'qr code generated', qr_code: qrCode, timestamp: timestamp });
};

module.exports = { purchaseTicket, viewTickets, viewQRCode, refreshOTP };