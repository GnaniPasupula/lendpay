import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';

class IncomingRequestProvider extends ChangeNotifier {
  List<Transaction> _allTransactions = [];

  List<Transaction> get allTransactions => _allTransactions;

  void setAllRequests(List<Transaction> transactions) {
    for (final transaction in transactions) {
      if (!_allTransactions.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allTransactions.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deleteRequest(Transaction transactionToDelete) {
    _allTransactions = _allTransactions.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }

  void addRequest(Transaction newRequest) {
    _allTransactions.add(newRequest);
    notifyListeners();
  }
}
