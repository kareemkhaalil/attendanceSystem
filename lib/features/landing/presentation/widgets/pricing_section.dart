import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class PricingSection extends StatefulWidget {
  final Map<String, dynamic> content;
  const PricingSection({super.key, required this.content});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final title = widget.content['title'] as String? ?? 'خطط تناسب كل شركة';
    final subtitle = widget.content['subtitle'] as String? ??
        'ابدأ مجاناً وطوّر خطتك مع نمو شركتك';

    return Container(
      color: LandingColors.bgDark,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 100,
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: LandingTheme.heading2(context)
                .copyWith(fontSize: isMobile ? 30 : 44),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: LandingTheme.body(context),
          ),
          const SizedBox(height: 40),
          // Toggle
          _buildToggle(),
          const SizedBox(height: 60),
          // Cards
          isMobile
              ? Column(
                  children: _pricingCards(isMobile: true),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _pricingCards(isMobile: false)
                      .map((w) => Expanded(child: w))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LandingColors.surface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: LandingColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('شهري', !_isYearly),
          _toggleOption('سنوي (وفر 20%)', _isYearly),
        ],
      ),
    );
  }

  Widget _toggleOption(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = text.contains('سنوي')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? LandingColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: active ? Colors.black : LandingColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<Widget> _pricingCards({required bool isMobile}) {
    final plans = [
      {
        'name': widget.content['starter_name'] as String? ?? 'Starter',
        'price_monthly':
            widget.content['starter_price'] as String? ?? '49',
        'highlighted': false,
        'features': [
          'حتى 20 موظف',
          'فرع واحد',
          'تقارير أساسية',
          'دعم فني عبر الإيميل',
        ],
      },
      {
        'name': widget.content['growth_name'] as String? ?? 'Growth',
        'price_monthly':
            widget.content['growth_price'] as String? ?? '149',
        'highlighted': true,
        'features': [
          'حتى 100 موظف',
          'حتى 5 فروع',
          'تقارير متقدمة',
          'رواتب تلقائية',
          'دعم فني أولوية',
        ],
      },
      {
        'name': widget.content['pro_name'] as String? ?? 'Enterprise',
        'price_monthly':
            widget.content['pro_price'] as String? ?? '399',
        'highlighted': false,
        'features': [
          'موظفون غير محدودين',
          'فروع غير محدودة',
          'API مخصص',
          'White Label',
          'مدير حساب مخصص',
        ],
      },
    ];

    return plans.asMap().entries.map((entry) {
      final plan = entry.value;
      final highlighted = plan['highlighted'] as bool;
      final price = plan['price_monthly'] as String;
      final yearlyPrice =
          (int.tryParse(price) ?? 0) * 12 * 0.8;

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 8,
          vertical: isMobile ? 8 : 0,
        ),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: highlighted ? LandingColors.primary : LandingColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: highlighted
                ? LandingColors.primary
                : LandingColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'الأكثر شيوعاً',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              plan['name'] as String,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: highlighted ? Colors.black : LandingColors.textWhite,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_isYearly ? (yearlyPrice / 12).toStringAsFixed(0) : price}',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color:
                        highlighted ? Colors.black : LandingColors.textWhite,
                  ),
                ),
                Text(
                  ' / شهر',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: highlighted
                        ? Colors.black.withOpacity(0.6)
                        : LandingColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ...(plan['features'] as List<String>).map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: highlighted
                          ? Colors.black.withOpacity(0.8)
                          : LandingColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      f,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: highlighted
                            ? Colors.black.withOpacity(0.85)
                            : LandingColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      highlighted ? Colors.black : LandingColors.surface,
                  foregroundColor:
                      highlighted ? LandingColors.primary : LandingColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: highlighted
                        ? BorderSide.none
                        : const BorderSide(color: LandingColors.border),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ابدأ الآن',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
