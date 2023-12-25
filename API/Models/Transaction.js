const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  // id: { type: String, required: true, unique: true },
  sender: { type: String, ref: 'User', required: true },
  receiver: { type: String, ref: 'User', required: true },
  amount: { type: Number, required: true },
  startDate: { type: String, default: Date.now , required: true},
  endDate: { type: String, default: Date.now , required: true},
  interestRate: { type: Number, required: true , default:0}, 
  paymentCycle: { type: Number, required: true , default:0},
  subAmount: { type: Number, required: true , default:0},
  loanPeriod: { type: Number, required: true , default:0},
  interestAmount: { type: Number, required: true , default:0},
  totalAmount: { type: Number, required: true , default:0},
});

const Transaction = mongoose.model('Transaction', transactionSchema);

module.exports = Transaction;
