const express = require('express');
const router = express.Router(); 
const User = require('../Models/User'); 
const Transaction = require('../Models/Transaction'); 
const subTransactions = require('../Models/subTransactions');

router.get('/dashboard', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId).populate('subTransactions');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allSubTransactions = [...user.subTransactions];

    // Sort subTransactions by the adjusted date in ascending order
    allSubTransactions.sort((a, b) => {
      const dateA = new Date(a.time).getTime();
      const dateB = new Date(b.time).getTime();

      return dateA - dateB;
    });

    res.status(200).json(allSubTransactions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/user/loans', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId).populate('creditTransactions debitTransactions');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allTransactions = [...user.creditTransactions, ...user.debitTransactions];

    // Sort subTransactions by the adjusted date in ascending order
    allTransactions.sort((a, b) => {
      const dateA = new Date(a.time).getTime();
      const dateB = new Date(b.time).getTime();

      return dateA - dateB;
    });

    res.status(200).json(allTransactions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/requests', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId)
      .populate('requests');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allRequestTransactions = [...user.requests];

    // Sort transactions by the adjusted date in ascending order
    allRequestTransactions.sort((a, b) => {
      const dateA = new Date(a.time).getTime();
      const dateB = new Date(b.time).getTime();

      const adjustedDateA = dateA + a.interestPeriod * 30 * 24 * 60 * 60 * 1000; 
      const adjustedDateB = dateB + b.interestPeriod * 30 * 24 * 60 * 60 * 1000; 

      return adjustedDateA - adjustedDateB;
    });

    // Get the transaction with the least adjusted date
    // const leastTransaction = allTransactions[0];

    res.status(200).json(allRequestTransactions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/paymentrequests', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId)
      .populate('paymentrequests');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const allPaymentRequestTransactions = [...user.paymentrequests];

    res.status(200).json(allPaymentRequestTransactions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/dashboard/user', async (req, res) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId);
    // console.log(user);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }else{
      res.status(200).json(user);
    }

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

    allTransactions.sort((a, b) => {

      const dateA = a.date.getTime(); 
      const dateB = b.date.getTime(); 

      const adjustedDateA = dateA + a.interestPeriod * 30 * 24 * 60 * 60 * 1000; 
      const adjustedDateB = dateB + b.interestPeriod * 30 * 24 * 60 * 60 * 1000; 

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
    const {
      receiverEmail,
      amount,
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
    } = req.body;    

    const senderEmail = req.user.userEmail;
    // console.dir(req.user, { depth: null });
    // console.dir(req.body, { depth: null });

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
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
    });

    sender.requests.push(transaction._id);
    receiver.requests.push(transaction._id);

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request sent successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.post('/acceptrequest', async (req, res) => {
  try {
    const {
      requestTransactionID,
      senderEmail,
      amount,
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
    } = req.body;    

    const receiverEmail = req.user.userEmail;
    // console.dir(req.user, { depth: null });

    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });
    // console.log("sender"+sender+",receiver"+receiver);

    if (!sender || !receiver) {
      return res.status(404).json({ message: 'Sender or receiver not found' });
    }

    const transaction = new Transaction({
      sender: senderEmail, 
      receiver: receiverEmail, 
      amount,
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
      type:"notReq"
    });

    sender.debitTransactions.push(transaction._id);
    sender.totalDebit += amount;

    receiver.creditTransactions.push(transaction._id);
    receiver.totalCredit += amount;

    await Transaction.findByIdAndDelete(requestTransactionID);
    sender.requests.pull(requestTransactionID);
    receiver.requests.pull(requestTransactionID);

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request sent successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.post('/rejectrequest', async (req, res) => {
  try {
    const { requestTransactionID, receiverEmail } = req.body;
    const senderEmail = req.user.userEmail;

    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });

    if (!sender || !receiver) {
      return res.status(404).json({ message: 'Sender or receiver not found' });
    }

    // console.log(req.body);

    // console.log(requestTransactionID);

    sender.requests.pull(requestTransactionID);
    receiver.requests.pull(requestTransactionID);

    await Transaction.findByIdAndDelete(requestTransactionID);
    
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request rejected successfully' });
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

router.post('/requestpayment', async (req, res) => {
  try {
    const { transactionID, paidAmount, date} = req.body;

    const transaction = await Transaction.findById(transactionID);

    const receiverEmail = transaction.sender;
    const senderEmail = transaction.receiver;
    
    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });

    const subTransaction = new subTransactions({
      transactionID:transactionID,
      sender:senderEmail,
      receiver:receiverEmail,
      amount:paidAmount,
      date:date
    });

    sender.paymentrequests.push(subTransaction);
    receiver.paymentrequests.push(subTransaction);

    await subTransaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Payment confirmed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/rejectrequestpayment', async (req, res) => {
  try {
    const { transactionID, paidAmount} = req.body;

    const transaction = await Transaction.findById(transactionID);

    const receiverEmail = transaction.sender;
    const senderEmail = transaction.receiver;
    
    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });

    const subTransaction = new subTransactions({
      transactionID,
      senderEmail,
      receiverEmail,
      paidAmount,
    });

    sender.paymentrequests.push(subTransaction);
    receiver.paymentrequests.push(subTransaction);

    await subTransaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Payment confirmed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router; 