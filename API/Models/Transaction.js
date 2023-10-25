const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  date: { type: Date, default: Date.now },
  interestRate: { type: Number, required: true , default:0}, 
  interestPeriod: { type: String, required: true , default:0}, 
});

const Transaction = mongoose.model('Transaction', transactionSchema);

module.exports = Transaction;
