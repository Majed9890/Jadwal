const supabase = require('../config/supabase');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// this function makes a random 6 digit code for OTP
function generateOTP() {
    const otp = Math.floor(100000 + Math.random() * 900000);
    return otp.toString();
}

// register a new attendee
const registerAttendee = async (req, res) => {
    const { name, email, password, phone_number, date_of_birth, gender, city } = req.body;

    // check if the email is already used
    const { data: existingUser } = await supabase
        .from('Attendee')
        .select('email')
        .eq('email', email)
        .single();

    if (existingUser) {
        return res.status(400).json({ error: 'this email is already registered' });
    }

    // hash the password before saving
    const hashedPassword = await bcrypt.hash(password, 10);

    // generate otp and set expiry to 10 minutes
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

    // for now we return the otp in the response for testing
    res.status(201).json({ message: 'registered successfully', otp: otp });
};

// register a new organizer
const registerOrganizer = async (req, res) => {
    const { entity_name, email, password, phone_number, license_num, address, contact_name } = req.body;

    const { data: existingUser } = await supabase
        .from('Organizer')
        .select('email')
        .eq('email', email)
        .single();

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

    res.status(201).json({ message: 'organizer registered, waiting for admin approval', otp: otp });
};

// verify the otp code
const verifyOTP = async (req, res) => {
    const { email, otp_code, role } = req.body;

    // decide which table to use based on role
    let tableName = 'Attendee';
    if (role === 'organizer') {
        tableName = 'Organizer';
    }

    const { data: user } = await supabase
        .from(tableName)
        .select('*')
        .eq('email', email)
        .single();

    if (!user) {
        return res.status(404).json({ error: 'user not found' });
    }

    // check if otp matches
    if (user.otp_code !== otp_code) {
        return res.status(400).json({ error: 'wrong OTP' });
    }

    // check if otp is expired
    const now = new Date();
    const expiry = new Date(user.expired_at);
    if (now > expiry) {
        return res.status(400).json({ error: 'OTP has expired' });
    }

    // clear the otp after verification
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

    // pick the right table
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
        .single();

    if (!user) {
        return res.status(404).json({ error: 'user not found' });
    }

    // compare the password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
        return res.status(401).json({ error: 'wrong password' });
    }

    // create a token
    const token = jwt.sign(
        { id: user[idField], email: user.email, role: role },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
    );

    res.json({ message: 'login successful', token: token, role: role });
};

module.exports = { registerAttendee, registerOrganizer, verifyOTP, login };