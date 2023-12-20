const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name:{type: String, required:true, default: "NoName"},
  creditTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction',required:true, default:[] }], 
  debitTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction',required:true, default:[] }],
  totalCredit: { type: Number, required: true, default: 0 },
  totalDebit: { type: Number, required: true, default: 0 },
  previousUsers: [{type: mongoose.Schema.Types.ObjectId,ref: 'User',required:true, default:[]}]
});


const User = mongoose.model('User', userSchema);

module.exports = User;
