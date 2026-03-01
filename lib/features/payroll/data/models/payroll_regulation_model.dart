import '../../domain/entities/payroll_regulation_entity.dart';

class PayrollRegulationModel extends PayrollRegulationEntity {
  const PayrollRegulationModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.workingHoursPerDay,
    super.workingDaysPerMonth,
    super.baseCurrency,
    super.overtimeRate,
    super.lateDeductionRate,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PayrollRegulationModel.fromJson(Map<String, dynamic> json) {
    return PayrollRegulationModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      workingHoursPerDay: (json['working_hours_per_day'] as num?)?.toDouble() ?? 8.0,
      workingDaysPerMonth: (json['working_days_per_month'] as num?)?.toDouble() ?? 26.0,
      baseCurrency: json['base_currency'] as String? ?? 'EGP',
      overtimeRate: (json['overtime_rate'] as num?)?.toDouble() ?? 1.5,
      lateDeductionRate: (json['late_deduction_rate'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'working_hours_per_day': workingHoursPerDay,
      'working_days_per_month': workingDaysPerMonth,
      'base_currency': baseCurrency,
      'overtime_rate': overtimeRate,
      'late_deduction_rate': lateDeductionRate,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
