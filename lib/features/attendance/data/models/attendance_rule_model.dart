import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';

class AttendanceRuleModel extends AttendanceRuleEntity {
  const AttendanceRuleModel({
    required super.id,
    required super.tenantId,
    required super.name,
    required super.details,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AttendanceRuleModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRuleModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      details: json['details'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = {
      'tenant_id': tenantId,
      'name': name,
      'details': details,
      'updated_at': updatedAt.toIso8601String(),
    };

    if (!forInsert && id.isNotEmpty) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }

    return map;
  }
}
