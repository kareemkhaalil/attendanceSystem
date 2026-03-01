import 'package:manzoma/core/enums/user_role.dart';

class UserEntity {
  final String id;
  final String tenantId;
  final String? branchId;
  final String? email;
  final UserRole role; // 👈 Enum
  final String? name;
  final String? phone;
  final String? avatar;
  final double? baseSalary;
  final List<dynamic>? allowances;
  final List<dynamic>? deductions;
  final Map<String, dynamic>? workSchedule;
  final bool? isActive;
  final bool? isSubscriptionActive; // 👈 Add this
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.tenantId,
    this.branchId,
    this.email,
    required this.role, // 👈 Enum
    this.name,
    this.phone,
    this.avatar,
    this.baseSalary,
    this.allowances,
    this.deductions,
    this.workSchedule,
    this.isActive,
    this.isSubscriptionActive, // 👈 Add this
    this.createdAt,
    this.updatedAt,
  });
}
