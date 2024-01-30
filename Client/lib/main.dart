import 'package:flutter/material.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/Providers/transaction_provider.dart';
import 'package:lendpay/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './auth_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SubtransactionsProvider()),
        ChangeNotifierProvider(create: (context) => TransactionsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

  final List<Color> gradientColor = [
    const Color(0xffffa31d),
    const Color(0xffef5454),
  ];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
      ),
      home: FutureBuilder(
        future: checkAuthToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return Dashboard();
            } else {
              return AuthScreen();
            }
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<bool> checkAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    return authToken != null && authToken.isNotEmpty;
  }
}
