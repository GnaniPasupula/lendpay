import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lendpay/api_helper.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

class FirebaseApi{

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async{

    await _firebaseMessaging.requestPermission();
    
  }

  Future<String?> getfCMToken() async{
    final fCMToken = await _firebaseMessaging.getToken();
    return fCMToken;
  }

  Future<void> sendNotificationToUser({
    required String receiverToken,
    required String title,
    required String body,
  }) async {
    try {
      await FirebaseMessagingPlatform.instance.sendMessage(
          data: {
            'title': title,
            'body': body,
          },
          to: receiverToken,
      );
      print('Notification sent successfully');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

}