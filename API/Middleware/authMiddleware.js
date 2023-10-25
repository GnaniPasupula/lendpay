require('dotenv').config();
const jwt = require('jsonwebtoken');

function authenticateUser(req, res, next) {
  const token = req.headers.authorization && req.headers.authorization.split(' ')[1]; // Get token from the "Authorization" header

  if (token) {
    try {
      const decodedToken = jwt.verify(token, process.env.SECRET_KEY);
      // console.log("Decoded token:", decodedToken);
      req.user = decodedToken;
      next();
    } catch (error) {
      res.status(401).json({ message: 'Unauthorized Token is invalid/expired' }); // Token is invalid/expired
    }
  } else {
    res.status(401).json({ message: 'Unauthorized Token is missing' }); // Token is missing
  }
}

module.exports = {
  authenticateUser,
};

  