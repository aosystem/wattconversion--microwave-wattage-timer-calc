import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wattconversion/l10n/app_localizations.dart';

class Model {
  Model._();

  static const String _prefShowBackImage = 'showBackImage';
  static const String _prefSoundVolume = 'soundVolume';
  static const String _prefWattFrom = 'wattFrom';
  static const String _prefWattTo = 'wattTo';
  static const String _prefMinute = 'minute';
  static const String _prefSecond = 'second';
  static const String _prefThemeNumber = 'themeNumber';
  static const String _prefLanguageCode = 'languageCode';

  static bool _ready = false;
  static bool _showBackImage = true;
  static double _soundVolume = 0.3;
  static int _wattFrom = 1000;
  static int _wattTo = 600;
  static int _minute = 5;
  static int _second = 0;
  static int _themeNumber = 0;
  static String _languageCode = '';

  static bool get showBackImage => _showBackImage;
  static double get soundVolume => _soundVolume;
  static int get wattFrom => _wattFrom;
  static int get wattTo => _wattTo;
  static int get minute => _minute;
  static int get second => _second;
  static int get themeNumber => _themeNumber;
  static String get languageCode => _languageCode;

  static Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    _showBackImage = prefs.getBool(_prefShowBackImage) ?? true;
    _soundVolume = (prefs.getDouble(_prefSoundVolume) ?? 1.0).clamp(0.0, 1.0);
    _wattFrom = (prefs.getInt(_prefWattFrom) ?? 1000).clamp(300, 1800);
    _wattTo = (prefs.getInt(_prefWattTo) ?? 600).clamp(300, 1800);
    _minute = (prefs.getInt(_prefMinute) ?? 5).clamp(1, 30);
    _second = (prefs.getInt(_prefSecond) ?? 0).clamp(0, 50);
    _themeNumber = (prefs.getInt(_prefThemeNumber) ?? 0).clamp(0, 2);
    _languageCode = prefs.getString(_prefLanguageCode) ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _languageCode = _resolveLanguageCode(_languageCode);
    _ready = true;
  }

  static String _resolveLanguageCode(String code) {
    final supported = AppLocalizations.supportedLocales;
    if (supported.any((l) => l.languageCode == code)) {
      return code;
    } else {
      return '';
    }
  }

  static Future<void> setShowBackImage(bool value) async {
    _showBackImage = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowBackImage, value);
  }

  static Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefSoundVolume, value);
  }

  static Future<void> setWattFrom(int value) async {
    _wattFrom = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefWattFrom, value);
  }

  static Future<void> setWattTo(int value) async {
    _wattTo = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefWattTo, value);
  }

  static Future<void> setMinute(int value) async {
    _minute = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMinute, value);
  }

  static Future<void> setSecond(int value) async {
    _second = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefSecond, value);
  }

  static Future<void> setThemeNumber(int value) async {
    _themeNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeNumber, value);
  }

  static Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCode, value);
  }

}
