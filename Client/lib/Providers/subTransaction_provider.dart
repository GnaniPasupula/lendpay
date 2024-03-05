import 'package:flutter/material.dart';
import 'package:lendpay/Models/subTransactions.dart';

class SubtransactionsProvider extends ChangeNotifier {
  List<subTransactions> _allSubTransactions = [];

  List<subTransactions> get allSubTransactions => _allSubTransactions;

  void setAllSubTransactions(List<subTransactions> transactions) {
    for (final transaction in transactions) {
      if (!_allSubTransactions.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allSubTransactions.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deletesubTransaction(subTransactions transactionToDelete) {
    _allSubTransactions = _allSubTransactions.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }

}
