import 'package:equatable/equatable.dart';

class PayrollRegulationEntity extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final double workingHoursPerDay;
  final double workingDaysPerMonth;
  final String baseCurrency;
  final double overtimeRate;
  final double lateDeductionRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PayrollRegulationEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    this.workingHoursPerDay = 8.0,
    this.workingDaysPerMonth = 26.0,
    this.baseCurrency = 'EGP',
    this.overtimeRate = 1.5,
    this.lateDeductionRate = 1.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        workingHoursPerDay,
        workingDaysPerMonth,
        baseCurrency,
        overtimeRate,
        lateDeductionRate,
        isActive,
        createdAt,
        updatedAt,
      ];
}
