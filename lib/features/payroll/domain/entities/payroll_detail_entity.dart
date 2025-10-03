import 'package:equatable/equatable.dart';

class PayrollDetailEntity extends Equatable {
  final String id;
  final String payrollId;
  final String tenantId;
  final String ruleName;
  final String calculationMethod;
  final String type; // allowance | deduction
  final DateTime createdAt;
  final double amount;

  const PayrollDetailEntity({
    required this.id,
    required this.payrollId,
    required this.tenantId,
    required this.ruleName,
    required this.calculationMethod,
    required this.type,
    required this.createdAt,
    required this.amount,
  });

  @override
  List<Object?> get props => [
        id,
        payrollId,
        tenantId,
        ruleName,
        calculationMethod,
        type,
        createdAt,
        amount,
      ];
}
