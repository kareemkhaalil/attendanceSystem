import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class CtaSection extends StatelessWidget {
  final Map<String, dynamic> content;
  const CtaSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final title =
        content['title'] as String? ?? 'جاهز لتحويل إدارة حضور شركتك؟';
    final subtitle =
        content['subtitle'] as String? ?? 'انضم لأكثر من 500 شركة تثق في Manzoma';

    return Container(
      color: LandingColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 32 : 80,
          vertical: isMobile ? 48 : 72,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D3B27), Color(0xFF091A13)],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
              color: LandingColors.primary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 28 : 44,
                fontWeight: FontWeight.w800,
                color: LandingColors.textWhite,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: LandingColors.textMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                PrimaryButton(
                  text: 'ابدأ تجربتك المجانية ←',
                  large: true,
                  onPressed: () => context.go('/login'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LandingColors.textWhite,
                    side: const BorderSide(color: LandingColors.border),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    'تواصل مع فريق المبيعات',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: LandingColors.bgDark,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      child: Column(
        children: [
          // Footer top
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _brand(),
                    const SizedBox(height: 40),
                    _links(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _brand()),
                    Expanded(child: _links()),
                    Expanded(child: _links2()),
                  ],
                ),
          const SizedBox(height: 40),
          const Divider(color: LandingColors.border),
          const SizedBox(height: 24),
          // Footer bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 Manzoma. جميع الحقوق محفوظة.',
                style: GoogleFonts.inter(
                    color: LandingColors.textMuted, fontSize: 13),
              ),
              Text(
                'صُنع بـ ❤️ في مصر',
                style: GoogleFonts.inter(
                    color: LandingColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: LandingColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Manzoma',
              style: GoogleFonts.inter(
                color: LandingColors.textWhite,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'نظام SaaS متكامل لإدارة\nالحضور والرواتب لشركتك',
          style: GoogleFonts.inter(
            color: LandingColors.textMuted,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _links() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنتج',
          style: GoogleFonts.inter(
            color: LandingColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...['المميزات', 'الأسعار', 'التكاملات', 'التحديثات'].map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(t,
                style: GoogleFonts.inter(
                    color: LandingColors.textMuted, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _links2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشركة',
          style: GoogleFonts.inter(
            color: LandingColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...['عن Manzoma', 'تواصل معنا', 'سياسة الخصوصية', 'الشروط والأحكام']
            .map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(t,
                style: GoogleFonts.inter(
                    color: LandingColors.textMuted, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
