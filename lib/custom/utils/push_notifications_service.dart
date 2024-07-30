//SHA1: 15:34:34:42:19:74:7D:8C:3E:F4:1A:DE:AD:F7:57:98:D4:86:62:0D

// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutkit/custom/models/notificacion.dart';
import 'package:flutkit/custom/screens/inicio/notificaciones_screen.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutkit/main.dart';
import 'package:flutter/material.dart';
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
    notificacionesCadenas.add(notificacion.toString());
    prefs.setStringList('notificaciones', notificacionesCadenas); 
    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
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
    notificacionesCadenas.add(notificacion.toString());
    prefs.setStringList('notificaciones', notificacionesCadenas); 
    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
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
    notificacionesCadenas.add(notificacion.toString());
    prefs.setStringList('notificaciones', notificacionesCadenas);
    navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomesScreen(indice: 0,)),(Route<dynamic> route) => false);
    navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => NotificacionesScreen()));
  }
  static Future initializeApp() async {
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    print('TOKEN: $token');
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