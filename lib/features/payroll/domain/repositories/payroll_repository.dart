// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../entities/payroll_entity.dart';

// abstract class PayrollRepository {
//   Future<Either<Failure, PayrollEntity>> createPayroll({
//     required String userId,
//     required String period,
//     required double basicSalary,
//     double allowances = 0,
//     double deductions = 0,
//     double overtime = 0,
//     double bonus = 0,
//     required int workingDays,
//     required int actualWorkingDays,
//     String? notes,
//   });

//   Future<Either<Failure, List<PayrollEntity>>> getPayrollHistory({
//     required String userId,
//     String? period,
//     int? limit,
//     int? offset,
//   });

//   Future<Either<Failure, List<PayrollEntity>>> getAllPayrolls({
//     String? period,
//     String? status,
//     int? limit,
//     int? offset,
//   });

//   Future<Either<Failure, PayrollEntity>> updatePayroll({
//     required String payrollId,
//     double? basicSalary,
//     double? allowances,
//     double? deductions,
//     double? overtime,
//     double? bonus,
//     int? workingDays,
//     int? actualWorkingDays,
//     String? status,
//     String? notes,
//   });

//   Future<Either<Failure, void>> deletePayroll({required String payrollId});

//   Future<Either<Failure, PayrollEntity>> approvePayroll({required String payrollId});

//   Future<Either<Failure, PayrollEntity>> markAsPaid({required String payrollId});
// }

import 'package:dartz/dartz.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_detail_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_regulation_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/employee_salary_profile_entity.dart';
import '../entities/payroll_entity.dart';
import '../../../../core/error/failures.dart';

abstract class PayrollRepository {
  Future<Either<Failure, List<PayrollEntity>>> getPayrolls(String tenantId);
  Future<Either<Failure, PayrollEntity>> getPayrollById(String id);
  Future<Either<Failure, PayrollEntity>> createPayroll(PayrollEntity payroll);
  Future<Either<Failure, PayrollEntity>> updatePayroll(PayrollEntity payroll);
  Future<Either<Failure, void>> deletePayroll(String id);
  Future<Either<Failure, List<PayrollDetailEntity>>> generatePayrollEntries(
    String payrollId,
    String tenantId,
  );

  // Advanced Payroll (Phase 4)
  Future<Either<Failure, PayrollRegulationEntity?>> getPayrollRegulation(String tenantId);
  Future<Either<Failure, PayrollRegulationEntity>> updatePayrollRegulation(PayrollRegulationEntity regulation);
  Future<Either<Failure, EmployeeSalaryProfileEntity?>> getEmployeeSalaryProfile(String userId);
  Future<Either<Failure, EmployeeSalaryProfileEntity>> upsertEmployeeSalaryProfile(EmployeeSalaryProfileEntity profile);
  Future<Either<Failure, List<String>>> getEmployeeSalaryComponentIds(String profileId);
  Future<Either<Failure, void>> updateEmployeeSalaryComponents(String profileId, List<String> ruleIds);
}
