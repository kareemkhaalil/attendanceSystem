import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان الـ Landing Page
class LandingColors {
  static const Color primary = Color(0xFF1AD17D);    // نيون أخضر
  static const Color bgDark = Color(0xFF0B0F13);     // خلفية داكنة
  static const Color surface = Color(0xFF141920);    // سطح البطاقات
  static const Color surfaceLight = Color(0xFF1E2630);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFB0B8C1);
  static const Color border = Color(0xFF2A3240);
  static const Color cardBg = Color(0xFF141920); // 👈 Added this
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF0B0F13);
}

/// Theme Data للـ Landing Page
class LandingTheme {
  static TextStyle heading1(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: LandingColors.textWhite,
        height: 1.15,
        letterSpacing: -1.5,
      );

  static TextStyle heading2(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: LandingColors.textWhite,
        height: 1.2,
      );

  static TextStyle heading3(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: LandingColors.textWhite,
      );

  static TextStyle body(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: LandingColors.textLight,
        height: 1.7,
      );

  static TextStyle label(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: LandingColors.textMuted,
      );
}

/// زر CTA الرئيسي
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool large;
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: LandingColors.primary,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: large ? 40 : 28,
          vertical: large ? 20 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: large ? 18 : 15,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// زر ثانوي (outlined)
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const SecondaryButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: LandingColors.textWhite,
        side: const BorderSide(color: LandingColors.border, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: LandingColors.textWhite,
        ),
      ),
    );
  }
}

/// بطاقة section عامة
class LandingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  const LandingCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? LandingColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: Border.all(color: LandingColors.border, width: 1),
      ),
      child: child,
    );
  }
}
