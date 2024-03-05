import 'package:flutter/material.dart';
import 'package:lendpay/Models/subTransactions.dart';

class SubtransactionsOfTransactionProvider extends ChangeNotifier {
  List<subTransactions> _allSubTransactionsOfTransaction = [];

  List<subTransactions> get allSubTransactionsOfTransaction => _allSubTransactionsOfTransaction;

  void setAllSubTransactions(List<subTransactions> transactions) {
    for (final transaction in transactions) {
      if (!_allSubTransactionsOfTransaction.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allSubTransactionsOfTransaction.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deletesubTransactionTransactionUser(subTransactions transactionToDelete) {
    _allSubTransactionsOfTransaction = _allSubTransactionsOfTransaction.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }
}
