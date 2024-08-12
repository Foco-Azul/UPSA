/*
* File : App Theme Notifier (Listener)
* Version : 1.0.0
* */

import 'dart:convert';

import 'package:flutkit/custom/models/notificacion.dart';
import 'package:flutkit/helpers/extensions/theme_extension.dart';
import 'package:flutkit/helpers/localizations/language.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';
import 'package:flutkit/helpers/theme/theme_type.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutkit/custom/models/user.dart';

class AppNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  bool _isLoggedIn = false;
  User _user = User();
  bool _esNuevo = true;
  final List<Notificacion> _notificaciones= [];

  bool get isLoggedIn => _isLoggedIn;
  User get user => _user;
  bool get esNuevo => _esNuevo;
  List<Notificacion> get notificaciones => _notificaciones;

  AppNotifier() {
    init();
  }

  init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ThemeType themeType = sharedPreferences.getString("theme_mode").toString().toThemeType;
    _changeTheme(themeType);
    await _loadFromPrefs();
    notifyListeners();
  }
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    _esNuevo = _prefs.getBool('esNuevo') ?? true;
    String? userJson = _prefs.getString('user') ?? "";
    if (userJson.isNotEmpty && _isLoggedIn) {
      Map<String, dynamic> userMap = json.decode(userJson);
      _user = User.fromJson(userMap);
    }
  }
  Future<void> _resetPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.clear(); // Esto eliminará todos los valores almacenados en SharedPreferences
    _isLoggedIn = false;
  }
  updateTheme(ThemeType themeType) {
    _changeTheme(themeType);

    notifyListeners();

    updateInStorage(themeType);
  }

  Future<void> updateInStorage(ThemeType themeType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("theme_mode", themeType.toText);
  }

  void changeDirectionality(TextDirection textDirection, [bool notify = true]) {
    AppTheme.textDirection = textDirection;
    if (notify) notifyListeners();
  }

  Future<void> changeLanguage(Language language,
      [bool notify = true, bool changeDirection = true]) async {
    if (changeDirection) {
      if (language.supportRTL) {
        changeDirectionality(TextDirection.rtl, false);
      } else {
        changeDirectionality(TextDirection.ltr, false);
      }
    }

    await Language.changeLanguage(language);

    if (notify) notifyListeners();
  }

  void _changeTheme(ThemeType themeType) {
    AppTheme.themeType = themeType;
    AppTheme.customTheme = AppTheme.getCustomTheme(themeType);
    AppTheme.theme = AppTheme.getTheme(themeType);
    AppTheme.resetThemeData();
  }
  void _saveToPrefs() {
    _prefs.setBool('isLoggedIn', _isLoggedIn);
    _prefs.setString('user', json.encode(_user.toJson()));
    _prefs.setBool('esNuevo', _esNuevo); 
  }
  void login() {
    _isLoggedIn = true;
    _saveToPrefs();
    notifyListeners();
  }
  void iniciar() {
    _saveToPrefs();
    notifyListeners();
  }
  void logout() {
    _isLoggedIn = false;
    _prefs.setString('user', "");
    _saveToPrefs();
    notifyListeners();
  }
  void limpiarValores() async {
    await _resetPrefs();
  }
  void setUser(User user) {
    _user = user;
    _saveToPrefs();
    notifyListeners();
  }
  void setEsNuevo(bool estado){
    _esNuevo = estado;
    _saveToPrefs();
    notifyListeners();
  }
  bool getEsNuevo(){
    return _esNuevo;
  }
  List<Notificacion> getNotificaciones(){
    return _notificaciones;
  }
}
