const express = require('express');
const router = express.Router(); 
const User = require('../Models/User'); 
const Transaction = require('../Models/Transaction'); 
const subTransactions = require('../Models/subTransactions');
const bcrypt = require('bcrypt');
const cron = require('node-cron');
const Redis = require('ioredis'); 

const redisClient = new Redis({
  host: process.env.REDIS_AWS_ENDPOINT, 
  port: 6379, 
  connectTimeout: 5000,
});

redisClient.on('error', (err) => console.error('Redis error:', err));

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

router.post('/addUser', async (req, res) => {
  try {
    const { name } = req.body;

    const existingUser = await User.findOne({ name, fCMToken:req.user.userId+name});

    if (existingUser) {
      return res.status(400).json({ message: 'User with the same name already exists' });
    }

    const userData = {
      password: 'No Password',
      name: name,
      fCMToken: req.user.userId + name,
      email: req.user.userId + name
    };

    const user = await User.create(userData);

    const userId = req.user.userId;
    const activeUser = await User.findById(userId);

    activeUser.previousUsers.push(user._id);
    user.previousUsers.push(userId);

    await activeUser.save();
    await user.save();

    return res.status(200).json(user);
  } catch (error) {
    console.error('Error creating user:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});


router.post('/deleteUser', async (req, res) => {
  try {
    const { userId } = req.body;

    const activeUserID= req.user.userId;

    const deletedUser = await User.findById(userId);

    if (!deletedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    const activeUser = await User.findById(activeUserID);
    activeUser.previousUsers.pull(userId);

    await Transaction.deleteMany({ $or: [{ sender: deletedUser.name }, { receiver: deletedUser.name }] });

    await subTransactions.deleteMany({ $or: [{ sender: deletedUser.name }, { receiver: deletedUser.name }] });

    activeUser.creditTransactions = activeUser.creditTransactions.filter(transactionId => !deletedUser.debitTransactions.includes(transactionId));
    activeUser.debitTransactions = activeUser.debitTransactions.filter(transactionId => !deletedUser.creditTransactions.includes(transactionId));
    activeUser.subTransactions = activeUser.subTransactions.filter(transactionId => !deletedUser.subTransactions.includes(transactionId));

    await activeUser.save();

    await User.findByIdAndDelete(userId);

    return res.status(201).json({ message: 'User and associated transactions deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});


router.post('/addTransaction', async (req, res) => {
  try {
    const {
      receiverUser,
      amount,
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
      isCredit
    } = req.body;    

    const senderEmail = req.user.userEmail;
    // console.dir(req.user, { depth: null });
    // console.dir(req.body, { depth: null });

    // console.dir(receiverUser, { depth: null });

    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({fCMToken: receiverUser.fCMToken});
    // console.log("sender"+sender+",receiver"+receiver);

    const transaction = new Transaction({
      sender: senderEmail, 
      receiver: receiver.name, 
      amount,
      startDate,
      endDate,
      interestRate,
      paymentCycle,
      subAmount,
      loanPeriod,
      interestAmount,
      totalAmount,
      type: "notReq",
      isCredit: isCredit
    });

    await transaction.save();

    sender.totalCredit+=amount;
    receiver.totalDebit+=amount;

    if(isCredit){
      sender.creditTransactions.push(transaction._id);
      receiver.debitTransactions.push(transaction._id);
    }else{
      sender.debitTransactions.push(transaction._id);
      receiver.creditTransactions.push(transaction._id);
    }

    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Transaction added successfully'});
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.post('/deleteTransaction', async (req, res) => {
  try {
    const {
      transactionID
    } = req.body;    

    const transaction = await Transaction.findById(transactionID);
    const amount=transaction.amount;

    const sender = await User.findOne({ email: transaction.sender });

    sender.totalCredit-=amount;
    // receiver.totalDebit-=amount;

    sender.creditTransactions.pull(transaction._id);
    // receiver.creditTransactions.push(transaction._id);

    await Transaction.findByIdAndDelete(transactionID);

    await sender.save();
    // await receiver.save();

    res.status(200).json({ message: 'Transaction added successfully'});
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

    if(allTransactions.length==0){
      res.status(201).json({message: 'No upcoming payments'});
    }else{

      allTransactions.sort((a, b) => {
  
        return a.endDate - b.endDate;
      });
  
      const leastTransaction = allTransactions[0];

      res.status(200).json(leastTransaction);
    }

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
      isCredit: true
    });

    sender.requests.push(transaction._id);
    receiver.requests.push(transaction._id);

    const cacheKey1 = `transactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `transactions:${receiverEmail}:${senderEmail}`;

    let cachedTransactions1 = await redisClient.get(cacheKey1);
    let cachedTransactions2 = await redisClient.get(cacheKey2);

    if (cachedTransactions1) {
      cachedTransactions1 = JSON.parse(cachedTransactions1);
    } else {
      cachedTransactions1 = []; 
    }
    if (cachedTransactions2) {
      cachedTransactions2 = JSON.parse(cachedTransactions2);
    } else {
      cachedTransactions2 = [];
    }

    cachedTransactions1.push(transaction);
    cachedTransactions2.push(transaction);

    redisClient.set(cacheKey1, JSON.stringify(cachedTransactions1), 'EX', 600); 
    redisClient.set(cacheKey2, JSON.stringify(cachedTransactions2), 'EX', 600); 

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request sent successfully', transaction });
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
    sender.totalCredit += amount;

    receiver.creditTransactions.push(transaction._id);
    receiver.totalDebit += amount;

    await Transaction.findByIdAndDelete(requestTransactionID);
    sender.requests.pull(requestTransactionID);
    receiver.requests.pull(requestTransactionID);

    const cacheKey1 = `transactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `transactions:${receiverEmail}:${senderEmail}`;

    let cachedTransactions1 = await redisClient.get(cacheKey1);
    let cachedTransactions2 = await redisClient.get(cacheKey2);

    if (cachedTransactions1) {
      cachedTransactions1 = JSON.parse(cachedTransactions1);
      cachedTransactions1 = cachedTransactions1.filter(t => t._id.toString() !== requestTransactionID);
      cachedTransactions1.push(transaction); 
      redisClient.set(cacheKey1, JSON.stringify(cachedTransactions1), 'EX', 600);
    }

    if (cachedTransactions2) {
      cachedTransactions2 = JSON.parse(cachedTransactions2);
      cachedTransactions2 = cachedTransactions2.filter(t => t._id.toString() !== requestTransactionID);
      cachedTransactions2.push(transaction); 
      redisClient.set(cacheKey2, JSON.stringify(cachedTransactions2), 'EX', 600);
    }

    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request accepted successfully',transaction });
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

    const cacheKey1 = `transactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `transactions:${receiverEmail}:${senderEmail}`;

    let cachedTransactions1 = await redisClient.get(cacheKey1);
    let cachedTransactions2 = await redisClient.get(cacheKey2);

    if (cachedTransactions1) {
      cachedTransactions1 = JSON.parse(cachedTransactions1);
      cachedTransactions1 = cachedTransactions1.filter(t => t._id.toString() !== requestTransactionID);
      redisClient.set(cacheKey1, JSON.stringify(cachedTransactions1), 'EX', 600);
    }

    if (cachedTransactions2) {
      cachedTransactions2 = JSON.parse(cachedTransactions2);
      cachedTransactions2 = cachedTransactions2.filter(t => t._id.toString() !== requestTransactionID);
      redisClient.set(cacheKey2, JSON.stringify(cachedTransactions2), 'EX', 600);
    }
    
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Request rejected successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/users/:email/transactions', async (req, res) => {
  try {
      const email = req.params.email;
      const otherUser = await User.findOne({ email: email });
      const activeUser = req.user.userEmail;

      if (!otherUser || otherUser === activeUser) {
          return res.status(404).json({ message: 'Sender or receiver not found' });
      }

      const cacheKey1 = `transactions:${activeUser}:${email}`;
      const cacheKey2 = `transactions:${email}:${activeUser}`;

      let cachedTransactions1 = await redisClient.get(cacheKey1);
      let cachedTransactions2 = await redisClient.get(cacheKey2);

      if (cachedTransactions1 || cachedTransactions2) {
          // console.log('Cache hit for key:', cacheKey);
          return res.status(200).json(JSON.parse(cachedTransactions1??cachedTransactions2));
      } else {
          // console.log('Cache miss for key:', cacheKey);

          const transactions = await Transaction.find({
              $or: [
                  { sender: activeUser, receiver: email },
                  { sender: email, receiver: activeUser },
              ],
          });

          redisClient.set(cacheKey1, JSON.stringify(transactions), 'EX', 600); 
          redisClient.set(cacheKey2, JSON.stringify(transactions), 'EX', 600); 

          return res.status(200).json(transactions); 
      }

  } catch (error) {
      console.error('Error:', error);
      return res.status(500).json({ message: 'An error occurred' });
  }
});

router.get('/manualUsers/:name/transactions',async (req,res)=>{
  try {

    const name = req.params.name;

    const activeUser = req.user.userEmail;

    // console.log(activeUser+" other"+name);

    const transactions = await Transaction.find({
      $or: [
        { sender: activeUser, receiver: name },
        { sender: name, receiver: activeUser },
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

router.post('/addPayment', async (req, res) => {
  try {
    const { transactionID, paidAmount, date, isCredit} = req.body;

    const transaction = await Transaction.findById(transactionID);
    transaction.amountPaid+=paidAmount;

    // const receiverEmail = transaction.receiver;
    const senderEmail = transaction.sender;

    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({previousUsers: sender._id, name:transaction.receiver});

    const subTransaction = new subTransactions({
      transactionID:transactionID,
      sender:senderEmail,
      receiver:transaction.receiver,
      amount:paidAmount,
      date:date,
      type:"notreq",
      isCredit: !isCredit
    });

    sender.subTransactions.push(subTransaction);
    receiver.subTransactions.push(subTransaction);

    await subTransaction.save();
    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json(subTransaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/deletePayment', async (req, res) => {
  try {
    const {subtransactionID} = req.body;

    const subTransaction = await subTransactions.findById(subtransactionID);
    const transaction = await Transaction.findById(subTransaction.transactionID);

    transaction.amountPaid-=subTransaction.amount;

    const sender = await User.findOne({ email: subTransaction.sender });

    await subTransactions.findByIdAndDelete(subtransactionID);
    sender.subTransactions.pull(subtransactionID);

    await transaction.save();
    await sender.save();

    res.status(200).json({ message: 'Payment deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/requestpayment', async (req, res) => {
  try {
    const { transactionID, paidAmount, date, isCredit} = req.body;

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
      date:date,
      isCredit: !isCredit
    });

    sender.paymentrequests.push(subTransaction);
    receiver.paymentrequests.push(subTransaction);

    const cacheKey1 = `subtransactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `subtransactions:${receiverEmail}:${senderEmail}`;

    let cachedSubTransactions1 = await redisClient.get(cacheKey1);
    let cachedSubTransactions2 = await redisClient.get(cacheKey2);

    if (cachedSubTransactions1) {
      cachedSubTransactions1 = JSON.parse(cachedSubTransactions1);
    } else {
      cachedSubTransactions1 = []; 
    }
    if (cachedSubTransactions2) {
      cachedSubTransactions2 = JSON.parse(cachedSubTransactions2);
    } else {
      cachedSubTransactions2 = [];
    }

    cachedSubTransactions1.push(subTransaction);
    cachedSubTransactions2.push(subTransaction);

    redisClient.set(cacheKey1, JSON.stringify(cachedTransactions1), 'EX', 600); 
    redisClient.set(cacheKey2, JSON.stringify(cachedTransactions2), 'EX', 600); 

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
    const { subtransactionID, senderEmail, receiverEmail} = req.body;
    
    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });

    await subTransactions.findByIdAndDelete(subtransactionID);

    sender.paymentrequests.pull(subtransactionID);
    receiver.paymentrequests.pull(subtransactionID);

    const cacheKey1 = `subtransactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `subtransactions:${receiverEmail}:${senderEmail}`;

    let cachedSubTransactions1 = await redisClient.get(cacheKey1);
    let cachedSubTransactions2 = await redisClient.get(cacheKey2);

    if (cachedSubTransactions1) {
      cachedSubTransactions1 = JSON.parse(cachedSubTransactions1);
      cachedSubTransactions1 = cachedSubTransactions1.filter(t => t._id.toString() !== subtransactionID);
      redisClient.set(cacheKey1, JSON.stringify(cachedSubTransactions1), 'EX', 600);
    }

    if (cachedSubTransactions2) {
      cachedSubTransactions2 = JSON.parse(cachedSubTransactions2);
      cachedSubTransactions2 = cachedSubTransactions2.filter(t => t._id.toString() !== subtransactionID);
      redisClient.set(cacheKey2, JSON.stringify(cachedSubTransactions2), 'EX', 600);
    }

    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Payment confirmed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/acceptrequestpayment', async (req, res) => {
  try {
    const { transactionID, date,subtransactionID, senderEmail, receiverEmail} = req.body;
    
    const sender = await User.findOne({ email: senderEmail });
    const receiver = await User.findOne({ email: receiverEmail });

    const transaction = await Transaction.findById(transactionID);
    transaction.amountPaid+=transaction.subAmount;

    await subTransactions.findByIdAndDelete(subtransactionID);
    
    const subTransaction = new subTransactions({
      transactionID:transactionID,
      sender:senderEmail,
      receiver:receiverEmail,
      amount:transaction.subAmount,
      date:date,
      type:"notreq"
    });

    sender.paymentrequests.pull(subtransactionID);
    receiver.paymentrequests.pull(subtransactionID);

    sender.subTransactions.push(subTransaction);
    receiver.subTransactions.push(subTransaction);

    const cacheKey1 = `subtransactions:${senderEmail}:${receiverEmail}`;
    const cacheKey2 = `subtransactions:${receiverEmail}:${senderEmail}`;

    let cachedSubTransactions1 = await redisClient.get(cacheKey1);
    let cachedSubTransactions2 = await redisClient.get(cacheKey2);

    if (cachedSubTransactions1) {
      cachedSubTransactions1 = JSON.parse(cachedSubTransactions1);
      cachedSubTransactions1 = cachedSubTransactions1.filter(t => t._id.toString() !== subtransactionID);
      cachedSubTransactions1.push(subTransaction); 
      redisClient.set(cacheKey1, JSON.stringify(cachedSubTransactions1), 'EX', 600);
    }

    if (cachedSubTransactions2) {
      cachedSubTransactions2 = JSON.parse(cachedSubTransactions2);
      cachedSubTransactions2 = cachedSubTransactions2.filter(t => t._id.toString() !== subtransactionID);
      cachedSubTransactions2.push(subTransaction); 
      redisClient.set(cacheKey2, JSON.stringify(cachedSubTransactions2), 'EX', 600);
    }

    await subTransaction.save();
    await transaction.save();
    await sender.save();
    await receiver.save();

    res.status(200).json({ message: 'Payment confirmed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/getLoan', async (req, res) => {
  try {
    const {transactionID} = req.body;

    const transaction = await Transaction.findById(transactionID);

    res.status(200).json(transaction);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.get('/subtransactions/:transactionID', async (req, res) => {
  try {
    const transactionID = req.params.transactionID;

    const result = await subTransactions.find({
      transactionID: transactionID,
      type: 'notreq'
    });

    res.status(200).json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

router.post('/change-name', async (req, res) => {
  try {
    const { email, newName } = req.body;

    const user = await User.findOne({email:email});

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.name = newName;

    await user.save();

    res.status(200).json({ message: 'Name changed successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.post('/change-password', async (req, res) => {
  const { email, oldPassword, newPassword } = req.body;

  try {
    const user = await User.findOne({email:email});

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isPasswordValid = await bcrypt.compare(oldPassword, user.password);

    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Old password is incorrect' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    user.password=hashedPassword;

    await user.save();

    return res.status(200).json({ message: 'Password changed successfully' });
  } catch (error) {
    console.error('Error changing password:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/store-fcm-token', async (req, res) => {
  try {
    const { email, fCMToken } = req.body;

    // Find the user by email
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.fCMToken = fCMToken;
    await user.save();

    return res.status(200).json({ message: 'FCM token stored successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

cron.schedule('0 8 * * *', async () => { 
  try {
    const fiveDaysFromNow = new Date();
    fiveDaysFromNow.setDate(fiveDaysFromNow.getDate() + 5);

    const transactions = await Transaction.find({ endDate: { $lte: fiveDaysFromNow } });

    for (const transaction of transactions) {
      const senderEmail = transaction.sender; 
      const senderReminderMessage = `Reminder: Your Payment of ${transaction.subAmount} for Loan with ID ${transaction._id} is to be paid by ${transaction.endDate}.`;

      await sendReminderEmail(senderEmail, senderReminderMessage);

      const receiverEmail = transaction.receiver; 
      const receiverReminderMessage = `Reminder: ${transaction.sender} has to pay you ${transaction.subAmount} for Loan with ID ${transaction._id} by ${transaction.endDate}.`;

      await sendReminderEmail(receiverEmail, receiverReminderMessage);
    }

    console.log('Reminders sent successfully');
  } catch (error) {
    console.error('Error sending reminders:', error);
  }
});

const sendReminderEmail = async (email, message) => {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.MAIL_EMAIL,
        pass: process.env.MAIL_PASS
      }
    });

    const mailOptions = {
      from: process.env.MAIL_EMAIL,
      to: email,
      subject: 'Loan Payment Reminder',
      text: message
    };

    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Error sending email');
  }
};

module.exports = router; 