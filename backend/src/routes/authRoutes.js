const express = require('express');
const router = express.Router();

const { registerAttendee, registerOrganizer, verifyOTP, login } = require('../controllers/authController');

// attendee registration
router.post('/register/attendee', registerAttendee);

// organizer registration
router.post('/register/organizer', registerOrganizer);

// verify otp for both attendee and organizer
router.post('/verify-otp', verifyOTP);

// login for all roles
router.post('/login', login);

module.exports = router;