import 'package:manzoma/features/attendance/data/models/attendance_rule_model.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';

abstract class AttendanceRulesRepository {
  Future<List<AttendanceRuleEntity>> getRules(String tenantId);
  Future<AttendanceRuleEntity> addRule(AttendanceRuleEntity data);
  Future<AttendanceRuleEntity> updateRule(AttendanceRuleEntity data);
  Future<void> assignRuleToUser(
      String userId, Map<String, dynamic> ruleDetails);
  Future<Map<String, dynamic>> getMetrics(String userId, DateTime date);
}
