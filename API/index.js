require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRouter = require('./routes/auth');
const lendPay = require('./routes/lendPay');
const { authenticateUser } = require('./Middleware/authMiddleware'); 

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log('Connected to MongoDB');
  startServer();
}).catch((err) => {
  console.error('Error connecting to MongoDB', err);
});

function startServer() {
  const app = express();

  app.use(express.json());

  app.use(cors());

  app.use('/auth', authRouter);
  app.use('/lendPay', authenticateUser, lendPay); 

  app.get('/', (req, res) => {
    res.redirect('/lendPay/dashboard');
  });

  const PORT = process.env.PORT || 3000;

  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}