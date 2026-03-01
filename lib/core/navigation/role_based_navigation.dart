import 'package:flutter/material.dart';
import 'package:manzoma/core/enums/user_role.dart';

class NavigationItem {
  final String titleKey; // مفتاح الترجمة
  final String route;
  final IconData icon;
  final List<UserRole> allowedRoles;
  final List<NavigationItem>? subItems;

  const NavigationItem({
    required this.titleKey,
    required this.route,
    required this.icon,
    required this.allowedRoles,
    this.subItems,
  });
}

class RoleBasedNavigation {
  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      titleKey: 'nav_dashboard',
      route: '/dashboard',
      icon: Icons.dashboard,
      allowedRoles: [UserRole.superAdmin, UserRole.cad, UserRole.employee],
    ),
    NavigationItem(
      titleKey: 'nav_attendance',
      route: '/attendance',
      icon: Icons.access_time,
      allowedRoles: [UserRole.superAdmin, UserRole.cad, UserRole.employee],
      subItems: [
        NavigationItem(
          titleKey: 'nav_attendance_check',
          route: '/attendance',
          icon: Icons.login,
          allowedRoles: [UserRole.employee],
        ),
        NavigationItem(
          titleKey: 'nav_attendance_history',
          route: '/attendance/history',
          icon: Icons.history,
          allowedRoles: [UserRole.superAdmin, UserRole.cad, UserRole.employee],
        ),
        NavigationItem(
          titleKey: 'nav_attendance_dashboard',
          route: '/attendance/dashboard',
          icon: Icons.dashboard,
          allowedRoles: [
            UserRole.superAdmin,
            UserRole.cad,
          ],
        ),
        NavigationItem(
          titleKey: 'nav_attendance_rules',
          route: '/attendance/rules',
          icon: Icons.rule,
          allowedRoles: [
            UserRole.superAdmin,
            UserRole.cad,
          ],
        ),
        NavigationItem(
          titleKey: 'nav_attendance_reports',
          route: '/attendance/report',
          icon: Icons.assessment,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_payroll',
      route: '/payroll',
      icon: Icons.payment,
      allowedRoles: [UserRole.superAdmin, UserRole.cad, UserRole.employee],
      subItems: [
        NavigationItem(
          titleKey: 'nav_payroll_my',
          route: '/payroll',
          icon: Icons.account_balance_wallet,
          allowedRoles: [UserRole.employee],
        ),
        NavigationItem(
          titleKey: 'nav_payroll_management',
          route: '/payroll',
          icon: Icons.manage_accounts,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
        NavigationItem(
          titleKey: 'nav_payroll_rules_settings',
          route: '/payroll/rules',
          icon: Icons.settings,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
        NavigationItem(
          titleKey: 'nav_employee_salary_structure',
          route: '/payroll/employees',
          icon: Icons.settings,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_branches',
      route: '/branches',
      icon: Icons.business,
      allowedRoles: [UserRole.superAdmin, UserRole.cad],
      subItems: [
        NavigationItem(
          titleKey: 'nav_branches_all',
          route: '/branches',
          icon: Icons.location_city,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
        NavigationItem(
          titleKey: 'nav_branches_add',
          route: '/branches/create',
          icon: Icons.add_location,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_clients',
      route: '/clients',
      icon: Icons.business_center,
      allowedRoles: [UserRole.superAdmin],
      subItems: [
        NavigationItem(
          titleKey: 'nav_clients_all',
          route: '/clients',
          icon: Icons.view_list,
          allowedRoles: [UserRole.superAdmin],
        ),
        NavigationItem(
          titleKey: 'nav_clients_add',
          route: '/clients/create',
          icon: Icons.add_business,
          allowedRoles: [UserRole.superAdmin],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_users',
      route: '/users',
      icon: Icons.people,
      allowedRoles: [UserRole.superAdmin, UserRole.cad],
      subItems: [
        NavigationItem(
          titleKey: 'nav_users_all',
          route: '/users',
          icon: Icons.group,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
        NavigationItem(
          titleKey: 'nav_users_add',
          route: '/users/create',
          icon: Icons.person_add,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_reports',
      route: '/reports',
      icon: Icons.analytics,
      allowedRoles: [UserRole.superAdmin, UserRole.cad],
      subItems: [
        NavigationItem(
          titleKey: 'nav_reports_attendance',
          route: '/reports/attendance',
          icon: Icons.schedule,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
        NavigationItem(
          titleKey: 'nav_reports_payroll',
          route: '/reports/payroll',
          icon: Icons.money,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
    NavigationItem(
      titleKey: 'nav_landing_cms',
      route: '/admin/landing',
      icon: Icons.web_rounded,
      allowedRoles: [UserRole.superAdmin],
    ),
    NavigationItem(
      titleKey: 'admin_transactions',
      route: '/admin/transactions',
      icon: Icons.receipt_long_rounded,
      allowedRoles: [UserRole.superAdmin],
    ),
    NavigationItem(
      titleKey: 'nav_settings',
      route: '/settings',
      icon: Icons.settings,
      allowedRoles: [UserRole.superAdmin, UserRole.cad],
      subItems: [
        NavigationItem(
          titleKey: 'nav_settings_profile',
          route: '/settings/profile',
          icon: Icons.person,
          allowedRoles: [UserRole.superAdmin, UserRole.cad, UserRole.employee],
        ),
        NavigationItem(
          titleKey: 'nav_settings_company',
          route: '/settings/company',
          icon: Icons.business_center,
          allowedRoles: [UserRole.superAdmin, UserRole.cad],
        ),
      ],
    ),
  ];

  static List<NavigationItem> getNavigationItemsForRole(UserRole role) {
    return navigationItems.where((item) {
      return item.allowedRoles.contains(role);
    }).map((item) {
      if (item.subItems != null) {
        final filteredSubItems = item.subItems!
            .where((subItem) => subItem.allowedRoles.contains(role))
            .toList();
        return NavigationItem(
          titleKey: item.titleKey,
          route: item.route,
          icon: item.icon,
          allowedRoles: item.allowedRoles,
          subItems: filteredSubItems.isNotEmpty ? filteredSubItems : null,
        );
      }
      return item;
    }).toList();
  }

  static bool canAccessRoute(String route, UserRole role) {
    for (final item in navigationItems) {
      if (item.route == route && item.allowedRoles.contains(role)) {
        return true;
      }
      if (item.subItems != null) {
        for (final subItem in item.subItems!) {
          if (subItem.route == route && subItem.allowedRoles.contains(role)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
