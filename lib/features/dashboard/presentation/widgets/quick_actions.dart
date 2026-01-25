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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => _buildActionItem(context, action)),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, QuickActionData action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(action.route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          action.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
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
