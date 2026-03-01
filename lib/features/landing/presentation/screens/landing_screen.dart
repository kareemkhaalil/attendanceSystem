import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/landing_cubit.dart';
import '../cubit/landing_state.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/features_section.dart';
import '../widgets/pricing_section.dart';
import '../widgets/cta_footer_section.dart';
import '../widgets/landing_theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LandingCubit>().loadContent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingColors.bgDark,
      body: BlocBuilder<LandingCubit, LandingState>(
        builder: (context, state) {
          // Default content — used when loading or no DB content
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

          return Stack(
            children: [
              // Scrollable content
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Navbar space
                    const SizedBox(height: 72),
                    // Hero
                    HeroSection(content: heroContent),
                    // Stats
                    StatsSection(content: statsContent),
                    // Features
                    FeaturesSection(content: featuresContent),
                    // Pricing
                    PricingSection(content: pricingContent),
                    // CTA
                    CtaSection(content: ctaContent),
                    // Footer
                    const FooterSection(),
                  ],
                ),
              ),
              // Fixed Navbar on top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: const LandingNavbar(),
              ),
              // Loading indicator
              if (state is LandingLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: LandingColors.primary,
                    minHeight: 2,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
