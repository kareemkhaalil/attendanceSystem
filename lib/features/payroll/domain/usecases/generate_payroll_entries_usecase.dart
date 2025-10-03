import 'package:dartz/dartz.dart';
import 'package:manzoma/core/error/failures.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_detail_entity.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_repository.dart';

class GeneratePayrollEntries {
  final PayrollRepository repository;
  GeneratePayrollEntries(this.repository);

  Future<Either<Failure, List<PayrollDetailEntity>>> call(
      String payrollId, String tenantId) {
    return repository.generatePayrollEntries(payrollId, tenantId);
  }
}
