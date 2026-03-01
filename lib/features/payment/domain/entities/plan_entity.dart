import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isActive;
  final int maxUsers;
  final int maxBranches;
  final int maxAdmins;
  final bool hasPayroll;
  final bool hasAttendance;
  final bool hasReports;

  const PlanEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'EGP',
    required this.durationDays,
    required this.features,
    this.isActive = true,
    this.maxUsers = 10,
    this.maxBranches = 1,
    this.maxAdmins = 1,
    this.hasPayroll = true,
    this.hasAttendance = true,
    this.hasReports = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        currency,
        durationDays,
        features,
        isActive,
        maxUsers,
        maxBranches,
        maxAdmins,
        hasPayroll,
        hasAttendance,
        hasReports,
      ];
}
