import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/enums/user_role.dart';

class QuickActions extends StatelessWidget {
  final UserRole userRole;

  const QuickActions({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _getActionsForRole();
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...actions.map((action) => _ActionTile(action: action)),
          ],
        ),
      ),
    );
  }

  List<QuickActionData> _getActionsForRole() {
    switch (userRole) {
      case UserRole.superAdmin:
        return [
          QuickActionData(
            title: 'Add New Client',
            subtitle: 'Register a new company',
            icon: Icons.business_center,
            color: Colors.blue,
            route: '/clients/create',
          ),
          QuickActionData(
            title: 'System Reports',
            subtitle: 'View system analytics',
            icon: Icons.analytics,
            color: Colors.green,
            route: '/reports',
          ),
          QuickActionData(
            title: 'User Management',
            subtitle: 'Manage all users',
            icon: Icons.people,
            color: Colors.orange,
            route: '/users',
          ),
          QuickActionData(
            title: 'Client Management',
            subtitle: 'View all clients',
            icon: Icons.business,
            color: Colors.purple,
            route: '/clients',
          ),
        ];

      case UserRole.cad:
        return [
          QuickActionData(
            title: 'Add Employee',
            subtitle: 'Register new team member',
            icon: Icons.person_add,
            color: Colors.blue,
            route: '/users/create',
          ),
          QuickActionData(
            title: 'Add Branch',
            subtitle: 'Register new branch',
            icon: Icons.business,
            color: Colors.green,
            route: '/branches/create',
          ),
          QuickActionData(
            title: 'Attendance Report',
            subtitle: 'View team attendance',
            icon: Icons.schedule,
            color: Colors.orange,
            route: '/reports',
          ),
          QuickActionData(
            title: 'Payroll Processing',
            subtitle: 'Process monthly payroll',
            icon: Icons.payment,
            color: Colors.purple,
            route: '/payroll',
          ),
        ];

      case UserRole.branchManager:
        return [
          QuickActionData(
            title: 'Add Employee',
            subtitle: 'Register new team member',
            icon: Icons.person_add,
            color: Colors.blue,
            route: '/users/create',
          ),
          QuickActionData(
            title: 'Add Branch',
            subtitle: 'Register new branch',
            icon: Icons.business,
            color: Colors.green,
            route: '/branches/create',
          ),
          QuickActionData(
            title: 'Attendance Report',
            subtitle: 'View team attendance',
            icon: Icons.schedule,
            color: Colors.orange,
            route: '/reports',
          ),
          QuickActionData(
            title: 'Payroll Processing',
            subtitle: 'Process monthly payroll',
            icon: Icons.payment,
            color: Colors.purple,
            route: '/payroll',
          ),
        ];

      case UserRole.employee:
        return [
          QuickActionData(
            title: 'Check In/Out',
            subtitle: 'Record your attendance',
            icon: Icons.access_time,
            color: Colors.blue,
            route: '/attendance',
          ),
          QuickActionData(
            title: 'View Payslip',
            subtitle: 'Check your salary details',
            icon: Icons.receipt,
            color: Colors.green,
            route: '/payroll',
          ),
          QuickActionData(
            title: 'Attendance History',
            subtitle: 'View your attendance record',
            icon: Icons.history,
            color: Colors.orange,
            route: '/attendance',
          ),
          QuickActionData(
            title: 'Update Profile',
            subtitle: 'Edit your information',
            icon: Icons.person,
            color: Colors.purple,
            route: '/profile',
          ),
        ];
    }
  }
}

class _ActionTile extends StatelessWidget {
  final QuickActionData action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleBorder = theme.dividerColor.withOpacity(0.18);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(action.route),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: subtleBorder),
              gradient: LinearGradient(
                colors: [
                  action.color.withOpacity(0.06),
                  theme.cardColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.25)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: action.color.withOpacity(0.2)),
                    ),
                    child: Icon(action.icon, color: action.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(action.title,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        if (action.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(action.subtitle!,
                              style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: theme.dividerColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickActionData {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String route;

  QuickActionData({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
