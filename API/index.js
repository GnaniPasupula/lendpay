require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const authRouter = require('./routes/auth');
const lendPay = require('./routes/lendPay');
const { authenticateUser } = require('./Middleware/authMiddleware');
const { sendFcmMessage } = require('./fcmService');
const socketIo = require('socket.io');

let pendingIncomingRequests = {};
let pendingIncomingPaymentRequests = {};
let userSocketMapping={};
let io;

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
  io = socketIo(server); 

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

  io.on('connection', (socket) => {
    console.log('New client connected');

    socket.on('joinRoom', (roomID) => {
      socket.join(roomID);
      userSocketMapping[roomID] = socket.id;
      processPendingIncomingRequests(roomID);
    });

    socket.on('transactionRequest', (data) => {
      console.log('Server: Transaction request received:', data);

      const roomID = data.receiverEmail;

      if (userSocketMapping[roomID]!=null) {
        io.to(roomID).emit('transactionRequest', data);
      } else {
        console.log(`Client with roomID ${roomID} is offline. Saving the loan request for later.`);
        if (!pendingIncomingRequests[roomID]) {
          pendingIncomingRequests[roomID] = [];
        }
        pendingIncomingRequests[roomID].push(data);
      }
    });

    socket.on('transactionPaymentRequest', (data) => {
      console.log('Server: Payment request received:', data);

      const roomID = data.receiverEmail;

      if (userSocketMapping[roomID]!=null) {
        io.to(roomID).emit('transactionPaymentRequest', data);
      } else {
        console.log(`Client with roomID ${roomID} is offline. Saving the payment request for later.`);
        if (!pendingIncomingPaymentRequests[roomID]) {
          pendingIncomingPaymentRequests[roomID] = [];
        }
        pendingIncomingPaymentRequests[roomID].push(data);
      }
    });

    socket.on('disconnect', () => {
      console.log('Client disconnected');

      const disconnectedSocketId = socket.id;
      for (const roomID in userSocketMapping) {
          if (userSocketMapping[roomID] === disconnectedSocketId) {
              delete userSocketMapping[roomID];
              console.log(`Removed socket.id ${disconnectedSocketId} from userSocketMapping`);
              break; 
          }
      }
    });
  });

  const PORT = process.env.PORT || 3000;

  server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}

function processPendingIncomingRequests(roomID) {
  if (pendingIncomingRequests[roomID]) {
    const requests = pendingIncomingRequests[roomID];
    requests.forEach((request) => {
      io.to(roomID).emit('transactionRequest', request);
    });
    delete pendingIncomingRequests[roomID];
  }
}
