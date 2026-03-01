import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/landing_cubit.dart';
import '../cubit/landing_state.dart';
import '../screens/landing_screen.dart';
import '../widgets/landing_theme.dart';

class LandingAdminScreen extends StatefulWidget {
  const LandingAdminScreen({super.key});

  @override
  State<LandingAdminScreen> createState() => _LandingAdminScreenState();
}

class _LandingAdminScreenState extends State<LandingAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPreview = false;

  // Hero controllers
  final _heroTitleCtrl = TextEditingController(
      text: 'إدارة الحضور بذكاء\nلشركتك وموظفيك');
  final _heroSubCtrl = TextEditingController(
      text:
          'نظام متكامل لإدارة الحضور والمغادرة بتقنية QR وGPS الذكي.\nمتعدد الفروع، متعدد الشركات، لحظي وموثوق.');
  final _heroCtaCtrl =
      TextEditingController(text: 'ابدأ تجربتك المجانية');

  // Stats controllers
  final _statsCompaniesCtrl = TextEditingController(text: '500+');
  final _statsEmployeesCtrl = TextEditingController(text: '25K+');
  final _statsCheckinsCtrl = TextEditingController(text: '2M+');
  final _statsUptimeCtrl = TextEditingController(text: '99.9%');

  // Features controllers
  final _featuresTitleCtrl =
      TextEditingController(text: 'كل ما تحتاجه في مكان واحد');
  final _featuresSubCtrl = TextEditingController(
      text:
          'من تسجيل الحضور بالـ QR حتى الرواتب والتقارير — نظام Manzoma يغطي كل احتياجاتك');

  // Pricing controllers
  final _pricingTitleCtrl =
      TextEditingController(text: 'خطط تناسب كل شركة');
  final _starterPriceCtrl = TextEditingController(text: '49');
  final _growthPriceCtrl = TextEditingController(text: '149');
  final _proPriceCtrl = TextEditingController(text: '399');

  // CTA controllers
  final _ctaTitleCtrl = TextEditingController(
      text: 'جاهز لتحويل إدارة حضور شركتك؟');
  final _ctaSubCtrl = TextEditingController(
      text: 'انضم لأكثر من 500 شركة تثق في Manzoma');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<LandingCubit>().loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroTitleCtrl.dispose();
    _heroSubCtrl.dispose();
    _heroCtaCtrl.dispose();
    _statsCompaniesCtrl.dispose();
    _statsEmployeesCtrl.dispose();
    _statsCheckinsCtrl.dispose();
    _statsUptimeCtrl.dispose();
    _featuresTitleCtrl.dispose();
    _featuresSubCtrl.dispose();
    _pricingTitleCtrl.dispose();
    _starterPriceCtrl.dispose();
    _growthPriceCtrl.dispose();
    _proPriceCtrl.dispose();
    _ctaTitleCtrl.dispose();
    _ctaSubCtrl.dispose();
    super.dispose();
  }

  void _loadFromState(LandingLoaded state) {
    final hero = state.getSection('hero');
    final stats = state.getSection('stats');
    final features = state.getSection('features');
    final pricing = state.getSection('pricing');
    final cta = state.getSection('cta');

    if (hero['title'] != null)
      _heroTitleCtrl.text = hero['title'] as String;
    if (hero['subtitle'] != null)
      _heroSubCtrl.text = hero['subtitle'] as String;
    if (hero['cta'] != null) _heroCtaCtrl.text = hero['cta'] as String;
    if (stats['companies'] != null)
      _statsCompaniesCtrl.text = stats['companies'] as String;
    if (stats['employees'] != null)
      _statsEmployeesCtrl.text = stats['employees'] as String;
    if (stats['checkins'] != null)
      _statsCheckinsCtrl.text = stats['checkins'] as String;
    if (stats['uptime'] != null)
      _statsUptimeCtrl.text = stats['uptime'] as String;
    if (features['title'] != null)
      _featuresTitleCtrl.text = features['title'] as String;
    if (features['subtitle'] != null)
      _featuresSubCtrl.text = features['subtitle'] as String;
    if (pricing['title'] != null)
      _pricingTitleCtrl.text = pricing['title'] as String;
    if (pricing['starter_price'] != null)
      _starterPriceCtrl.text = pricing['starter_price'] as String;
    if (pricing['growth_price'] != null)
      _growthPriceCtrl.text = pricing['growth_price'] as String;
    if (pricing['pro_price'] != null)
      _proPriceCtrl.text = pricing['pro_price'] as String;
    if (cta['title'] != null) _ctaTitleCtrl.text = cta['title'] as String;
    if (cta['subtitle'] != null)
      _ctaSubCtrl.text = cta['subtitle'] as String;
  }

  void _saveAll() {
    final cubit = context.read<LandingCubit>();

    cubit.updateMultipleSections({
      'hero': {
        'title': _heroTitleCtrl.text,
        'subtitle': _heroSubCtrl.text,
        'cta': _heroCtaCtrl.text,
      },
      'stats': {
        'companies': _statsCompaniesCtrl.text,
        'employees': _statsEmployeesCtrl.text,
        'checkins': _statsCheckinsCtrl.text,
        'uptime': _statsUptimeCtrl.text,
      },
      'features': {
        'title': _featuresTitleCtrl.text,
        'subtitle': _featuresSubCtrl.text,
      },
      'pricing': {
        'title': _pricingTitleCtrl.text,
        'starter_price': _starterPriceCtrl.text,
        'growth_price': _growthPriceCtrl.text,
        'pro_price': _proPriceCtrl.text,
      },
      'cta': {
        'title': _ctaTitleCtrl.text,
        'subtitle': _ctaSubCtrl.text,
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم حفظ التغييرات',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: LandingColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandingCubit, LandingState>(
      listener: (context, state) {
        if (state is LandingLoaded) _loadFromState(state);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          appBar: _buildAppBar(context, state),
          body: _showPreview ? _buildPreview() : _buildEditor(),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, LandingState state) {
    return AppBar(
      backgroundColor: const Color(0xFF141920),
      foregroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.web_rounded,
              color: LandingColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            'تحكم في Landing Page',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        // Preview toggle
        TextButton.icon(
          onPressed: () => setState(() => _showPreview = !_showPreview),
          icon: Icon(
            _showPreview ? Icons.edit_rounded : Icons.preview_rounded,
            size: 17,
          ),
          label: Text(
            _showPreview ? 'العودة للتحرير' : 'معاينة الصفحة',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            foregroundColor: _showPreview
                ? Colors.white70
                : LandingColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        // Open in browser
        IconButton(
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          tooltip: 'فتح في تبويب جديد',
          onPressed: () => context.go('/'),
        ),
        const SizedBox(width: 8),
        // Save
        if (!_showPreview)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: ElevatedButton.icon(
              onPressed:
                  state is LandingLoading ? null : _saveAll,
              icon: state is LandingLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.save_rounded, size: 17),
              label: Text(
                'حفظ التغييرات',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: LandingColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditor() {
    return Row(
      children: [
        // Tabs panel
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // Tab bar
              Container(
                color: const Color(0xFF141920),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: LandingColors.primary,
                  labelColor: LandingColors.primary,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Hero'),
                    Tab(text: 'إحصائيات'),
                    Tab(text: 'Pricing'),
                    Tab(text: 'CTA'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _heroEditor(),
                    _statsEditor(),
                    _pricingEditor(),
                    _ctaEditor(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Split preview
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: const Color(0xFF1E2630),
                child: Row(
                  children: [
                    const Icon(Icons.preview_rounded,
                        color: LandingColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'معاينة مباشرة',
                      style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      'مزامنة تلقائية عند الحفظ',
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Expanded(child: _PreviewEmbed()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return const _PreviewEmbed();
  }

  // ─── Hero Editor ───────────────────────────────────────────
  Widget _heroEditor() {
    return _sectionScaffold(
      title: 'قسم Hero',
      icon: Icons.view_carousel_rounded,
      children: [
        _formField('العنوان الرئيسي', _heroTitleCtrl, maxLines: 2),
        _formField('النص التعريفي', _heroSubCtrl, maxLines: 3),
        _formField('نص زر CTA', _heroCtaCtrl),
      ],
    );
  }

  // ─── Stats Editor ──────────────────────────────────────────
  Widget _statsEditor() {
    return _sectionScaffold(
      title: 'الإحصائيات والأرقام',
      icon: Icons.bar_chart_rounded,
      children: [
        Row(
          children: [
            Expanded(
                child: _formField('عدد الشركات', _statsCompaniesCtrl)),
            const SizedBox(width: 16),
            Expanded(
                child: _formField('عدد الموظفين', _statsEmployeesCtrl)),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: _formField('تسجيلات الحضور', _statsCheckinsCtrl)),
            const SizedBox(width: 16),
            Expanded(
                child: _formField('معدل التشغيل', _statsUptimeCtrl)),
          ],
        ),
      ],
    );
  }

  // ─── Pricing Editor ────────────────────────────────────────
  Widget _pricingEditor() {
    return _sectionScaffold(
      title: 'قسم الأسعار',
      icon: Icons.price_change_rounded,
      children: [
        _formField('عنوان قسم الأسعار', _pricingTitleCtrl),
        const SizedBox(height: 8),
        Text(
          'أسعار الخطط (\$/شهر)',
          style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _formField('Starter', _starterPriceCtrl,
                    prefix: '\$')),
            const SizedBox(width: 16),
            Expanded(
                child: _formField('Growth', _growthPriceCtrl,
                    prefix: '\$')),
            const SizedBox(width: 16),
            Expanded(
                child:
                    _formField('Enterprise', _proPriceCtrl, prefix: '\$')),
          ],
        ),
      ],
    );
  }

  // ─── CTA Editor ────────────────────────────────────────────
  Widget _ctaEditor() {
    return _sectionScaffold(
      title: 'قسم الدعوة للعمل (CTA)',
      icon: Icons.campaign_rounded,
      children: [
        _formField('العنوان', _ctaTitleCtrl),
        _formField('النص التعريفي', _ctaSubCtrl),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────
  Widget _sectionScaffold({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LandingColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: LandingColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {int maxLines = 1, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixText: prefix,
              prefixStyle:
                  GoogleFonts.inter(color: LandingColors.primary),
              filled: true,
              fillColor: const Color(0xFF1E2630),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LandingColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LandingColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: LandingColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// معاينة مدمجة للـ Landing Page
class _PreviewEmbed extends StatelessWidget {
  const _PreviewEmbed();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        final heroContent = state is LandingLoaded
            ? state.getSection('hero')
            : <String, dynamic>{};
        final statsContent = state is LandingLoaded
            ? state.getSection('stats')
            : <String, dynamic>{};
        final featuresContent = state is LandingLoaded
            ? state.getSection('features')
            : <String, dynamic>{};
        final pricingContent = state is LandingLoaded
            ? state.getSection('pricing')
            : <String, dynamic>{};
        final ctaContent = state is LandingLoaded
            ? state.getSection('cta')
            : <String, dynamic>{};

        return Container(
          color: LandingColors.bgDark,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    import_hero_section_preview(heroContent),
                    import_stats_section_preview(statsContent),
                    import_features_section_preview(featuresContent),
                    import_pricing_section_preview(pricingContent),
                    import_cta_section_preview(ctaContent),
                  ],
                ),
              ),
              // Preview badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: LandingColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    '👁 معاينة',
                    style: GoogleFonts.inter(
                        color: LandingColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget import_hero_section_preview(Map<String, dynamic> content) {
    return _MiniHeroPreview(content: content);
  }

  Widget import_stats_section_preview(Map<String, dynamic> content) {
    return _MiniStatsPreview(content: content);
  }

  Widget import_features_section_preview(Map<String, dynamic> content) {
    return _MiniFeaturesPreview(content: content);
  }

  Widget import_pricing_section_preview(Map<String, dynamic> content) {
    return _MiniPricingPreview(content: content);
  }

  Widget import_cta_section_preview(Map<String, dynamic> content) {
    return _MiniCtaPreview(content: content);
  }
}

// ─── Mini Preview Widgets ───────────────────────────────────

class _MiniHeroPreview extends StatelessWidget {
  final Map<String, dynamic> content;
  const _MiniHeroPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.5),
          radius: 1.2,
          colors: [Color(0xFF0D2A1A), LandingColors.bgDark],
        ),
      ),
      child: Column(
        children: [
          Text(
            content['title'] as String? ?? 'إدارة الحضور بذكاء',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content['subtitle'] as String? ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: LandingColors.textMuted, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: LandingColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              content['cta'] as String? ?? 'ابدأ الآن',
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatsPreview extends StatelessWidget {
  final Map<String, dynamic> content;
  const _MiniStatsPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    final items = [
      [content['companies'] ?? '500+', 'شركة'],
      [content['employees'] ?? '25K+', 'موظف'],
      [content['checkins'] ?? '2M+', 'حضور'],
      [content['uptime'] ?? '99.9%', 'uptime'],
    ];
    return Container(
      color: LandingColors.surface,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: items
            .map((i) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: LandingColors.bgDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LandingColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(i[0] as String,
                          style: GoogleFonts.inter(
                              color: LandingColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                      Text(i[1] as String,
                          style: GoogleFonts.inter(
                              color: LandingColors.textMuted,
                              fontSize: 11)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _MiniFeaturesPreview extends StatelessWidget {
  final Map<String, dynamic> content;
  const _MiniFeaturesPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingColors.bgLight,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            content['title'] as String? ?? 'كل ما تحتاجه في مكان واحد',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: LandingColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Icons.qr_code_scanner_rounded,
              Icons.location_on_rounded,
              Icons.account_tree_rounded,
              Icons.payments_rounded,
              Icons.insert_chart_rounded,
              Icons.security_rounded,
            ]
                .map((icon) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Icon(icon,
                          color: LandingColors.primary, size: 22),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniPricingPreview extends StatelessWidget {
  final Map<String, dynamic> content;
  const _MiniPricingPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {'name': 'Starter', 'price': content['starter_price'] ?? '49'},
      {'name': 'Growth', 'price': content['growth_price'] ?? '149'},
      {'name': 'Enterprise', 'price': content['pro_price'] ?? '399'},
    ];
    return Container(
      color: LandingColors.bgDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            content['title'] as String? ?? 'خطط الأسعار',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: plans.map((p) {
              final isGrowth = p['name'] == 'Growth';
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isGrowth
                        ? LandingColors.primary
                        : LandingColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LandingColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(p['name'] as String,
                          style: GoogleFonts.inter(
                              color: isGrowth ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      Text('\$${p["price"]}/م',
                          style: GoogleFonts.inter(
                              color: isGrowth
                                  ? Colors.black87
                                  : LandingColors.textMuted,
                              fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniCtaPreview extends StatelessWidget {
  final Map<String, dynamic> content;
  const _MiniCtaPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingColors.surface,
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D3B27), Color(0xFF091A13)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: LandingColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              content['title'] as String? ??
                  'جاهز لتحويل إدارة حضور شركتك؟',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              content['subtitle'] as String? ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: LandingColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: LandingColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'ابدأ الآن ←',
                style: GoogleFonts.inter(
                    color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
