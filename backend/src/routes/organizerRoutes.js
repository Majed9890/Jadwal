const express = require('express');
const router = express.Router();
const { getOrganizerProfile, editOrganizerProfile } = require('../controllers/eventController');
const { verifyToken } = require('../middleware/authMiddleware');

router.get('/profile', verifyToken, getOrganizerProfile);
router.put('/edit-profile', verifyToken, editOrganizerProfile);

module.exports = router;