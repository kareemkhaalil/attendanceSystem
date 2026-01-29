import 'package:flutter/material.dart';

class GlassTheme extends ThemeExtension<GlassTheme> {
  final Color bgStart;
  final Color bgEnd;
  final Color blob1;
  final Color blob2;
  final Color blob3;

  final Color glass; // لون الزجاج
  final Color glassBorder; // حدود الزجاج
  final Color onGlassPrimary; // لون النص الأساسي فوق الزجاج
  final Color onGlassSecondary; // لون النص الثانوي فوق الزجاج
  final Color accent; // لون أكسنت (مثلاً شريط التقدم)

  // ألوان حالة "داخل/خارج"
  final Color statusInFg;
  final Color statusInBg;
  final Color statusOutFg;
  final Color statusOutBg;

  const GlassTheme({
    required this.bgStart,
    required this.bgEnd,
    required this.blob1,
    required this.blob2,
    required this.blob3,
    required this.glass,
    required this.glassBorder,
    required this.onGlassPrimary,
    required this.onGlassSecondary,
    required this.accent,
    required this.statusInFg,
    required this.statusInBg,
    required this.statusOutFg,
    required this.statusOutBg,
  });

  static GlassTheme light() => GlassTheme(
        bgStart: const Color(0xFFF8FAFC),
        bgEnd: const Color(0xFFEFF4FF),
        blob1: const Color(0xFF7C3AED).withOpacity(0.18),
        blob2: const Color(0xFF06B6D4).withOpacity(0.16),
        blob3: const Color(0xFF10B981).withOpacity(0.14),
        glass: Colors.white.withOpacity(0.75),
        glassBorder: Colors.black.withOpacity(0.06),
        onGlassPrimary: Colors.black87,
        onGlassSecondary: Colors.black54,
        accent: const Color(0xFF2563EB),
        statusInFg: const Color(0xFF059669),
        statusInBg: const Color(0xFF059669).withOpacity(0.15),
        statusOutFg: const Color(0xFFDC2626),
        statusOutBg: const Color(0xFFDC2626).withOpacity(0.15),
      );

  static GlassTheme dark() => GlassTheme(
        bgStart: const Color(0xFF0F172A),
        bgEnd: const Color(0xFF111827),
        blob1: const Color(0xFF7C3AED).withOpacity(0.35),
        blob2: const Color(0xFF06B6D4).withOpacity(0.30),
        blob3: const Color(0xFF10B981).withOpacity(0.25),
        glass: Colors.white.withOpacity(0.06),
        glassBorder: Colors.white.withOpacity(0.15),
        onGlassPrimary: Colors.white,
        onGlassSecondary: Colors.white70,
        accent: const Color(0xFF60A5FA),
        statusInFg: const Color(0xFF34D399),
        statusInBg: const Color(0xFF065F46).withOpacity(0.35),
        statusOutFg: const Color(0xFFF87171),
        statusOutBg: const Color(0xFF7F1D1D).withOpacity(0.35),
      );

  @override
  GlassTheme copyWith({
    Color? bgStart,
    Color? bgEnd,
    Color? blob1,
    Color? blob2,
    Color? blob3,
    Color? glass,
    Color? glassBorder,
    Color? onGlassPrimary,
    Color? onGlassSecondary,
    Color? accent,
    Color? statusInFg,
    Color? statusInBg,
    Color? statusOutFg,
    Color? statusOutBg,
  }) {
    return GlassTheme(
      bgStart: bgStart ?? this.bgStart,
      bgEnd: bgEnd ?? this.bgEnd,
      blob1: blob1 ?? this.blob1,
      blob2: blob2 ?? this.blob2,
      blob3: blob3 ?? this.blob3,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      onGlassPrimary: onGlassPrimary ?? this.onGlassPrimary,
      onGlassSecondary: onGlassSecondary ?? this.onGlassSecondary,
      accent: accent ?? this.accent,
      statusInFg: statusInFg ?? this.statusInFg,
      statusInBg: statusInBg ?? this.statusInBg,
      statusOutFg: statusOutFg ?? this.statusOutFg,
      statusOutBg: statusOutBg ?? this.statusOutBg,
    );
  }

  @override
  ThemeExtension<GlassTheme> lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return GlassTheme(
      bgStart: lerpColor(bgStart, other.bgStart),
      bgEnd: lerpColor(bgEnd, other.bgEnd),
      blob1: lerpColor(blob1, other.blob1),
      blob2: lerpColor(blob2, other.blob2),
      blob3: lerpColor(blob3, other.blob3),
      glass: lerpColor(glass, other.glass),
      glassBorder: lerpColor(glassBorder, other.glassBorder),
      onGlassPrimary: lerpColor(onGlassPrimary, other.onGlassPrimary),
      onGlassSecondary: lerpColor(onGlassSecondary, other.onGlassSecondary),
      accent: lerpColor(accent, other.accent),
      statusInFg: lerpColor(statusInFg, other.statusInFg),
      statusInBg: lerpColor(statusInBg, other.statusInBg),
      statusOutFg: lerpColor(statusOutFg, other.statusOutFg),
      statusOutBg: lerpColor(statusOutBg, other.statusOutBg),
    );
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB), brightness: Brightness.light),
    primaryColor: const Color(0xFF2563EB),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: const Color(0xFFF7FAFC),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    brightness: Brightness.light,
    extensions: <ThemeExtension<dynamic>>[
      GlassTheme.light(),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0EA5E9), brightness: Brightness.dark),
    primaryColor: const Color(0xFF1A202C),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey.shade800,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey.shade900,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white54),
      labelSmall: TextStyle(color: Colors.white54),
    ),
    extensions: <ThemeExtension<dynamic>>[
      GlassTheme.dark(),
    ],
  );
}
