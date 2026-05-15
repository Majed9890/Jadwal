const express = require('express');
const router = express.Router();
const { createEvent, getOrganizerEvents, getOrganizerDashboard, searchEvents, filterEvents, getRecommendedEvents, getEventStats, getEventGenderStats } = require('../controllers/eventController');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/create', verifyToken, createEvent);
router.get('/my-events', verifyToken, getOrganizerEvents);
router.get('/dashboard', verifyToken, getOrganizerDashboard);
router.get('/recommended', verifyToken, getRecommendedEvents);
router.get('/search', verifyToken, searchEvents);
router.get('/filter', verifyToken, filterEvents);
router.get('/stats/:event_id', verifyToken, getEventStats);
router.get('/gender-stats/:event_id', verifyToken, getEventGenderStats);

module.exports = router;
