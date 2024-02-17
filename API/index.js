require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const socketIO = require('socket.io');
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
  const server = http.createServer(app);
  // const io = socketIO(server);

  app.use(express.json());
  app.use(cors());

  app.use('/auth', authRouter);
  app.use('/lendPay', authenticateUser, lendPay);

  app.get('/', (req, res) => {
    res.redirect('/lendPay/dashboard');
  });

  // io.use((socket, next) => {
  //   const token = socket.handshake.auth.token;

  //   authenticateUser(socket.request, {}, (err) => {
  //     if (err) {
  //       // Authentication failed, disconnect the socket
  //       return next(new Error('Authentication failed.'));
  //     }

  //     next();
  //   });
  // });

  // io.on('connection', (socket) => {
  //   console.log('Client connected');

  //   socket.on('transaction_request', (data) => {
  //     const { receiverEmail } = data;
  //     io.to(receiverEmail).emit('incoming_transaction_request');
  //   });

  //   socket.on('receiver_accepts_transaction', (data) => {
  //     const { senderEmail, amount, startDate, endDate, interestRate, paymentCycle, subAmount, loanPeriod, interestAmount, totalAmount } = data;

  //     // Perform the necessary logic when the receiver accepts the transaction
  //     console.log('Receiver accepted the transaction');
  //     // Example call to ApiHelper.sendTransactionRequest
  //     // ApiHelper.sendTransactionRequest(senderEmail, receiverEmail, amount, startDate, endDate, interestRate, paymentCycle, subAmount, loanPeriod, interestAmount, totalAmount);
  //   });

  //   socket.on('disconnect', () => {
  //     console.log('Client disconnected');
  //   });
  // });

  const PORT = process.env.PORT || 3000;

  server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}
