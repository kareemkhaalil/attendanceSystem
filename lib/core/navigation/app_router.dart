import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/localization/app_localizations.dart';
import 'package:manzoma/core/localization/cubit/locale_cubit.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import 'package:manzoma/features/attendance/presentation/screens/attendance_rule_screen.dart';
import 'package:manzoma/features/branches/domain/entities/branch_entity.dart';
import 'package:manzoma/features/branches/presentation/screens/branches_edit_screen.dart';
import 'package:manzoma/features/employee/presentation/screens/attendance_screen.dart';
import 'package:manzoma/features/employee/presentation/screens/employee_home_screen.dart';
import 'package:manzoma/features/payroll/presentation/screens/employee_salary.dart';
import 'package:manzoma/features/payroll/presentation/screens/employee_salary_screen.dart';
import 'package:manzoma/features/payroll/presentation/screens/payroll_rules_screen.dart';
import 'package:manzoma/features/payroll/presentation/screens/payroll_settings_screen.dart';
import 'package:manzoma/features/payroll/presentation/screens/employee_salary_profile_screen.dart';
import 'package:manzoma/features/users/domain/entities/user_entity.dart';
import 'package:manzoma/features/users/presentation/screens/users_edit_screen.dart';
import 'package:manzoma/shared/widgets/app_sidebar.dart';
import 'package:manzoma/shared/widgets/app_topbar.dart';
import 'package:manzoma/shared/widgets/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/payroll/presentation/screens/payroll_screen.dart';
import '../../features/branches/presentation/screens/branches_screen.dart';
import '../../features/branches/presentation/screens/branches_create_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/users/presentation/screens/users_create_screen.dart';
import 'package:manzoma/features/reports/presentation/screens/reports_screen.dart';
import 'package:manzoma/features/clients/presentation/screens/clients_screen.dart';
import 'package:manzoma/features/clients/presentation/screens/clients_create_screen.dart';
import 'package:manzoma/features/landing/presentation/screens/landing_screen.dart';
import 'package:manzoma/features/landing/presentation/screens/landing_admin_screen.dart';
import 'package:manzoma/features/landing/presentation/cubit/landing_cubit.dart';
import 'package:manzoma/features/payment/presentation/screens/plan_selection_screen.dart';
import 'package:manzoma/features/payment/presentation/screens/admin_transactions_screen.dart';
import 'package:manzoma/features/payment/presentation/screens/subscription_expired_screen.dart';
import 'package:manzoma/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_state.dart';
import 'package:manzoma/core/di/injection_container.dart';
import '../navigation/route_names.dart';
import '../navigation/navigation_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final user = SharedPrefHelper.getUser();
      final loggedIn = user != null;
      final goingToLogin = state.matchedLocation == RouteNames.login;
      final goingToSplash = state.matchedLocation == RouteNames.splash;

      // Splash يشتغل دايمًا
      if (goingToSplash) return null;

      // Landing Page متاحة للجميع
      if (state.matchedLocation == '/') return null;

      if (!loggedIn && !goingToLogin) return RouteNames.login;
      if (loggedIn && goingToLogin) return RouteNames.dashboard;

      // حماية حسب الدور
      final role = user?.role ?? UserRole.employee;
      final loc = state.matchedLocation;

      // SuperAdmin فقط يشوف العملاء ولوحة التحكم في اللاندنج
      if (role != UserRole.superAdmin) {
        if (loc == RouteNames.clients ||
            loc == RouteNames.createClient ||
            loc.startsWith('/clients/') ||
            loc == '/admin/landing') {
          return RouteNames.dashboard;
        }
      }

      // الموظف يمنع من بعض الصفحات
      if (role == UserRole.employee) {
        final restrictedForEmployee = <String>{
          RouteNames.branches,
          RouteNames.createBranch,
          RouteNames.users,
          RouteNames.createUser,
          RouteNames.reports,
        };
        if (restrictedForEmployee.contains(loc) ||
            loc == '/branches/edit' ||
            loc == '/users/edit') {
          return RouteNames.dashboard;
        }
      }

      // 3. Subscription Guard
      if (loggedIn && role != UserRole.superAdmin) {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          final sub = authState.subscription;
          final isSubActive = sub?.isActive ?? false;

          // If subscription expired or none, force plans/expired screen
          if (!isSubActive) {
            if (loc != '/subscription/plans' && loc != '/subscription/expired') {
              return '/subscription/expired';
            }
          } else if (sub != null && sub.plan != null) {
            // Check feature flags (Modules)
            final plan = sub.plan!;
            
            // Payroll Module Guard
            if (loc.startsWith('/payroll') && !plan.hasPayroll) {
              return RouteNames.dashboard; // Or a "Feature Locked" screen
            }
            
            // Reports Module Guard
            if (loc.startsWith('/reports') && !plan.hasReports) {
              return RouteNames.dashboard;
            }
          }
        }
      }

      return null;
    },
    routes: [
      // Landing Page (public)
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LandingCubit>(),
          child: const LandingScreen(),
        ),
      ),

      // Landing Admin CMS (super_admin only)
      GoRoute(
        path: '/admin/landing',
        name: 'landingAdmin',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LandingCubit>(),
          child: const LandingAdminScreen(),
        ),
      ),

       // Admin Transactions (super_admin only)
      GoRoute(
        path: '/admin/transactions',
        name: 'adminTransactions',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PaymentCubit>(),
          child: const AdminTransactionsScreen(),
        ),
      ),

      // Subscription Plans
      GoRoute(
        path: '/subscription/plans',
        name: 'subscriptionPlans',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PaymentCubit>(),
          child: const PlanSelectionScreen(),
        ),
      ),

      // Subscription Expired
      GoRoute(
        path: '/subscription/expired',
        name: 'subscriptionExpired',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PaymentCubit>(),
          child: const SubscriptionExpiredScreen(),
        ),
      ),

      // Splash/Login
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Dashboard
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) =>
            const MainAppShell(child: DashboardScreen()),
      ),

      // Attendance
      GoRoute(
        path: RouteNames.attendance,
        name: 'attendance',
        builder: (context, state) => MainAppShell(child: AttendanceScreen()),
      ),
      GoRoute(
        path: RouteNames.attendanceDashboard,
        name: 'attendanceDashboard',
        builder: (context, state) =>
            const MainAppShell(child: AttendanceDashboardPage()),
      ),
      GoRoute(
        path: RouteNames.attendanceRule,
        name: 'attendanceRule',
        builder: (context, state) =>
            const MainAppShell(child: AttendanceRulesPage()),
      ),

      // Payroll
      GoRoute(
        path: RouteNames.payroll,
        name: 'payroll',
        builder: (context, state) => const MainAppShell(child: PayrollScreen()),
      ),
      GoRoute(
        path: RouteNames.payrollRules,
        builder: (context, state) =>
            const MainAppShell(child: PayrollRulesScreen()),
      ),
      GoRoute(
        path: RouteNames.employeePayroll,
        name: 'employeePayroll',
        builder: (context, state) =>
            const MainAppShell(child: EmployeePayrollPage()),
      ),
      GoRoute(
        path: RouteNames.employeeSalary,
        name: 'employeeSalary',
        builder: (context, state) {
          final extra = state.extra as Map?;
          if (extra == null ||
              extra['tenantId'] == null ||
              extra['employees'] == null) {
            return const Scaffold(
              body: Center(child: Text("❌ بيانات ناقصة لعرض المرتبات")),
            );
          }
          return MainAppShell(
            child: EmployeeSalaryScreen(
              tenantId: extra['tenantId'],
              employees: List.from(extra['employees']),
            ),
          );
        },
      ),
      GoRoute(
        path: '/payroll/settings',
        name: 'payrollSettings',
        builder: (context, state) =>
            const MainAppShell(child: PayrollSettingsScreen()),
      ),
      GoRoute(
        path: '/payroll/employee-profile',
        name: 'employeeSalaryProfile',
        builder: (context, state) {
          final employee = state.extra as UserEntity;
          return MainAppShell(
              child: EmployeeSalaryProfileScreen(employee: employee));
        },
      ),

      // Clients (SuperAdmin only)
      GoRoute(
        path: RouteNames.clients,
        name: 'clients',
        builder: (context, state) => const MainAppShell(child: ClientsScreen()),
      ),
      GoRoute(
        path: RouteNames.createClient,
        name: 'createClient',
        builder: (context, state) =>
            const MainAppShell(child: ClientsCreateScreen()),
      ),
      GoRoute(
        path: '/clients/:id/edit',
        name: 'editClient',
        builder: (context, state) {
          final client = state.extra;
          return MainAppShell(child: ClientsCreateScreen(client: client));
        },
      ),

      // Users
      GoRoute(
        path: RouteNames.users,
        name: 'users',
        builder: (context, state) => const MainAppShell(child: UsersScreen()),
      ),
      GoRoute(
        path: RouteNames.createUser,
        name: 'createUser',
        builder: (context, state) =>
            const MainAppShell(child: UsersCreateScreen()),
      ),
      GoRoute(
        path: '/users/edit',
        builder: (context, state) {
          final widget = state.extra as UsersEditScreen;
          return widget;
        },
      ),

      // Branches
      GoRoute(
        path: RouteNames.branches,
        name: 'branches',
        builder: (context, state) =>
            const MainAppShell(child: BranchesScreen()),
      ),
      GoRoute(
        path: RouteNames.createBranch,
        name: 'createBranch',
        builder: (context, state) =>
            const MainAppShell(child: BranchesCreateScreen()),
      ),
      GoRoute(
        path: '/branches/edit',
        builder: (context, state) {
          final branch = state.extra as BranchEntity;
          return BranchesEditScreen(editingBranch: branch);
        },
      ),

      // Reports
      GoRoute(
        path: RouteNames.reports,
        name: 'reports',
        builder: (context, state) => const MainAppShell(child: ReportsScreen()),
      ),

      // Employee app
      GoRoute(
        path: "/employee/home",
        builder: (context, state) => const EmployeeHomeScreen(),
      ),
      GoRoute(
        path: "/employee/attendance",
        builder: (context, state) => const AttendanceEmployeeScreen(),
      ),
    ],
  );
}

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({
    super.key,
    required this.child,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  UserRole _userRole = UserRole.employee;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = SharedPrefHelper.getUser();
    if (user != null) {
      setState(() {
        _userRole = user.role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 768;
      final isLtr = Directionality.of(context) == TextDirection.ltr;
      final localeCubit = context.watch<LocaleCubit>();
      final isEnglish = localeCubit.state.locale.languageCode == "en";

      if (isMobile) {
        // 📱 Mobile Layout
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppTopBar(
            title: AppLocalizations.off(context).dashboard,
          ),
          drawer: Drawer(
            child: AppSidebar(
              isMobile: true,
              onItemTap: () => Navigator.of(context).pop(),
            ),
          ),
          body: widget.child,
        );
      } else {
        // 💻 Desktop Layout
        return Scaffold(
          body: Row(
            children: [
              if (isEnglish || !isEnglish) const AppSidebar(isMobile: false),
              Expanded(
                child: Column(
                  children: [
                    AppTopBar(title: AppLocalizations.off(context).dashboard),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}
