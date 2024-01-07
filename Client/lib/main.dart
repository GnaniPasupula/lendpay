import 'package:flutter/material.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/Providers/transaction_provider.dart';
import 'package:lendpay/dashboard.dart';
import 'package:provider/provider.dart';
import './auth_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SubtransactionsProvider()),
        ChangeNotifierProvider(create: (context) => TransactionsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Add more providers if needed
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
        primarySwatch: MaterialColor(0xffef5454, <int, Color>{
          50:  gradientColor[0],
          100: gradientColor[0],
          200: gradientColor[0],
          300: gradientColor[0],
          400: gradientColor[0],
          500: gradientColor[0],
          600: gradientColor[0],
          700: gradientColor[0],
          800: gradientColor[0],
          900: gradientColor[0],
        }),      
      ),
      routes: {
        '/': (ctx) => AuthScreen(), // Auth route
        '/dashboard': (ctx) => Dashboard(), // Credit card screen route
      },
    );
  }
}