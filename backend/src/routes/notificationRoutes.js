const express = require('express');
const router = express.Router();
const { getNotifications } = require('../controllers/notificationController');
const { verifyToken } = require('../middleware/authMiddleware');

// get notifications for organizer
router.get('/', verifyToken, getNotifications);

module.exports = router;