import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';

class UserProvider extends ChangeNotifier {
  late User _activeUser;

  User get activeUser => _activeUser;

  void setActiveUser(User user) {
    _activeUser = user;
    notifyListeners();
  }
}
