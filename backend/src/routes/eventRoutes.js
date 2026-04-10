const express = require('express');
const router = express.Router();
const { createEvent, getOrganizerEvents, getOrganizerDashboard, searchEvents, filterEvents } = require('../controllers/eventController');
const { verifyToken } = require('../middleware/authMiddleware');

// organizer routes
router.post('/create', verifyToken, createEvent);
router.get('/my-events', verifyToken, getOrganizerEvents);
router.get('/dashboard', verifyToken, getOrganizerDashboard);

// attendee routes
router.get('/search', verifyToken, searchEvents);
router.get('/filter', verifyToken, filterEvents);

module.exports = router;