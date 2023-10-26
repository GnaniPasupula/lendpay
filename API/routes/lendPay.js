const express = require('express');
const router = express.Router(); 
const User = require('../Models/User'); 
const Transaction = require('../Models/Transaction'); 

router.get('/dashboard', async (req, res) => {
  const userId=req.user._id;

  const userDetails = await User.findById(userId);
  res.status(200).json(userDetails);
  
});

router.post('/transfer', async (req, res) => {
  try {
    const {receiverEmail, amount, interestRate, interestPeriod } = req.body;
    const senderEmail = req.user.userEmail;
    // console.dir(req.user, { depth: null });

    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });
    // console.log("sender"+sender+",receiver"+receiver);

    if (!sender || !receiver || senderEmail===receiverEmail) {
      return res.status(404).json({ message: 'Sender or receiver not found' });
    }

    const transaction = new Transaction({
      sender: sender._id, 
      receiver: receiver._id, 
      amount,
      interestRate,
      interestPeriod,
    });

    sender.creditTransactions.push(transaction._id);
    sender.totalCredit += amount;

    receiver.debitTransactions.push(transaction._id);
    receiver.totalDebit += amount;

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Transaction completed successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

module.exports = router; 