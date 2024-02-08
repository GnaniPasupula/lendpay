import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/api_helper.dart';

class FetchUserProvider extends ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers() async {
    try {
      final List<User> users = await ApiHelper.fetchUsers();
      _users = users;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void clearUsers() {
    _users.clear();
    notifyListeners();
  }
}
