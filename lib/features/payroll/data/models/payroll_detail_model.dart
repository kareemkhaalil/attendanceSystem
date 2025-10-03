import 'package:manzoma/features/payroll/domain/entities/payroll_detail_entity.dart';

class PayrollDetailModel extends PayrollDetailEntity {
  const PayrollDetailModel({
    required super.id,
    required super.payrollId,
    required super.tenantId,
    required super.ruleName,
    required super.type,
    required super.amount,
    required super.calculationMethod,
    required super.createdAt,
  });

  factory PayrollDetailModel.fromJson(Map<String, dynamic> json) {
    return PayrollDetailModel(
      id: json['id'] as String,
      payrollId: json['payroll_id'] as String,
      tenantId: json['tenant_id'] as String,
      ruleName: json['rule_name'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      calculationMethod: json['calculation_method'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = {
      'payroll_id': payrollId,
      'tenant_id': tenantId,
      'rule_name': ruleName,
      'type': type,
      'amount': amount,
      'calculation_method': calculationMethod,
    };
    if (!forInsert) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }
    return map;
  }

  factory PayrollDetailModel.fromEntity(PayrollDetailEntity entity) {
    return PayrollDetailModel(
      id: entity.id,
      payrollId: entity.payrollId,
      tenantId: entity.tenantId,
      ruleName: entity.ruleName,
      type: entity.type,
      amount: entity.amount,
      calculationMethod: entity.calculationMethod,
      createdAt: entity.createdAt,
    );
  }

  /// ✅ من Model لـ Entity
  PayrollDetailEntity toEntity() {
    return PayrollDetailEntity(
      id: id,
      payrollId: payrollId,
      tenantId: tenantId,
      ruleName: ruleName,
      type: type,
      amount: amount,
      calculationMethod: calculationMethod,
      createdAt: createdAt,
    );
  }
}
