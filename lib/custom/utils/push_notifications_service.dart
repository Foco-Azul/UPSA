//SHA1: 15:34:34:42:19:74:7D:8C:3E:F4:1A:DE:AD:F7:57:98:D4:86:62:0D

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutkit/custom/models/notificacion.dart';
import 'package:flutkit/custom/screens/inicio/notificaciones_screen.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService{
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  
  static Future _backgroundHandler(RemoteMessage message) async {
    //print('background Handler ${message.messageId}');
    //print(message.toMap());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificacionesCadenas = prefs.getStringList('notificaciones') ?? [];

    Notificacion notificacion = Notificacion(
      tipoNotificacion: message.data["tipoNotificacion"],
      tipoContenido: message.data["tipoContenido"],
      titulo: message.data["titulo"],
      descripcion: message.data["descripcion"],
      id: int.parse(message.data["id"]),
      estadoNotificacion: message.data["estadoNotificacion"],
    );

    // Convierte la notificación a JSON antes de guardarla
    String notificacionJson = json.encode(notificacion.toJson());
    notificacionesCadenas.insert(0, notificacionJson);

    await prefs.setStringList('notificaciones', notificacionesCadenas);

    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
  }
  static Future _onMessageHandler(RemoteMessage message) async {
    //print('onMessage Handler ${message.messageId}');
    //print(message.toMap());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificacionesCadenas = prefs.getStringList('notificaciones') ?? [];

    Notificacion notificacion = Notificacion(
      tipoNotificacion: message.data["tipoNotificacion"],
      tipoContenido: message.data["tipoContenido"],
      titulo: message.data["titulo"],
      descripcion: message.data["descripcion"],
      id: int.parse(message.data["id"]),
      estadoNotificacion: message.data["estadoNotificacion"],
    );

    // Convierte la notificación a JSON antes de guardarla
    String notificacionJson = json.encode(notificacion.toJson());
    notificacionesCadenas.insert(0, notificacionJson);

    await prefs.setStringList('notificaciones', notificacionesCadenas);

    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
  }
  static Future _onMessageOpenApp(RemoteMessage message) async {
    //print('onMessageOpenApp Handler ${message.messageId}');
    //print(message.toMap());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificacionesCadenas = prefs.getStringList('notificaciones') ?? [];

    Notificacion notificacion = Notificacion(
      tipoNotificacion: message.data["tipoNotificacion"],
      tipoContenido: message.data["tipoContenido"],
      titulo: message.data["titulo"],
      descripcion: message.data["descripcion"],
      id: int.parse(message.data["id"]),
      estadoNotificacion: message.data["estadoNotificacion"],
    );

    // Convierte la notificación a JSON antes de guardarla
    String notificacionJson = json.encode(notificacion.toJson());
    notificacionesCadenas.insert(0, notificacionJson);

    await prefs.setStringList('notificaciones', notificacionesCadenas);

    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
  }
  static Future initializeApp() async {
    try {
      await Firebase.initializeApp();

      if (Platform.isIOS) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        print('Permisos de notificación para iOS: ${settings.authorizationStatus}');
      } else {
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      }

      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        print('Sin conexión a Internet, no se puede obtener el token.');
        token = 'null';
      } else {
        if (Platform.isIOS) {
          token = await FirebaseMessaging.instance.getAPNSToken();
          print('APNS-TOKEN: $token');
        }

        try {
          token = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          print('Error al obtener el token: $e');
          token = 'null';
        }
      }

      print('TOKEN: $token');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('tokenDispositivo', token ?? 'null');

      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onMessageHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    } catch (e, stacktrace) {
      print('Error en initializeApp: $e');
      print('Stacktrace: $stacktrace');
    }
  }
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  String getToken(){
    return token!;
  }
}