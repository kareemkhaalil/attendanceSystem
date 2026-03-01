import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class HeroSection extends StatelessWidget {
  final Map<String, dynamic> content;
  const HeroSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final title = content['title'] as String? ??
        'إدارة الحضور بذكاء\nلشركتك وموظفيك';
    final subtitle = content['subtitle'] as String? ??
        'نظام متكامل لإدارة الحضور والمغادرة بتقنية QR وGPS الذكي.\nمتعدد الفروع، متعدد الشركات، لحظي وموثوق.';
    final ctaText = content['cta'] as String? ?? 'ابدأ تجربتك المجانية';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.5),
          radius: 1.2,
          colors: [
            Color(0xFF0D2A1A),
            LandingColors.bgDark,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 80,
          vertical: isMobile ? 100 : 140,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: LandingColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: LandingColors.primary.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: LandingColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الإصدار الجديد متاح الآن ✨',
                    style: GoogleFonts.inter(
                      color: LandingColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Main title
            Text(
              title,
              textAlign: TextAlign.center,
              style: LandingTheme.heading1(context).copyWith(
                fontSize: isMobile ? 36 : 60,
              ),
            ),
            const SizedBox(height: 24),
            // Subtitle
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: LandingTheme.body(context).copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 48),
            // CTA buttons
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                PrimaryButton(
                  text: ctaText,
                  large: true,
                  onPressed: () => context.go('/login'),
                ),
                SecondaryButton(
                  text: 'شاهد الديمو',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 80),
            // Mock dashboard preview
            _buildDashboardPreview(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPreview(bool isMobile) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Container(
        height: isMobile ? 200 : 360,
        decoration: BoxDecoration(
          color: LandingColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LandingColors.border),
          boxShadow: [
            BoxShadow(
              color: LandingColors.primary.withOpacity(0.08),
              blurRadius: 60,
              spreadRadius: -10,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Window bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: LandingColors.surfaceLight,
                child: Row(
                  children: [
                    _dot(const Color(0xFFFF5F57)),
                    const SizedBox(width: 8),
                    _dot(const Color(0xFFFFBD2E)),
                    const SizedBox(width: 8),
                    _dot(const Color(0xFF28CA41)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: LandingColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'app.manzoma.com',
                          style: GoogleFonts.inter(
                              color: LandingColors.textMuted, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar mock
                      Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: LandingColors.bgDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            _sidebarIcon(Icons.dashboard_rounded, true),
                            _sidebarIcon(Icons.people_rounded, false),
                            _sidebarIcon(Icons.qr_code_scanner, false),
                            _sidebarIcon(Icons.bar_chart_rounded, false),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Stats grid mock
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: isMobile ? 2 : 4,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            _statsMock('حضور اليوم', '94%',
                                LandingColors.primary),
                            _statsMock('الموظفون', '128',
                                const Color(0xFF6366F1)),
                            _statsMock('الفروع', '5',
                                const Color(0xFFF59E0B)),
                            _statsMock('تأخيرات', '3',
                                const Color(0xFFEF4444)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _sidebarIcon(IconData icon, bool active) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active
              ? LandingColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: active ? LandingColors.primary : LandingColors.textMuted,
            size: 18),
      );

  Widget _statsMock(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    color: LandingColors.textMuted, fontSize: 11)),
          ],
        ),
      );
}
