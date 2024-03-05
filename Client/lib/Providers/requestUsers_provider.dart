import 'package:flutter/material.dart';
import 'package:lendpay/Models/User.dart';

class RequestUsersProvider extends ChangeNotifier {
  List<User> _allrequestUser = [];

  List<User> get allrequestUser => _allrequestUser;

  void setAllRequestUsers(List<User> users) {
    for (final newUser in users) {
      if (!_allrequestUser.any((existingUser) => existingUser.email == newUser.email)) {
        _allrequestUser.add(newUser);
      }
    }    
    notifyListeners();
  }

  void deleteUser(User userToDelete) {
    _allrequestUser = _allrequestUser.where((user) => user.id != userToDelete.id).toList();
    notifyListeners();  
  }
}
