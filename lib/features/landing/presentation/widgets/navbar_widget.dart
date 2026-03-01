import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class LandingNavbar extends StatefulWidget {
  const LandingNavbar({super.key});

  @override
  State<LandingNavbar> createState() => _LandingNavbarState();
}

class _LandingNavbarState extends State<LandingNavbar> {
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > 50 && !_scrolled) {
          setState(() => _scrolled = true);
        } else if (n.metrics.pixels <= 50 && _scrolled) {
          setState(() => _scrolled = false);
        }
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: _scrolled
              ? LandingColors.bgDark.withOpacity(0.95)
              : Colors.transparent,
          border: _scrolled
              ? const Border(
                  bottom: BorderSide(color: LandingColors.border, width: 1))
              : null,
        ),
        child: Row(
          children: [
            // Logo
            _buildLogo(),
            const Spacer(),
            // Links - desktop only
            if (!isMobile) ...[
              _navLink('المميزات'),
              _navLink('الأسعار'),
              _navLink('تواصل معنا'),
              const SizedBox(width: 32),
            ],
            // CTA
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: LandingColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: LandingColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time_rounded,
              color: Colors.black, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'Manzoma',
          style: GoogleFonts.inter(
            color: LandingColors.textWhite,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _navLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: LandingColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
