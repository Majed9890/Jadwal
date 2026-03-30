const jwt = require('jsonwebtoken');

// this middleware checks if the user is logged in
const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];

    if (!authHeader) {
        return res.status(401).json({ error: 'no token provided' });
    }

    // the token comes as "Bearer <token>"
    const token = authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'token missing' });
    }

    // verify the token
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'invalid token' });
        }

        // attach user info to the request
        req.user = decoded;
        next();
    });
};

module.exports = { verifyToken };