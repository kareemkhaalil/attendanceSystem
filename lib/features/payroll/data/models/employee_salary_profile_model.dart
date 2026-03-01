import '../../domain/entities/employee_salary_profile_entity.dart';

class EmployeeSalaryProfileModel extends EmployeeSalaryProfileEntity {
  const EmployeeSalaryProfileModel({
    required super.id,
    required super.userId,
    required super.tenantId,
    required super.basicSalary,
    super.allowancesTotal,
    super.deductionsTotal,
    super.paymentMethod,
    super.bankName,
    super.accountNumber,
    super.iban,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmployeeSalaryProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSalaryProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tenantId: json['tenant_id'] as String,
      basicSalary: (json['basic_salary'] as num).toDouble(),
      allowancesTotal: (json['allowances_total'] as num?)?.toDouble() ?? 0.0,
      deductionsTotal: (json['deductions_total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'bank_transfer',
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      iban: json['iban'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tenant_id': tenantId,
      'basic_salary': basicSalary,
      'allowances_total': allowancesTotal,
      'deductions_total': deductionsTotal,
      'payment_method': paymentMethod,
      'bank_name': bankName,
      'account_number': accountNumber,
      'iban': iban,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
