import 'package:flutter/material.dart';

/// Zentrale Design-Datei.
///
/// Die Farbwelt ist bewusst dunkel, hochwertig und sportlich gehalten:
/// schwarzer Hintergrund, klare Karten, Gold-Akzent und dezentes Rot.
/// Dadurch erinnert die App optisch an ein Premium-Auto-/Porsche-Projekt,
/// bleibt aber trotzdem seriös und gut lesbar.
class AppTheme {
  static const Color background = Color(0xFF050609);
  static const Color backgroundSoft = Color(0xFF0E1117);
  static const Color card = Color(0xFF151923);
  static const Color cardSoft = Color(0xFF1C2230);
  static const Color cardBorder = Color(0xFF313746);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFFFD66B);
  static const Color redAccent = Color(0xFFC1121F);
  static const Color text = Color(0xFFF7F7F2);
  static const Color mutedText = Color(0xFFA6ADBA);
  static const Color success = Color(0xFF55D47E);
  static const Color warning = Color(0xFFFFB84D);


  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldSoft, gold],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2B2111),
      Color(0xFF111722),
      Color(0xFF050609),
    ],
  );

  static BoxDecoration premiumDecoration({bool highlighted = false}) {
    return BoxDecoration(
      gradient: highlighted ? heroGradient : null,
      color: highlighted ? null : card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: highlighted ? gold.withOpacity(0.55) : cardBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldSoft,
        surface: card,
        error: redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: text,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(color: mutedText, fontSize: 14),
        labelLarge: TextStyle(color: text, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: redAccent, width: 1.4),
        ),
        labelStyle: const TextStyle(color: mutedText),
        hintStyle: const TextStyle(color: mutedText),
        helperStyle: const TextStyle(color: mutedText),
        prefixIconColor: mutedText,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundSoft,
        selectedColor: gold.withOpacity(0.20),
        disabledColor: backgroundSoft,
        labelStyle: const TextStyle(color: text, fontWeight: FontWeight.w700),
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: cardBorder),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundSoft,
        contentTextStyle: const TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: gold),
    );
  }
}
