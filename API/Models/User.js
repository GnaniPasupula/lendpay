const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  creditTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction' }],
  debitTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction' }],
  totalCredit: { type: Number, required: true, default: 0 },
  totalDebit: { type: Number, required: true, default: 0 },
});


const User = mongoose.model('User', userSchema);

module.exports = User;
