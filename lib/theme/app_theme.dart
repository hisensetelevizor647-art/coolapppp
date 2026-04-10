import 'package:flutter/material.dart';

class AppTheme {
  // --- Constants from styles.css ---
  static const double borderRadiusPill = 999.0;
  static const double borderRadiusWrapper = 32.0;
  static const double borderRadiusPanel = 20.0;
  static const double borderRadiusStandard = 12.0;

  // --- Colors ---
  static const Color accentColor = Colors.black;
  static const Color geminiInputLight = Colors.white;
  static const Color geminiInputDark = Color(0xFF1F2937);
  static const Color geminiBorderLight = Color(0xFFE5E7EB);
  static const Color geminiBorderDark = Color(0xFF374151);
  
  static const Color bgMessageAiLight = Color(0xFFFFFFFF);
  static const Color messageAiBorderLight = Color(0xFFE5E7EB);
  static const Color bgMessageUserLight = Color(0xFF000000);
  
  // --- Shadows from styles.css ---
  static final List<BoxShadow> inputShadowLight = [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))
  ];
  
  static final List<BoxShadow> inputShadowDark = [
    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4))
  ];

  static final List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 8))
  ];

  static final List<BoxShadow> welcomeChipShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6))
  ];

  // --- Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
