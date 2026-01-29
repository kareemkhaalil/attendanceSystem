class PayrollEntryModel {
  final String userId;
  final double baseSalary;
  final double proratedBase;
  final double workedHours;
  final double expectedHours;
  final double overtimeHours;
  final double gross;
  final double net;
  final List<dynamic> additions;
  final List<dynamic> deductions;

  PayrollEntryModel({
    required this.userId,
    required this.baseSalary,
    required this.proratedBase,
    required this.workedHours,
    required this.expectedHours,
    required this.overtimeHours,
    required this.gross,
    required this.net,
    required this.additions,
    required this.deductions,
  });

  factory PayrollEntryModel.fromJson(Map<String, dynamic> json) {
    return PayrollEntryModel(
      userId: json['user_id']?.toString() ?? '',
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      proratedBase: (json['prorated_base'] ?? 0).toDouble(),
      workedHours: (json['worked_hours'] ?? 0).toDouble(),
      expectedHours: (json['expected_hours'] ?? 0).toDouble(),
      overtimeHours: (json['overtime_hours'] ?? 0).toDouble(),
      gross: (json['gross'] ?? 0).toDouble(),
      net: (json['net'] ?? 0).toDouble(),
      additions: json['additions'] ?? [],
      deductions: json['deductions'] ?? [],
    );
  }
}
