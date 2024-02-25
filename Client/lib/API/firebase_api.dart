import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // static const String fcmServerKey = '07efb902e96cf85bf4abf6d23043e82aec9384cf';
  // static const String serverUrl = 'http://192.168.0.103:3000/send-notification';
  static const String serverUrl = 'http://localhost:3000/send-notification';

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
  }

  Future<String?> getfCMToken() async {
    final String? fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  Future<void> sendNotificationToUser({
    required String receiverToken,
    required String title,
    required String body,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'receiverToken': receiverToken,
        'title': title,
        'body': body,
      };

      print(receiverToken+" from client");

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
