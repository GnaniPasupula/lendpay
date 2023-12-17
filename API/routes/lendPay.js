const express = require('express');
const router = express.Router(); 
const User = require('../Models/User'); 
const Transaction = require('../Models/Transaction'); 

router.get('/dashboard', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId)
      .populate('creditTransactions debitTransactions');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allTransactions = [...user.creditTransactions, ...user.debitTransactions];

    // Sort transactions by the adjusted date in ascending order
    allTransactions.sort((a, b) => {
      // Convert transactionDate to a single unit (e.g., hours)
      const dateA = a.date.getTime(); // Date in milliseconds
      const dateB = b.date.getTime(); // Date in milliseconds

      // Add interest period to the adjusted date
      const adjustedDateA = dateA + a.interestPeriod * 30 * 24 * 60 * 60 * 1000; // Assuming 30 days in a month
      const adjustedDateB = dateB + b.interestPeriod * 30 * 24 * 60 * 60 * 1000; // Assuming 30 days in a month

      return adjustedDateA - adjustedDateB;
    });

    // Get the transaction with the least adjusted date
    // const leastTransaction = allTransactions[0];

    res.status(200).json(allTransactions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/dashboard/urgent', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId)
      .populate('creditTransactions debitTransactions');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allTransactions = [...user.creditTransactions, ...user.debitTransactions];

    // Sort transactions by the adjusted date in ascending order
    allTransactions.sort((a, b) => {
      // Convert transactionDate to a single unit (e.g., hours)
      const dateA = a.date.getTime(); // Date in milliseconds
      const dateB = b.date.getTime(); // Date in milliseconds

      // Add interest period to the adjusted date
      const adjustedDateA = dateA + a.interestPeriod * 30 * 24 * 60 * 60 * 1000; // Assuming 30 days in a month
      const adjustedDateB = dateB + b.interestPeriod * 30 * 24 * 60 * 60 * 1000; // Assuming 30 days in a month

      return adjustedDateA - adjustedDateB;
    });

    // Get the transaction with the least adjusted date
    const leastTransaction = allTransactions[0];

    res.status(200).json(leastTransaction);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
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
      sender: senderEmail, 
      receiver: receiverEmail, 
      amount,
      interestRate,
      interestPeriod,
    });

    // console.log(transaction);

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

router.post('/request', async (req, res) => {
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
      sender: senderEmail, 
      receiver: receiverEmail, 
      amount,
      interestRate,
      interestPeriod,
    });

    sender.debitTransactions.push(transaction._id);
    sender.totalDebit += amount;

    receiver.creditTransactions.push(transaction._id);
    receiver.totalCredit += amount;

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request sent successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/users/:email/transactions',async (req,res)=>{

  try {

    const email = req.params.email;

    const otherUser = await User.findOne({email:email});
    const activeUser = req.user.userEmail;

    // console.log(activeUser+" userId="+email);

    if (!otherUser || otherUser===activeUser) {
      return res.status(404).json({ message: 'Sender or receiver not found' });
    }

    const transactions = await Transaction.find({
      $or: [
        { sender: activeUser, receiver: email },
        { sender: email, receiver: activeUser },
      ],
    });

    res.status(200).json(transactions);

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }

})

router.get('/users/:email', async (req,res)=>{
  try {
    const email = req.params.email;
    const otherUser = await User.findOne({email:email});
    const activeUser = req.user.userEmail;

    const currentUser = await User.findOne({email:activeUser});

    if (!otherUser || email===activeUser) {
      return res.status(404).json({ message: 'Sender or receiver not found' });
    }else{
      const previousUserIds = new Set(currentUser.previousUsers.map(user => user.toString()));

      if (!previousUserIds.has(otherUser._id.toString())) {
        currentUser.previousUsers.push(otherUser);
      }
      await currentUser.save();
      res.status(200).json(otherUser);
    }

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
})

router.get('/user/request', async (req,res)=>{
  try {
    const userId = req.user.userId;

    const users=await User.findById(userId).populate('previousUsers');

    if (!users) {
      return res.status(404).json({ message: 'Users not found' });
    }

    const allUsers = [...users.previousUsers];

    res.status(200).json(allUsers);

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
})

module.exports = router; 