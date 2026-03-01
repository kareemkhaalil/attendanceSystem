import 'package:equatable/equatable.dart';
import 'plan_entity.dart';

class SubscriptionEntity extends Equatable {
  final String id;
  final String tenantId;
  final String planId;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final PlanEntity? plan; // 👈 Add this

  const SubscriptionEntity({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.status,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.plan,
  });

  bool get isActive => status == 'active' && (endDate == null || endDate!.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [id, tenantId, planId, status, startDate, endDate, createdAt, plan];
}
