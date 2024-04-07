import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lendpay/API/firebase_api.dart';
import 'package:lendpay/Providers/activeUser_provider.dart';
import 'package:lendpay/Providers/allTransactions_provider.dart';
import 'package:lendpay/Providers/fCMToken_provider.dart';
import 'package:lendpay/Providers/incomingPaymentRequest_provider.dart';
import 'package:lendpay/Providers/incomingRequest_provider.dart';
import 'package:lendpay/Providers/requestUsers_provider.dart';
import 'package:lendpay/Providers/subTransaction_provider.dart';
import 'package:lendpay/Providers/subTransactionsOfTransaction_provider.dart';
import 'package:lendpay/Providers/transactionsUser_provider.dart';
import 'package:lendpay/Providers/urgentTransactions_provider.dart';
import 'package:lendpay/Widgets/bottom_networkBar.dart';
import 'package:lendpay/dashboard.dart';
import 'package:lendpay/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './auth_screen.dart'; 

void main() async{
  await dotenv.load(fileName:'.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SubtransactionsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => FCMTokenProvider()),
        ChangeNotifierProvider(create: (context) => RequestUsersProvider()),
        ChangeNotifierProvider(create: (context) => SubtransactionsOfTransactionProvider()),
        ChangeNotifierProvider(create: (context) => TransactionsUser()),
        ChangeNotifierProvider(create: (context) => UrgentTransactionProvider()),
        ChangeNotifierProvider(create: (context) => TransactionsAllProvider()),
        ChangeNotifierProvider(create: (context) => IncomingRequestProvider()),
        ChangeNotifierProvider(create: (context) => IncomingPaymentRequestProvider()),
        Provider(create: (context) => BottomBar()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LendPay',
      theme: ThemeData( 
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black ),
      ),
      home: Scaffold(
        body: FutureBuilder(
          future: checkAuthToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return const Dashboard();
              } else {
                return AuthScreen();
              }
            } else {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        bottomNavigationBar: Consumer<BottomBar>( 
          builder: (context, bottomBar, _) => bottomBar,
        ),
      ),
    );
  }

  Future<bool> checkAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    return authToken != null && authToken.isNotEmpty;
  }
}
