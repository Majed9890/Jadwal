const express = require('express');
const router = express.Router();
const { getPendingOrganizers, updateOrganizerStatus, getPendingEvents, updateEventStatus, getGlobalAnalytics } = require('../controllers/adminController');
const { verifyToken } = require('../middleware/authMiddleware');

// organizer management
router.get('/organizers/pending', verifyToken, getPendingOrganizers);
router.put('/organizers/status', verifyToken, updateOrganizerStatus);

// event management
router.get('/events/pending', verifyToken, getPendingEvents);
router.put('/events/status', verifyToken, updateEventStatus);

// analytics
router.get('/analytics', verifyToken, getGlobalAnalytics);

module.exports = router;