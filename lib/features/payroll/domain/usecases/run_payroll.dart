import 'package:dartz/dartz.dart';
import 'package:manzoma/core/error/failures.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_entry.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_repository.dart';

class RunPayrollParams {
  final String tenantId;
  final DateTime start;
  final DateTime end;
  final List<String>? userIds;

  RunPayrollParams({
    required this.tenantId,
    required this.start,
    required this.end,
    this.userIds,
  });
}

class PreviewPayroll {
  final PayrollRepository repository;
  PreviewPayroll(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(RunPayrollParams params) {
    return repository.previewPayroll(
      tenantId: params.tenantId,
      periodStart: params.start,
      periodEnd: params.end,
      userIds: params.userIds,
    );
  }
}

class PersisttPayroll {
  final PayrollRepository repository;
  PersisttPayroll(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(RunPayrollParams params) {
    return repository.persistPayroll(
      tenantId: params.tenantId,
      periodStart: params.start,
      periodEnd: params.end,
      userIds: params.userIds,
    );
  }
}
