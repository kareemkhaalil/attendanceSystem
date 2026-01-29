import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:manzoma/core/di/injection_container.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/features/clients/domain/usecases/get_clients_usecase.dart';
import 'package:manzoma/features/users/domain/usecases/get_users_usecase.dart';
import 'package:manzoma/features/dashboard/presentation/cubit/activite_cubit.dart';
import 'package:manzoma/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../widgets/dashboard_stats.dart';
import '../widgets/recent_activities.dart';
import '../widgets/quick_actions.dart';

// استورد الـ ThemeExtension بتاع الجلاس (عدّل المسار حسب مشروعك)
import 'package:manzoma/core/theme/app_themes.dart'; // يحتوي GlassTheme

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  UserRole _userRole = UserRole.employee;
  late final DashboardCubit _dashboardCubit;
  late final ActivityCubit _activityCubit;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // تحسين UX: نعرض آخر تحديث
  DateTime? _lastUpdated;

  // تحسين بسيط: فلتر نطاق زمني للشكل العام (UI فقط)
  String _selectedRange = 'Today'; // Today - This Week - This Month

  @override
  void initState() {
    super.initState();
    _loadUserRole();

    _dashboardCubit = DashboardCubit(
      getClientsUseCase: getIt<GetClientsUseCase>(),
      getUsersUseCase: getIt<GetUsersUseCase>(),
    )..getStats();

    _activityCubit = ActivityCubit()..getRecentActivities();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _lastUpdated = DateTime.now();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _activityCubit.close();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final user = SharedPrefHelper.getUser();
    if (user != null) {
      setState(() => _userRole = user.role);
      if (user.role == UserRole.employee) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/employee/home');
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    // نفس اللوجيك: بنعمل Refresh للـ Cubits
    _dashboardCubit.getStats();
    _activityCubit.getRecentActivities();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _lastUpdated = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _activityCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(context),
                    const SizedBox(height: 24),
                    DashboardStats(userRole: _userRole),
                    const SizedBox(height: 24),
                    isMobile
                        ? Column(
                            children: [
                              QuickActions(userRole: _userRole),
                              const SizedBox(height: 24),
                              RecentActivities(userRole: _userRole),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: QuickActions(userRole: _userRole),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: RecentActivities(userRole: _userRole),
                              ),
                            ],
                          )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
          body: Stack(
            children: [
              _BackgroundLayer(), // الجريدينت + البلوبس
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 800;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                            24, kToolbarHeight + 24, 24, 24),
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderGlassCard(
                              userRole: _userRole,
                              lastUpdated: _lastUpdated,
                              selectedRange: _selectedRange,
                              onRangeChange: (val) =>
                                  setState(() => _selectedRange = val),
                              onExportTap: () {
                                // Placeholder UX action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Export coming soon...")),
                                );
                              },
                              onRefresh: _onRefresh,
                              getWelcomeMessage: _getWelcomeMessage,
                              getWelcomeSubtitle: _getWelcomeSubtitle,
                              getWelcomeIcon: _getWelcomeIcon,
                            ),
                            const SizedBox(height: 24),
                            // نفس اللوجيك للـ Widgets
                            DashboardStats(userRole: _userRole),
                            const SizedBox(height: 24),
                            isMobile
                                ? Column(
                                    children: [
                                      QuickActions(userRole: _userRole),
                                      const SizedBox(height: 24),
                                      RecentActivities(userRole: _userRole),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child:
                                            QuickActions(userRole: _userRole),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 2,
                                        child: RecentActivities(
                                            userRole: _userRole),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getWelcomeSubtitle(),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(
            _getWelcomeIcon(),
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  String _getWelcomeMessage() {
    switch (_userRole) {
      case UserRole.superAdmin:
        return 'Welcome, Super Admin!';
      case UserRole.cad:
        return 'Welcome, Admin!';
      case UserRole.branchManager:
        return 'Welcome, Supervisor!';
      case UserRole.employee:
        return 'Welcome back!';
    }
  }

  String _getWelcomeSubtitle() {
    switch (_userRole) {
      case UserRole.superAdmin:
        return 'Manage all clients and system operations';
      case UserRole.cad:
        return 'Manage your team and company operations';
      case UserRole.branchManager:
        return 'Manage your team';
      case UserRole.employee:
        return 'Track your attendance and info';
    }
  }

  IconData _getWelcomeIcon() {
    switch (_userRole) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.cad:
        return Icons.business_center;
      case UserRole.branchManager:
        return Icons.supervisor_account;
      case UserRole.employee:
        return Icons.person;
    }
  }
}

/* =========================
   خلفية مودرن بلمسات متدرجة + Blobs
   ========================= */
class _BackgroundLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [g.bgStart, g.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
            top: -60, right: -30, child: _Blob(color: g.blob1, size: 200)),
        Positioned(
            top: 120, left: -40, child: _Blob(color: g.blob2, size: 180)),
        Positioned(
            bottom: -40, right: -20, child: _Blob(color: g.blob3, size: 160)),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}

/* =========================
   Header Glass Card: ترحيب + رينج + آخر تحديث + CTA
   ========================= */
class _HeaderGlassCard extends StatelessWidget {
  final UserRole userRole;
  final DateTime? lastUpdated;
  final String selectedRange;
  final ValueChanged<String> onRangeChange;
  final VoidCallback onExportTap;
  final VoidCallback onRefresh;

  final String Function() getWelcomeMessage;
  final String Function() getWelcomeSubtitle;
  final IconData Function() getWelcomeIcon;

  const _HeaderGlassCard({
    required this.userRole,
    required this.lastUpdated,
    required this.selectedRange,
    required this.onRangeChange,
    required this.onExportTap,
    required this.onRefresh,
    required this.getWelcomeMessage,
    required this.getWelcomeSubtitle,
    required this.getWelcomeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    const ranges = ["Today", "This Week", "This Month"];

    final dateStr =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    final last = lastUpdated != null
        ? "${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}"
        : "--:--";

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: g.glass,
            border: Border.all(color: g.glassBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 780;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // السطر العلوي: ترحيب + أيقونة الدور + الوقت
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(getWelcomeMessage(),
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: g.onGlassPrimary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(getWelcomeIcon(),
                                    size: 18, color: g.onGlassSecondary),
                                const SizedBox(width: 6),
                                Text(getWelcomeSubtitle(),
                                    style:
                                        TextStyle(color: g.onGlassSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 16, color: g.onGlassSecondary),
                                const SizedBox(width: 6),
                                Text("Today: $dateStr",
                                    style:
                                        TextStyle(color: g.onGlassSecondary)),
                                const SizedBox(width: 12),
                                Icon(Icons.update,
                                    size: 16, color: g.onGlassSecondary),
                                const SizedBox(width: 6),
                                Text("Last updated: $last",
                                    style:
                                        TextStyle(color: g.onGlassSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(width: 12),
                        _HeaderActionButtons(
                            onExportTap: onExportTap, onRefresh: onRefresh),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  // شريط تقدم ديكوري (Brand accent)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 0.78,
                      minHeight: 6,
                      backgroundColor: g.glassBorder,
                      valueColor: AlwaysStoppedAnimation(g.accent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // فلاتر الرينج + CTA للموبايل
                  Row(
                    children: [
                      Wrap(
                        spacing: 8,
                        children: ranges
                            .map(
                              (r) => ChoiceChip(
                                label: Text(r),
                                selected: selectedRange == r,
                                onSelected: (_) => onRangeChange(r),
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundColor: g.glass,
                                labelStyle: TextStyle(
                                  color: selectedRange == r
                                      ? Colors.white
                                      : g.onGlassSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: StadiumBorder(
                                    side: BorderSide(color: g.glassBorder)),
                              ),
                            )
                            .toList(),
                      ),
                      const Spacer(),
                      if (isNarrow)
                        _HeaderActionButtons(
                            onExportTap: onExportTap, onRefresh: onRefresh),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButtons extends StatelessWidget {
  final VoidCallback onExportTap;
  final VoidCallback onRefresh;

  const _HeaderActionButtons({
    required this.onExportTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassIconButton(
          icon: Icons.download_rounded,
          label: "Export",
          onTap: onExportTap,
        ),
        const SizedBox(width: 8),
        _GlassIconButton(
          icon: Icons.refresh_rounded,
          label: "Refresh",
          onTap: onRefresh,
          gradient: LinearGradient(
              colors: [g.accent, Theme.of(context).colorScheme.secondary]),
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  const _GlassIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final gr = gradient ??
        LinearGradient(
          colors: [
            g.onGlassSecondary.withOpacity(0.6),
            g.onGlassSecondary.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gr,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
