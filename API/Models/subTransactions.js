const mongoose = require('mongoose');

const subTransactionSchema = new mongoose.Schema({
  // id: { type: String, required: true, unique: true },
  transactionID: {type: String, ref: 'transaction', required: true},
  sender: { type: String, ref: 'User', required: true },
  receiver: { type: String, ref: 'User', required: true },
  amount: { type: Number, required: true },
  time: { type: String, default: () => new Date().toLocaleTimeString() , required: true},
  Date: { type: String, default: Date.now , required: true},
  type: { type: String, required: true , default:"req"},
});

const subTransactions = mongoose.model('subTransactions', subTransactionSchema);

module.exports = subTransactions;
