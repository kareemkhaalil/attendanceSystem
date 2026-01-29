import 'package:manzoma/features/attendance/domain/repositories/attendance_rules_repository.dart';

class AssignRuleToUserUsecase {
  final AttendanceRulesRepository repository;
  AssignRuleToUserUsecase(this.repository);

  Future<void> call(String userId, Map<String, dynamic> ruleDetails) {
    return repository.assignRuleToUser(userId, ruleDetails);
  }
}
