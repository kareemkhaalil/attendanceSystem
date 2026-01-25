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

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWelcomeMessage(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        ],
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
        return 'Manage your team ';
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
