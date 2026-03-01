import 'package:equatable/equatable.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/features/clients/domain/entities/client_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_regulation_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/employee_salary_profile_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_rules_entity.dart';
import '../../domain/entities/payroll_entity.dart';
import '../../domain/entities/payroll_detail_entity.dart';

enum PayrollStatus { initial, loading, success, failure }

class PayrollState extends Equatable {
  final PayrollStatus status;
  final List<PayrollEntity> payrolls;
  final PayrollEntity? selectedPayroll;
  final List<PayrollDetailEntity> details;
  final List<PayrollRuleEntity> rules;
  final List<ClientEntity>? clients; // 👈 جديد
  final List<UserEntity> employees;
  final PayrollRegulationEntity? regulation; // Phase 4
  final EmployeeSalaryProfileEntity? salaryProfile; // Phase 4
  final List<String> selectedRuleIds; // Phase 4
  final String? errorMessage;
  final String? message;

  const PayrollState({
    this.status = PayrollStatus.initial,
    this.payrolls = const [],
    this.selectedPayroll,
    this.details = const [],
    this.rules = const [],
    this.errorMessage,
    this.clients = const [],
    this.employees = const [],
    this.regulation,
    this.salaryProfile,
    this.selectedRuleIds = const [],
    this.message,
  });

  PayrollState copyWith({
    PayrollStatus? status,
    List<PayrollEntity>? payrolls,
    PayrollEntity? selectedPayroll,
    List<PayrollDetailEntity>? details,
    List<PayrollRuleEntity>? rules,
    List<ClientEntity>? clients, // 👈 جديد
    List<UserEntity>? employees,
    PayrollRegulationEntity? regulation,
    EmployeeSalaryProfileEntity? salaryProfile,
    List<String>? selectedRuleIds,
    String? errorMessage,
    String? message,
  }) {
    return PayrollState(
      status: status ?? this.status,
      payrolls: payrolls ?? this.payrolls,
      selectedPayroll: selectedPayroll ?? this.selectedPayroll,
      details: details ?? this.details,
      rules: rules ?? this.rules,
      clients: clients ?? this.clients, // 👈 جديد
      employees: employees ?? this.employees,
      regulation: regulation ?? this.regulation,
      salaryProfile: salaryProfile ?? this.salaryProfile,
      selectedRuleIds: selectedRuleIds ?? this.selectedRuleIds,
      errorMessage: errorMessage,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        payrolls,
        selectedPayroll,
        details,
        rules,
        clients,
        employees,
        regulation,
        salaryProfile,
        selectedRuleIds,
        errorMessage,
        message
      ];
}
