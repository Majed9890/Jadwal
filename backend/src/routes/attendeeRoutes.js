const express = require('express');
const router = express.Router();
const { editProfile, updateInterests, likeEvent, getProfile, checkLike } = require('../controllers/attendeeController');
const { verifyToken } = require('../middleware/authMiddleware');

// attendee routes
router.get('/profile', verifyToken, getProfile);
router.put('/edit-profile', verifyToken, editProfile);
router.put('/update-interests', verifyToken, updateInterests);
router.post('/like-event', verifyToken, likeEvent);
router.get('/check-like/:event_id', verifyToken, checkLike);

module.exports = router;