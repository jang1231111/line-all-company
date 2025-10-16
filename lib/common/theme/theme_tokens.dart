import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1C63D6);
  static const Color primaryVariant = Color(0xFF154E9C);
  static const Color scaffoldBg = Color(0xFFF4F8FF);
  static const Color cardBg = Colors.white;
  static const Color elevatedButtonBg = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFFFC857);
  static const Color inputFill = Colors.white;
  static const Color hintText = Color(0x8A000000); // black54-ish
  static const Color prefixIcon = Colors.blueGrey;
  static const Color chipBg = Color(0xFFEAF5FF);
  static const Color chipSelected = Color(0xFFBEE1FF);
}

class AppSpacing {
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
}

class AppRadius {
  static const double card = 18.0;
  static const double field = 12.0;
  static const double button = 12.0;
  static const double chip = 10.0;
}