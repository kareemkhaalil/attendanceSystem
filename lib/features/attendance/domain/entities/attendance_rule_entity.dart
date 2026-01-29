import 'package:equatable/equatable.dart';

class AttendanceRuleEntity extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final Map<String, dynamic> details; // بدل workDays وغيره
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRuleEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, tenantId, name, details, createdAt, updatedAt];

  factory AttendanceRuleEntity.fromJson(Map<String, dynamic> json) {
    return AttendanceRuleEntity(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      details: (json['details'] ?? {}) as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson({bool forInsert = false}) {
    final map = {
      'tenant_id': tenantId.isNotEmpty ? tenantId : null,
      'name': name,
      'details': details,
      'updated_at': updatedAt.toIso8601String(),
    };

    if (!forInsert) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }

    return map;
  }
}
