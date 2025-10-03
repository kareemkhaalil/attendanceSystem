import 'package:equatable/equatable.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/features/clients/domain/entities/client_entity.dart';
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
  final String? errorMessage;
  final String? message; // 👈 جديد

  const PayrollState({
    this.status = PayrollStatus.initial,
    this.payrolls = const [],
    this.selectedPayroll,
    this.details = const [],
    this.rules = const [],
    this.errorMessage,
    this.clients = const [], // 👈 جديد
    this.employees = const [],
    this.message, // 👈 جديد
  });

  PayrollState copyWith({
    PayrollStatus? status,
    List<PayrollEntity>? payrolls,
    PayrollEntity? selectedPayroll,
    List<PayrollDetailEntity>? details,
    List<PayrollRuleEntity>? rules,
    List<ClientEntity>? clients, // 👈 جديد
    List<UserEntity>? employees,
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
      errorMessage: errorMessage,
      message: message, // 👈 جديد
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
        errorMessage,
        message
      ];
}
