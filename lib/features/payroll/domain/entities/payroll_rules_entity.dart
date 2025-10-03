import 'package:equatable/equatable.dart';

class PayrollRuleEntity extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String type; // allowance | deduction
  final String calculationMethod; // fixed | percentage | per_hour | custom
  final double value;
  final bool isAutomatic;
  final String? customFormula;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PayrollRuleEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.type,
    required this.calculationMethod,
    required this.value,
    required this.isAutomatic,
    this.customFormula,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PayrollRuleEntity.fromJson(Map<String, dynamic> json) {
    return PayrollRuleEntity(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      calculationMethod: json['calculation_method'] as String,
      value: (json['value'] as num).toDouble(),
      isAutomatic: json['is_automatic'] as bool,
      customFormula: json['custom_formula'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = {
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'type': type,
      'calculation_method': calculationMethod,
      'value': value,
      'is_automatic': isAutomatic,
      'custom_formula': customFormula,
    };
    if (!forInsert) {
      map['id'] = id;
      map['updated_at'] = DateTime.now().toIso8601String();
    }
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        description,
        type,
        calculationMethod,
        value,
        isAutomatic,
        customFormula,
        createdAt,
        updatedAt,
      ];
}
