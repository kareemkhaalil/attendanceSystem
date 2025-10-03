import 'package:manzoma/features/attendance/data/models/attendance_rule_model.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';
import 'package:manzoma/features/attendance/domain/repositories/attendance_rules_repository.dart';

class GetRulesUsecase {
  final AttendanceRulesRepository repository;
  GetRulesUsecase(this.repository);

  Future<List<AttendanceRuleEntity>> call(String tenantId) {
    return repository.getRules(tenantId);
  }
}
