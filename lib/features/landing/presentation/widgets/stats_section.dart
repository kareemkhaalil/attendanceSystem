import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class StatsSection extends StatelessWidget {
  final Map<String, dynamic> content;
  const StatsSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final stats = [
      {
        'value': content['companies'] as String? ?? '500+',
        'label': 'شركة تثق بنا',
        'icon': Icons.business_rounded,
        'color': LandingColors.primary,
      },
      {
        'value': content['employees'] as String? ?? '25K+',
        'label': 'موظف مسجّل',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF6366F1),
      },
      {
        'value': content['checkins'] as String? ?? '2M+',
        'label': 'تسجيل حضور شهرياً',
        'icon': Icons.fingerprint_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'value': content['uptime'] as String? ?? '99.9%',
        'label': 'وقت تشغيل الخوادم',
        'icon': Icons.cloud_done_rounded,
        'color': const Color(0xFF10B981),
      },
    ];

    return Container(
      color: LandingColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      child: isMobile
          ? GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: stats
                  .map((s) => _statCard(s, isMobile))
                  .toList(),
            )
          : Row(
              children: stats
                  .map((s) => Expanded(child: _statCard(s, false)))
                  .toList(),
            ),
    );
  }

  Widget _statCard(Map<String, dynamic> stat, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LandingColors.bgDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LandingColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: GoogleFonts.inter(
              color: LandingColors.textWhite,
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['label'] as String,
            style: GoogleFonts.inter(
              color: LandingColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
