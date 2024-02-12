import 'package:flutter/material.dart';

class FCMTokenProvider extends ChangeNotifier {
  late String _fCMToken;

  String get fCMToken => _fCMToken;

  void setfCMToken(String token) {
    _fCMToken = token;
    notifyListeners();
  }
}