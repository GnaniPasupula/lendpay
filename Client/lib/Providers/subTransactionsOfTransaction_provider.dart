import 'package:flutter/material.dart';
import 'package:lendpay/Models/subTransactions.dart';

class SubtransactionsOfTransactionProvider extends ChangeNotifier {
  List<subTransactions> _allTransactions = [];

  List<subTransactions> get allTransactions => _allTransactions;

  void setAllSubTransactions(List<subTransactions> transactions) {
    _allTransactions = transactions;
    notifyListeners();
  }
}
