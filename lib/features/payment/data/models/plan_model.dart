import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.currency,
    required super.durationDays,
    required super.features,
    super.isActive,
    super.maxUsers,
    super.maxBranches,
    super.maxAdmins,
    super.hasPayroll,
    super.hasAttendance,
    super.hasReports,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      durationDays: json['duration_days'] as int,
      features: (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      maxUsers: json['max_users'] as int? ?? 10,
      maxBranches: json['max_branches'] as int? ?? 1,
      maxAdmins: json['max_admins'] as int? ?? 1,
      hasPayroll: json['has_payroll'] as bool? ?? true,
      hasAttendance: json['has_attendance'] as bool? ?? true,
      hasReports: json['has_reports'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration_days': durationDays,
      'features': features,
      'is_active': isActive,
      'max_users': maxUsers,
      'max_branches': maxBranches,
      'max_admins': maxAdmins,
      'has_payroll': hasPayroll,
      'has_attendance': hasAttendance,
      'has_reports': hasReports,
    };
  }
}
