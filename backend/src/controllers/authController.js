const supabase = require('../config/supabase');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const { isValidCity } = require('../constants/options');

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
        subject: 'Jadwal - Verify Your Account',
        text: `Your OTP code is: ${otp}. It expires in 10 minutes.`
    });
};

// this function makes a random 6 digit code for OTP
function generateOTP() {
    const otp = Math.floor(100000 + Math.random() * 900000);
    return otp.toString();
}

// register a new attendee
const registerAttendee = async (req, res) => {
    const { name, email, password, phone_number, date_of_birth, gender, city } = req.body;

    if (!isValidCity(city)) {
        return res.status(400).json({ error: 'please select a valid city' });
    }

    const { data: existingUser } = await supabase
        .from('Attendee')
        .select('email')
        .eq('email', email)
        .maybeSingle();

    if (existingUser) {
        return res.status(400).json({ error: 'this email is already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOTP();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 10);

    const { data, error } = await supabase
        .from('Attendee')
        .insert([{
            name: name,
            email: email,
            password: hashedPassword,
            phone_number: phone_number,
            date_of_birth: date_of_birth,
            gender: gender,
            city: city,
            otp_code: otp,
            expired_at: expiry
        }])
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    await sendOTPEmail(email, otp);

    res.status(201).json({ message: 'registered successfully, check your email for OTP' });
};

// register a new organizer
const registerOrganizer = async (req, res) => {
    const { entity_name, email, password, phone_number, license_num, address, contact_name } = req.body;

    const { data: existingUser } = await supabase
        .from('Organizer')
        .select('email')
        .eq('email', email)
        .maybeSingle();

    if (existingUser) {
        return res.status(400).json({ error: 'this email is already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOTP();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 10);

    const { data, error } = await supabase
        .from('Organizer')
        .insert([{
            entity_name: entity_name,
            email: email,
            password: hashedPassword,
            phone_number: phone_number,
            license_num: license_num,
            address: address,
            contact_name: contact_name,
            otp_code: otp,
            expired_at: expiry,
            verify_status: 'pending'
        }])
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    await sendOTPEmail(email, otp);

    res.status(201).json({ message: 'organizer registered, check your email for OTP' });
};

// verify the otp code
const verifyOTP = async (req, res) => {
    const { email, otp_code, role } = req.body;

    let tableName = 'Attendee';
    if (role === 'organizer') {
        tableName = 'Organizer';
    }

    const { data: user } = await supabase
        .from(tableName)
        .select('*')
        .eq('email', email)
        .maybeSingle();

    if (!user) {
        return res.status(404).json({ error: 'user not found' });
    }

    if (user.otp_code !== otp_code) {
        return res.status(400).json({ error: 'wrong OTP' });
    }

    const now = new Date();
    const expiry = new Date(user.expired_at);
    if (now > expiry) {
        return res.status(400).json({ error: 'OTP has expired' });
    }

    let idField = 'attendee_id';
    if (role === 'organizer') {
        idField = 'organizer_id';
    }

    await supabase
        .from(tableName)
        .update({ otp_code: null, expired_at: null })
        .eq(idField, user[idField]);

    res.json({ message: 'OTP verified successfully' });
};

// login for all roles
const login = async (req, res) => {
    const { email, password, role } = req.body;

    let tableName = '';
    let idField = '';

    if (role === 'attendee') {
        tableName = 'Attendee';
        idField = 'attendee_id';
    } else if (role === 'organizer') {
        tableName = 'Organizer';
        idField = 'organizer_id';
    } else if (role === 'admin') {
        tableName = 'Admin';
        idField = 'admin_id';
    } else {
        return res.status(400).json({ error: 'invalid role' });
    }

    const { data: user } = await supabase
        .from(tableName)
        .select('*')
        .eq('email', email)
        .maybeSingle();

    if (!user) {
        return res.status(404).json({ error: 'user not found' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
        return res.status(401).json({ error: 'wrong password' });
    }

    const token = jwt.sign(
        { id: user[idField], email: user.email, role: role },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
    );

    res.json({ message: 'login successful', token: token, role: role });
};

module.exports = { registerAttendee, registerOrganizer, verifyOTP, login };
