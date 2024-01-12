import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:lendpay/Models/User.dart';
import 'package:lendpay/Models/subTransactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lendpay/Models/Transaction.dart';

class ApiHelper {
  static final String baseUrl = 'http://localhost:3000/lendpay';

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
        log(response.body);
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
        log(response.body);
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
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
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

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        log(response.body);
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

  static Future<void> sendTransactionRequest({
    required String receiverEmail,
    required int amount,
    required String startDate,
    required String endDate,
    required int interestRate,
    required int paymentCycle,
    required double subAmount,
    required int loanPeriod,
    required double interestAmount,
    required double totalAmount,
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
        log('Transaction request sent successfully');
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
    required int amount,
    required String startDate,
    required String endDate,
    required int interestRate,
    required int paymentCycle,
    required double subAmount,
    required int loanPeriod,
    required double interestAmount,
    required double totalAmount,
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
    required double paidAmount,
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

}
