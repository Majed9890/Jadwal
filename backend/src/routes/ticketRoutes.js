const express = require('express');
const router = express.Router();
const { purchaseTicket, viewTickets, viewQRCode } = require('../controllers/ticketController');
const { verifyToken } = require('../middleware/authMiddleware');

// ticket routes
router.post('/purchase', verifyToken, purchaseTicket);
router.get('/my-tickets', verifyToken, viewTickets);
router.post('/qr-code', verifyToken, viewQRCode);

module.exports = router;