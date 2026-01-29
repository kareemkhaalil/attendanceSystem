class RouteNames {
  // Splash Route
  static const String splash = '/';

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';

  // Dashboard Routes
  static const String dashboard = '/dashboard';

  // Attendance Routes
  static const String attendance = '/attendance';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceReport = '/attendance/report';
  static const String attendanceDashboard = '/attendance/dashboard';
  static const String attendanceRule = '/attendance/rules';

  // Payroll Routes
  static const String payroll = '/payroll'; // Dashboard
  static const String payrollHistory = '/payroll/history';
  static const String payrollRules = '/payroll/rules'; // بدل settings
  static const String employeePayroll = '/payroll/employees'; // Multi-select
  static const String employeeSalary = '/payroll/employees/salary'; // Details

  // Branches Routes (Super Admin & CAD only)
  static const String branches = '/branches';
  static const String branchDetails = '/branches/:id';
  static const String createBranch = '/branches/create';

  // Users Routes (Super Admin & CAD only)
  static const String users = '/users';
  static const String userDetails = '/users/:id';
  static const String createUser = '/users/create';

  // Clients Routes (Super Admin only)
  static const String clients = '/clients';
  static const String clientDetails = '/clients/:id';
  static const String createClient = '/clients/create';

  // Reports Routes
  static const String reports = '/reports';
  static const String attendanceReports = '/reports/attendance';
  static const String payrollReports = '/reports/payroll';

  // Settings Routes
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String companySettings = '/settings/company';

  // Error Routes
  static const String notFound = '/404';
  static const String unauthorized = '/unauthorized';
}
