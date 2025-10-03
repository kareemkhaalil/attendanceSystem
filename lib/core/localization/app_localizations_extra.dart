// lib/core/localization/app_localizations_extra.dart
import 'package:manzoma/core/localization/app_localizations.dart';

/// Extra translations map (nav keys + common extras)
const Map<String, Map<String, String>> _extraLocalizedValues = {
  'en': {
    // Navigation
    'nav_dashboard': 'Dashboard',
    'nav_attendance': 'Attendance',
    'nav_attendance_dashboard': 'Attendance Dashboard',
    'nav_attendance_check': 'Check In/Out',
    'nav_attendance_history': 'Attendance History',
    'nav_attendance_reports': 'Attendance Reports',
    'nav_attendance_rules': 'Attendance Rules',
    'nav_payroll': 'Payroll',
    'nav_payroll_my': 'My Payroll',
    'nav_payroll_management': 'Payroll Management',
    'nav_payroll_settings': 'Payroll Settings',
    'nav_employee_salary_structure': 'Employee Salary Structure',
    'nav_payroll_rules_settings': 'Payroll Rules & Settings',
    'nav_branches': 'Branches',
    'nav_branches_all': 'All Branches',
    'nav_branches_add': 'Add Branch',
    'nav_clients': 'Clients',
    'nav_clients_all': 'All Clients',
    'nav_clients_add': 'Add Client',
    'nav_users': 'Users',
    'nav_users_all': 'All Users',
    'nav_users_add': 'Add User',
    'nav_reports': 'Reports',
    'nav_reports_attendance': 'Attendance Reports',
    'nav_reports_payroll': 'Payroll Reports',
    'nav_settings': 'Settings',
    'nav_settings_profile': 'Profile',
    'nav_settings_company': 'Company Settings',
    // add more keys here if you want
  },
  'ar': {
    // Navigation (Arabic)
    'nav_dashboard': 'لوحة التحكم',
    'nav_attendance': 'الحضور',
    'nav_attendance_dashboard': 'لوحة الحضور',
    'nav_attendance_check': 'تسجيل دخول/خروج',
    'nav_attendance_history': 'سجل الحضور',
    'nav_attendance_reports': 'تقارير الحضور',
    'nav_attendance_rules': 'قواعد الحضور',
    'nav_payroll': 'الرواتب',
    'nav_payroll_my': 'راتبي',
    'nav_payroll_management': 'إدارة الرواتب',
    'nav_payroll_settings': 'إعدادات الرواتب',
    'nav_employee_salary_structure': 'هيكل رواتب الموظفين',
    'nav_payroll_rules_settings': 'قواعد وإعدادات الرواتب',
    'nav_branches': 'الفروع',
    'nav_branches_all': 'كل الفروع',
    'nav_branches_add': 'إضافة فرع',
    'nav_clients': 'العملاء',
    'nav_clients_all': 'كل العملاء',
    'nav_clients_add': 'إضافة عميل',
    'nav_users': 'المستخدمين',
    'nav_users_all': 'كل المستخدمين',
    'nav_users_add': 'إضافة مستخدم',
    'nav_reports': 'التقارير',
    'nav_reports_attendance': 'تقارير الحضور',
    'nav_reports_payroll': 'تقارير الرواتب',
    'nav_settings': 'الإعدادات',
    'nav_settings_profile': 'الملف الشخصي',
    'nav_settings_company': 'إعدادات الشركة',
    // add more keys here if you want
  },
};

/// Extension that first checks the extra map, then falls back to existing tr().
extension AppLocalizationsExtra on AppLocalizations {
  /// ترجمة: يفحص القاموس الموسع أولاً ثم fallback إلى tr(key) الموجود في الملف القديم.
  String translate(String key) {
    final code = locale.languageCode;
    final value = _extraLocalizedValues[code]?[key];
    if (value != null) return value;
    // fallback to original implementation (keeps old behavior)
    return tr(key);
  }
}
