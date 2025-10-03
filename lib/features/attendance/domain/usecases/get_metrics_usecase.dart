import 'package:dartz/dartz.dart';
import 'package:manzoma/features/attendance/domain/repositories/attendance_rules_repository.dart';
import '../../../../core/error/failures.dart';

class GetMetricsParams {
  final String userId;
  final DateTime date;

  GetMetricsParams({required this.userId, required this.date});
}

class GetMetricsUseCase {
  final AttendanceRulesRepository repository;

  GetMetricsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      GetMetricsParams params) async {
    return Right(await repository.getMetrics(
      params.userId,
      params.date,
    ));
  }
}
