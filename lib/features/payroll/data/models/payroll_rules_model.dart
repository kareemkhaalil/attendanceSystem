import 'package:manzoma/features/payroll/domain/entities/payroll_rules_entity.dart';

class PayrollRuleModel extends PayrollRuleEntity {
  const PayrollRuleModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.description,
    required super.type,
    required super.calculationMethod,
    required super.value,
    required super.isAutomatic,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PayrollRuleModel.fromJson(Map<String, dynamic> json) {
    return PayrollRuleModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      calculationMethod: json['calculation_method'] as String,
      value: (json['value'] as num).toDouble(),
      isAutomatic: json['is_automatic'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = {
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'type': type,
      'calculation_method': calculationMethod,
      'value': value,
      'is_automatic': isAutomatic,
    };
    if (!forInsert) {
      map['id'] = id;
      map['updated_at'] = updatedAt.toIso8601String();
    }
    return map;
  }
}
