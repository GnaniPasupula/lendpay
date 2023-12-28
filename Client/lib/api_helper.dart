import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:lendpay/Models/User.dart';
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
  static Future<User?> getActiveUser() async {
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
      } 

      return null;
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



  static Future<List<Transaction>> fetchTransactions() async {
    return _fetchTransactionsByUrl('$baseUrl/dashboard');
  }

  static Future<List<Transaction>> fetchUserTransactions(String userEmail) async {
    final url = '$baseUrl/users/$userEmail';
    return _fetchTransactionsByUrl('$url/transactions');
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
    final url = '$baseUrl/user/request';

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
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
}
