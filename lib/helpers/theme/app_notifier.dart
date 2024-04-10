/*
* File : App Theme Notifier (Listener)
* Version : 1.0.0
* */

import 'package:upsa/helpers/extensions/theme_extension.dart';
import 'package:upsa/helpers/localizations/language.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/theme/theme_type.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;
  int _count = 0;
  bool _isLoggedIn = false;

  int get count => _count;
  bool get isLoggedIn => _isLoggedIn;
  AppNotifier() {
    init();
  }

  init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ThemeType themeType =
        sharedPreferences.getString("theme_mode").toString().toThemeType;
    _changeTheme(themeType);
    await _loadFromPrefs();
    notifyListeners();
  }
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _count = _prefs.getInt('count') ?? 0;
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
  }
  Future<void> _resetPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.clear(); // Esto eliminará todos los valores almacenados en SharedPreferences
    // Ahora puedes volver a cargar los valores predeterminados o dejarlos en su estado inicial
    _count = 0;
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
    //TODO:-----------------
    // FxAppTheme.textDirection = textDirection;

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
    _prefs.setInt('count', _count);
    _prefs.setBool('isLoggedIn', _isLoggedIn);
  }

  void incrementCount() {
    _count++;
    _saveToPrefs();
    notifyListeners();
  }
  void login() {
    _isLoggedIn = true;
    _saveToPrefs();
    notifyListeners();
  }
  void logout() {
    _isLoggedIn = false;
    _saveToPrefs();
    notifyListeners();
  }
  void limpiarValores() async {
    await _resetPrefs();
  }
}
