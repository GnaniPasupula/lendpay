import 'package:flutter/material.dart';
import 'package:lendpay/Models/subTransactions.dart';

class IncomingPaymentRequestProvider extends ChangeNotifier {
  List<subTransactions> _allTransactions = [];

  List<subTransactions> get allTransactions => _allTransactions;

  void setAllRequests(List<subTransactions> transactions) {
    for (final transaction in transactions) {
      if (!_allTransactions.any((existingtransaction) => existingtransaction.id == transaction.id)) {
        _allTransactions.add(transaction);
      }
    }    
    notifyListeners();
  }

  void deletePaymentRequest(subTransactions transactionToDelete) {
    _allTransactions = _allTransactions.where((transaction) => transaction.id != transactionToDelete.id).toList();
    notifyListeners();  
  }

  void addPaymentRequest(subTransactions newRequest) {
    _allTransactions.add(newRequest);
    notifyListeners();
  }
}
