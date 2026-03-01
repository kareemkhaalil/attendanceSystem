import 'package:dartz/dartz.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_detail_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_regulation_entity.dart';
import 'package:manzoma/features/payroll/domain/entities/employee_salary_profile_entity.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_repository.dart';
import '../../domain/entities/payroll_entity.dart';
import '../datasources/payroll_remote_datasource.dart';
import '../models/payroll_model.dart';
import '../models/payroll_regulation_model.dart';
import '../models/employee_salary_profile_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  final PayrollRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PayrollRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PayrollEntity>>> getAllPayrolls(
      String tenantId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final models = await remoteDataSource.getAllPayrolls(tenantId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PayrollEntity>> getPayrollById(
      String payrollId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final model = await remoteDataSource.getPayrollById(payrollId);
      if (model == null) {
        return const Left(ServerFailure(message: 'لم يتم العثور على البيانات'));
      }
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PayrollEntity>> createPayroll(
      PayrollEntity payroll) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final model = await remoteDataSource
          .createPayroll(PayrollModel.fromEntity(payroll)); // ✅
      if (model == null) {
        return const Left(ServerFailure(message: 'فشل إنشاء الراتب'));
      }
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayroll(String payrollId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      await remoteDataSource.deletePayroll(payrollId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // شيل دي أو خليه ينده getAllPayrolls
  @override
  Future<Either<Failure, List<PayrollEntity>>> getPayrolls(
      String tenantId) async {
    return getAllPayrolls(tenantId);
  }

  @override
  Future<Either<Failure, PayrollEntity>> updatePayroll(
      PayrollEntity payroll) async {
    // if (!await networkInfo.isConnected) {
    //   return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    // }
    // try {
    //   final model = await remoteDataSource
    //       .updatePayroll(PayrollModel.fromEntity(payroll)); // ✅
    //   return Right(model);
    // } on ServerException catch (e) {
    //   return Left(ServerFailure(message: e.message));
    // }
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PayrollDetailEntity>>> generatePayrollEntries(
      String payrollId, String tenantId) async {
    try {
      final model = await remoteDataSource.generatePayrollEntries(
        payrollId: payrollId,
        tenantId: tenantId,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ---- Advanced Payroll (Phase 4) ----

  @override
  Future<Either<Failure, PayrollRegulationEntity?>> getPayrollRegulation(String tenantId) async {
    try {
      final regulation = await remoteDataSource.getPayrollRegulation(tenantId);
      return Right(regulation);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PayrollRegulationEntity>> updatePayrollRegulation(PayrollRegulationEntity regulation) async {
    try {
      final updated = await remoteDataSource.updatePayrollRegulation(
        PayrollRegulationModel(
          id: regulation.id,
          tenantId: regulation.tenantId,
          name: regulation.name,
          workingHoursPerDay: regulation.workingHoursPerDay,
          workingDaysPerMonth: regulation.workingDaysPerMonth,
          baseCurrency: regulation.baseCurrency,
          overtimeRate: regulation.overtimeRate,
          lateDeductionRate: regulation.lateDeductionRate,
          isActive: regulation.isActive,
          createdAt: regulation.createdAt,
          updatedAt: regulation.updatedAt,
        ),
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeSalaryProfileEntity?>> getEmployeeSalaryProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getEmployeeSalaryProfile(userId);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeSalaryProfileEntity>> upsertEmployeeSalaryProfile(EmployeeSalaryProfileEntity profile) async {
    try {
      final updated = await remoteDataSource.upsertEmployeeSalaryProfile(
        EmployeeSalaryProfileModel(
          id: profile.id,
          userId: profile.userId,
          tenantId: profile.tenantId,
          basicSalary: profile.basicSalary,
          allowancesTotal: profile.allowancesTotal,
          deductionsTotal: profile.deductionsTotal,
          paymentMethod: profile.paymentMethod,
          bankName: profile.bankName,
          accountNumber: profile.accountNumber,
          iban: profile.iban,
          isActive: profile.isActive,
          createdAt: profile.createdAt,
          updatedAt: profile.updatedAt,
        ),
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getEmployeeSalaryComponentIds(String profileId) async {
    try {
      final ids = await remoteDataSource.getEmployeeSalaryComponentIds(profileId);
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmployeeSalaryComponents(String profileId, List<String> ruleIds) async {
    try {
      await remoteDataSource.updateEmployeeSalaryComponents(profileId, ruleIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
