const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  // id: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name:{type: String, required:true, default: "NoName"},
  creditTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction',required:true, default:[] }], 
  debitTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction',required:true, default:[] }],
  requests: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Transaction',required:true, default:[] }],
  paymentrequests: [{ type: mongoose.Schema.Types.ObjectId, ref: 'subTransactions',required:true, default:[] }],
  totalCredit: { type: Number, required: true, default: 0 },
  totalDebit: { type: Number, required: true, default: 0 },
  previousUsers: [{type: mongoose.Schema.Types.ObjectId,ref: 'User',required:true, default:[]}],
  subTransactions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'subTransactions',required:true, default:[] }], 
});


const User = mongoose.model('User', userSchema);

module.exports = User;
