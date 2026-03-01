import 'package:dartz/dartz.dart';
import 'package:manzoma/core/error/failures.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_entry.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:manzoma/core/error/failures.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_entry.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_repository.dart';

class ApprovePayroll {
  final PayrollRepository repo;

  ApprovePayroll(this.repo);

  Future<Either<Failure, void>> call({
    required DateTime start,
    required DateTime end,
    required String tenantId,
    required List<PayrollEntry> entries,
  }) async {
    // ✅ نرجع String بدل void
    return await repo.approvePayroll(
      start: start,
      end: end,
      tenantId: tenantId,
      entries: entries,
    );
  }
}
