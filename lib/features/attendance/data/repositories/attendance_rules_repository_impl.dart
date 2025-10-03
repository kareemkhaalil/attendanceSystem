import 'package:manzoma/features/attendance/data/datasources/attendance_rules_remote_datasource.dart';
import 'package:manzoma/features/attendance/data/models/attendance_rule_model.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';
import 'package:manzoma/features/attendance/domain/repositories/attendance_rules_repository.dart';

class AttendanceRulesRepositoryImpl implements AttendanceRulesRepository {
  final AttendanceRulesRemoteDataSource remote;

  AttendanceRulesRepositoryImpl({required this.remote});

  @override
  Future<List<AttendanceRuleEntity>> getRules(String tenantId) {
    return remote.getRules(tenantId);
  }

  @override
  Future<AttendanceRuleEntity> addRule(AttendanceRuleEntity data) {
    return remote.addRule(data);
  }

  @override
  Future<AttendanceRuleEntity> updateRule(AttendanceRuleEntity data) {
    return remote.updateRule(data);
  }

  @override
  Future<void> assignRuleToUser(
      String userId, Map<String, dynamic> ruleDetails) {
    return remote.assignRuleToUser(userId, ruleDetails);
  }

  @override
  Future<Map<String, dynamic>> getMetrics(String userId, DateTime date) {
    return remote.getMetrics(userId, date);
  }
}
