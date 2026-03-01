import 'package:equatable/equatable.dart';

class EmployeeSalaryProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String tenantId;
  final double basicSalary;
  final double allowancesTotal;
  final double deductionsTotal;
  final String paymentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeSalaryProfileEntity({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.basicSalary,
    this.allowancesTotal = 0.0,
    this.deductionsTotal = 0.0,
    this.paymentMethod = 'bank_transfer',
    this.bankName,
    this.accountNumber,
    this.iban,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        tenantId,
        basicSalary,
        allowancesTotal,
        deductionsTotal,
        paymentMethod,
        bankName,
        accountNumber,
        iban,
        isActive,
        createdAt,
        updatedAt,
      ];
}
