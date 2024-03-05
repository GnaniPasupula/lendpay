import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';

class TransactionsUser extends ChangeNotifier {
  List<Transaction> _allTransactionsUser = [];

  List<Transaction> get allTransactionsUser => _allTransactionsUser;

  void setAllTransactionUsers(List<Transaction> transactions) {
    for (final transaction in transactions) {
      if (!_allTransactionsUser.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allTransactionsUser.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deleteTransactionUser(Transaction transactionToDelete) {
    _allTransactionsUser = _allTransactionsUser.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }
}
