import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:lendpay/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lendpay/Models/Transaction.dart';

class ApiHelper {
  // static final String baseUrl = 'http://localhost:3000/lendpay';
  static final String baseUrl = 'http://192.168.0.103:3000/lendpay';

  static Future<User?> verifyUser(String email) async {
    final url = '$baseUrl/users/$email';
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        final User user = User.fromJson(jsonData);

        return user;
        
      } else if (response.statusCode == 404) {
        // User not found
        log('User not found');
        return null;
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
  static Future<User> getActiveUser() async {
    final url = '$baseUrl/dashboard/user';
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      // print(response.body);

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        final User user = User.fromJson(jsonData);
        return user;
      } else{
        throw Exception('Error fetching user data after login');
      }

    } catch (e) {
      throw Exception('Error fetching user data after login: $e');
    }
  }

  static Future<void> storeFCMToken(String email, String fCMToken) async {
    final url = '$baseUrl/store-fcm-token';
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'fCMToken': fCMToken}),
      );

      if (response.statusCode == 200) {
        print('FCM token stored successfully');
      } else if (response.statusCode == 404) {
        print('User not found');
        throw Exception('User not found');
      } else {
        throw Exception('Failed to store FCM token');
      }
    } catch (e) {
      throw Exception('Error storing FCM token: $e');
    }
  } 

  static Future<List<User>> fetchUsers() async{
    final url='$baseUrl/user/request';
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      // print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // log(response.body);
        final List<User> users = jsonData
            .map((data) => User.fromJson(data))
            .toList();
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<List<subTransactions>> fetchSubTransactions() async {

    final url = '$baseUrl/dashboard';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // log(response.body);
        final List<subTransactions> transactions = jsonData
            .map((data) => subTransactions.fromJson(data))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }

  }

  static Future<List<Transaction>> fetchUserTransactions(String userEmail) async {
    final url = '$baseUrl/users/$userEmail';
    return _fetchTransactionsByUrl('$url/transactions');
  }

  static Future<List<Transaction>> fetchUserLoans() async {
    final url = '$baseUrl/user/loans';
    return _fetchTransactionsByUrl('$url');
  }

  static Future<List<Transaction>> _fetchTransactionsByUrl(String url) async {
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        log(response.body);
        final List<Transaction> transactions = jsonData
            .map((data) => Transaction.fromJson(data))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load User transactions');
      }
    } catch (e) {
      throw Exception('Error fetching User transactions: $e');
    }
  }

  static Future<List<Transaction>> fetchUserRequests() async {
    final url = '$baseUrl/requests/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        log(response.body);
        final List<Transaction> transactions = jsonData
            .map((data) => Transaction.fromJson(data))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  static Future<List<subTransactions>> fetchUserPaymentRequests() async {
    final url = '$baseUrl/paymentrequests/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      log(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<subTransactions> transactions = jsonData
            .map((data) => subTransactions.fromJson(data))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  static Future<Transaction> sendTransactionRequest({
    required String receiverEmail,
    required num amount,
    required String startDate,
    required String endDate,
    required num interestRate,
    required num paymentCycle,
    required num subAmount,
    required num loanPeriod,
    required num interestAmount,
    required num totalAmount,
  }) async {
    final url = '$baseUrl/request';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json',},
        body: jsonEncode({
          'receiverEmail': receiverEmail,
          'amount': amount,
          'startDate': startDate,
          'endDate': endDate,
          'interestRate': interestRate,
          'paymentCycle': paymentCycle,
          'subAmount': subAmount,
          'loanPeriod': loanPeriod,
          'interestAmount': interestAmount,
          'totalAmount': totalAmount,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final transaction = Transaction.fromJson(responseData['transaction']);
        return transaction;
      } else if (response.statusCode == 404) {
        log('Sender or receiver not found');
        throw Exception('Sender or receiver not found');
      } else {
        throw Exception('Failed to send transaction request');
      }
    } catch (e) {
      throw Exception('Error sending transaction request: $e');
    }
  }

  static Future<void> acceptTransactionRequest({
    required String requestTransactionID,
    required String senderEmail,
    required num amount,
    required String startDate,
    required String endDate,
    required num interestRate,
    required num paymentCycle,
    required num subAmount,
    required num loanPeriod,
    required num interestAmount,
    required num totalAmount,
  }) async {
    final url = '$baseUrl/acceptrequest';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json',},
        body: jsonEncode({
          'requestTransactionID': requestTransactionID,
          'senderEmail': senderEmail,
          'amount': amount,
          'startDate': startDate,
          'endDate': endDate,
          'interestRate': interestRate,
          'paymentCycle': paymentCycle,
          'subAmount': subAmount,
          'loanPeriod': loanPeriod,
          'interestAmount': interestAmount,
          'totalAmount': totalAmount,
        }),
      );

      if (response.statusCode == 200) {
        log('Transaction request accepted successfully');
      } else if (response.statusCode == 404) {
        log('Sender or receiver not found');
        throw Exception('Sender or receiver not found');
      } else {
        throw Exception('Failed to accept transaction request');
      }
    } catch (e) {
      throw Exception('Error accepting transaction request: $e');
    }
  }

  static Future<void> rejectTransactionRequest({
    required String requestTransactionID,
    required String receiverEmail,

  }) async {
    final url = '$baseUrl/rejectrequest';
    // print("requestTransactionID");
    // print(requestTransactionID);

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json',},
        body: jsonEncode({
          'requestTransactionID': requestTransactionID,
          'receiverEmail': receiverEmail,
        }),
      );

      if (response.statusCode == 200) {
        log('Transaction request rejected successfully');
      } else if (response.statusCode == 404) {
        log('Sender or receiver not found');
        throw Exception('Sender or receiver not found');
      } else {
        throw Exception('Failed to reject transaction request');
      }
    } catch (e) {
      throw Exception('Error rejecting transaction request: $e');
    }
  }

  static Future<void> sendTransactionPaymentRequest({
    required String transactionID,
    required num paidAmount,
    required String date,
    }) async {
    final url = '$baseUrl/requestpayment';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transactionID': transactionID,
          'paidAmount': paidAmount,
          'date': date
        }),
      );

      if (response.statusCode == 200) {
        log('Payment confirmed successfully');
      } else {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  static Future<void> rejectTransactionPaymentRequest({
    required String subtransactionID,
    required String senderEmail,
    required String receiverEmail
    }) async {
    final url = '$baseUrl/rejectrequestpayment';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subtransactionID': subtransactionID,
          'senderEmail': senderEmail,
          'receiverEmail': receiverEmail
        }),
      );

      if (response.statusCode == 200) {
        log('Payment confirmed successfully');
      } else {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  static Future<void> acceptTransactionPaymentRequest({
    required String transactionID,
    required String date,
    required String subtransactionID,
    required String senderEmail,
    required String receiverEmail,
  }) async {
    final url = '$baseUrl/acceptrequestpayment';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transactionID': transactionID,
          'date': date,
          'subtransactionID': subtransactionID,
          'senderEmail': senderEmail,
          'receiverEmail': receiverEmail,
        }),
      );

      if (response.statusCode == 200) {
        log('Payment confirmed successfully');
      } else {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  static Future<Transaction> getLoan(String transactionID) async {
    final url = '$baseUrl/getLoan';
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transactionID': transactionID,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        final Transaction loan = Transaction.fromJson(jsonData);
        return loan;
      } else {
        throw Exception('Failed to fetch loan');
      }
    } catch (e) {
      throw Exception('Error fetching loan: $e');
    }
  }

  static Future<List<subTransactions>> fetchSubTransactionsOfTransaction(String transactionID) async {
    final url = '$baseUrl/subtransactions/$transactionID';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<subTransactions> subTransactionss = jsonData
            .map((dynamic item) => subTransactions.fromJson(item))
            .toList();

        return subTransactionss;
      } else {
        throw Exception('Failed to fetch subTransactions');
      }
    } catch (e) {
      throw Exception('Error fetching subTransactions: $e');
    }
  }

static Future<void> changeName(String newName,String email) async {
  final url = '$baseUrl/change-name';

  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({'email': email, 'newName': newName}),
    );

    if (response.statusCode == 200) {
      print('Name changed successfully');
    } else {
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['message'];
      print(errorMessage);
    }
  } catch (error) {
    print('Error during HTTP request: $error');
  }
}


  static Future<void> logout(BuildContext context) async {
    // const url = 'http://localhost:3000/auth/logout';
    const url = 'http://192.168.0.103:3000/auth/logout';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'];
        print(errorMessage);
        // _showErrorDialog(errorMessage);
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  static Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    final url = '$baseUrl/change-password'; 

    try {

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        print('Password changed successfully');
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'];
        print('Error changing password: $errorMessage');
      }
    } catch (error) {
      print('Error changing password: $error');
    }
  }

}
