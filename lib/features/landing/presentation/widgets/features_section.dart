import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_theme.dart';

class FeaturesSection extends StatelessWidget {
  final Map<String, dynamic> content;
  const FeaturesSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final title = content['title'] as String? ?? 'كل ما تحتاجه في مكان واحد';
    final subtitle = content['subtitle'] as String? ??
        'من تسجيل الحضور بالـ QR حتى الرواتب والتقارير — نظام Manzoma يغطي كل احتياجاتك';

    final features = [
      {
        'icon': Icons.qr_code_scanner_rounded,
        'color': LandingColors.primary,
        'title': 'حضور بالـ QR',
        'desc': 'مسح رمز QR لتسجيل الحضور فورياً مع التحقق من الموقع الجغرافي',
      },
      {
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFF6366F1),
        'title': 'تتبع GPS',
        'desc': 'تأكيد أن الموظف داخل نطاق العمل عند تسجيل الحضور',
      },
      {
        'icon': Icons.account_tree_rounded,
        'color': const Color(0xFFF59E0B),
        'title': 'تعدد الفروع',
        'desc': 'إدارة جميع فروع شركتك من لوحة تحكم واحدة بسهولة',
      },
      {
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF10B981),
        'title': 'الرواتب التلقائية',
        'desc': 'احتساب الرواتب تلقائياً بناءً على سجلات الحضور والغياب',
      },
      {
        'icon': Icons.insert_chart_rounded,
        'color': const Color(0xFFEF4444),
        'title': 'تقارير متقدمة',
        'desc': 'تقارير تفصيلية قابلة للتصدير بصيغ Excel وPDF',
      },
      {
        'icon': Icons.security_rounded,
        'color': const Color(0xFF8B5CF6),
        'title': 'أمان متعدد المستأجرين',
        'desc': 'بيانات كل شركة معزولة تماماً مع صلاحيات دقيقة لكل دور',
      },
    ];

    return Container(
      color: LandingColors.bgLight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 100,
      ),
      child: Column(
        children: [
          // Header
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 30 : 44,
              fontWeight: FontWeight.w800,
              color: LandingColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 64),
          // Features grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cols = constraints.maxWidth < 600 ? 1 :
                           constraints.maxWidth < 900 ? 2 : 3;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: features.map((f) {
                  return SizedBox(
                    width: (constraints.maxWidth - (cols - 1) * 24) / cols,
                    child: _featureCard(f),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _featureCard(Map<String, dynamic> feature) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: feature['color'] as Color,
              size: 26,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            feature['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LandingColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature['desc'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
