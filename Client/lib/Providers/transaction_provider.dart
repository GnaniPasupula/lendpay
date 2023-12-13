import 'package:flutter/material.dart';
import 'package:lendpay/Models/Transaction.dart';

class TransactionsProvider extends ChangeNotifier {
  List<Transaction> _allTransactions = [];

  List<Transaction> get allTransactions => _allTransactions;

  void setAllTransactions(List<Transaction> transactions) {
    _allTransactions = transactions;
    notifyListeners();
  }
}
