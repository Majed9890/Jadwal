const express = require('express');
const router = express.Router();
const { purchaseTicket, viewTickets, viewQRCode, refreshOTP, checkInTicket } = require('../controllers/ticketController');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/purchase', verifyToken, purchaseTicket);
router.get('/my-tickets', verifyToken, viewTickets);
router.post('/qr-code', verifyToken, viewQRCode);
router.post('/refresh-otp', verifyToken, refreshOTP);
router.post('/checkin', verifyToken, checkInTicket);

module.exports = router;