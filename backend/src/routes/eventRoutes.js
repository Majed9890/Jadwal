const express = require('express');
const router = express.Router();
const { createEvent, getOrganizerEvents, getOrganizerDashboard } = require('../controllers/eventController');
const { verifyToken } = require('../middleware/authMiddleware');

// organizer routes
router.post('/create', verifyToken, createEvent);
router.get('/my-events', verifyToken, getOrganizerEvents);
router.get('/dashboard', verifyToken, getOrganizerDashboard);

module.exports = router;