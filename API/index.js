require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const authRouter = require('./routes/auth');
const lendPay = require('./routes/lendPay');
const { authenticateUser } = require('./Middleware/authMiddleware');
const { sendFcmMessage } = require('./fcmService');

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
  const server = http.createServer(app);
  // const io = socketIO(server);

  app.use(express.json());
  app.use(cors());

  app.use('/auth', authRouter);
  app.use('/lendPay', authenticateUser, lendPay);

  app.get('/', (req, res) => {
    res.redirect('/lendPay/dashboard');
  });

  app.post('/send-notification', async (req, res) => {
    const { receiverToken, title, body } = req.body;

    try {
      await sendFcmMessage({ receiverToken, title, body });
      console.log('Notification sent successfully');
      res.status(200).send('FCM message sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
      res.status(500).send('Error sending notification');
    }
  });

  const PORT = process.env.PORT || 3000;

  server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}
