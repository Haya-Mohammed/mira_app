import 'package:flutter/painting.dart';

abstract final class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F2C2C2A), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x142C2C2A), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F2C2C2A), offset: Offset(0, 8), blurRadius: 24),
  ];

  static List<BoxShadow> focus(Color color) => [
    BoxShadow(color: color, spreadRadius: 3),
  ];
}
