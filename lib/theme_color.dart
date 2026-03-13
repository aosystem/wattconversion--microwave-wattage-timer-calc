import 'package:flutter/material.dart';

class ThemeColor {
  final int? themeNumber;
  final BuildContext context;

  ThemeColor({this.themeNumber, required this.context});

  Brightness get _effectiveBrightness {
    switch (themeNumber) {
      case 1:
        return Brightness.light;
      case 2:
        return Brightness.dark;
      default:
        return Theme.of(context).brightness;
    }
  }

  bool get _isLight => _effectiveBrightness == Brightness.light;

  //main page
  Color get mainBackColor => _isLight ? Color.fromRGBO(221, 221, 221, 1.0) : Color.fromRGBO(51, 51, 51, 1.0);
  Color get mainForeColor => _isLight ? Color.fromRGBO(0,0,0,0.7) : Color.fromRGBO(255, 255, 255, 1);
  Color get mainHeaderColor => _isLight ? Color.fromRGBO(255,255,255,0.4) : Color.fromRGBO(0,0,0,0.4);
  Color get mainBackColorMono => _isLight ? Colors.white : Colors.black;
  Color get mainForeColorMono => _isLight ? Colors.black : Colors.white;
  Color get mainFromColor => _isLight ? Color.fromRGBO(0, 61, 191, 1.0) : Color.fromRGBO(180, 180, 255, 1.0);
  Color get mainToColor => _isLight ? Color.fromRGBO(211, 0, 126, 1.0) : Color.fromRGBO(253, 137, 174, 1.0);
  Color get backColor => _isLight ? Colors.grey[200]! : Colors.grey[900]!;
  Color get cardColor => _isLight ? Colors.white : Colors.grey[800]!;
  Color get appBarForegroundColor => _isLight ? Colors.grey[700]! : Colors.white70;
  Color get dropdownColor => cardColor;
  Color get borderColor => _isLight ? Colors.grey[300]! : Colors.grey[700]!;
  Color get inputFillColor => _isLight ? Colors.grey[50]! : Colors.grey[900]!;
}
