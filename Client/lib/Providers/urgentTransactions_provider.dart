import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';

class UrgentTransactionProvider extends ChangeNotifier {
  List<Transaction> _allUrgentTransactions= [];

  List<Transaction> get allUrgentTransactions => _allUrgentTransactions;

  void setAllSubTransactions(List<Transaction> transactions) {
    for (final transaction in transactions) {
      if (!_allUrgentTransactions.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allUrgentTransactions.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deletesubTransactionTransactionUser(Transaction transactionToDelete) {
    _allUrgentTransactions = _allUrgentTransactions.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }
}
