//SHA1: 15:34:34:42:19:74:7D:8C:3E:F4:1A:DE:AD:F7:57:98:D4:86:62:0D

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService{
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;

  static Future _backgroundHandler(RemoteMessage message) async {
    print('background Handler ${message.messageId}');
  }
  static Future _onMessageHandler(RemoteMessage message) async {
    print('onMessage Handler ${message.messageId}');
  }
  static Future _onMessageOpenApp(RemoteMessage message) async {
    print('onMessageOpenApp Handler ${message.messageId}');
  }

  static Future initializeApp() async {
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    print('TOKEN: ${token}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenDispositivo', token!); 
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }
  String getToken(){
    return token!;
  }
}