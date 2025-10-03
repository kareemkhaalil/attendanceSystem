import 'package:dartz/dartz.dart';
import 'package:manzoma/features/payroll/data/models/payroll_rules_model.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_rules_entity.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_rules_repo.dart';
import '../datasources/payroll_rules_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

class PayrollRulesRepositoryImpl implements PayrollRulesRepository {
  final PayrollRulesDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PayrollRulesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PayrollRuleEntity>>> getAllRules(
      String tenantId) async {
    if (!await networkInfo.isConnected)
      return const Left(NetworkFailure(message: ''));
    try {
      final models = await remoteDataSource.getPayrollRules(tenantId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PayrollRuleEntity>> createRule(
      PayrollRuleEntity rule) async {
    if (!await networkInfo.isConnected)
      return const Left(NetworkFailure(message: ''));
    try {
      final model = PayrollRuleModel(
        id: rule.id,
        tenantId: rule.tenantId,
        name: rule.name,
        description: rule.description,
        type: rule.type,
        calculationMethod: rule.calculationMethod,
        value: rule.value,
        isAutomatic: rule.isAutomatic,
        createdAt: rule.createdAt,
        updatedAt: rule.updatedAt,
      );
      final result = await remoteDataSource.createPayrollRule(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PayrollRuleEntity>> updateRule(
      PayrollRuleEntity rule) async {
    if (!await networkInfo.isConnected)
      return const Left(NetworkFailure(message: ''));
    try {
      final model = PayrollRuleModel(
        id: rule.id,
        tenantId: rule.tenantId,
        name: rule.name,
        description: rule.description,
        type: rule.type,
        calculationMethod: rule.calculationMethod,
        value: rule.value,
        isAutomatic: rule.isAutomatic,
        createdAt: rule.createdAt,
        updatedAt: rule.updatedAt,
      );
      final result = await remoteDataSource.updatePayrollRule(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRule(String ruleId) async {
    if (!await networkInfo.isConnected)
      return const Left(NetworkFailure(message: ''));
    try {
      await remoteDataSource.deletePayrollRule(ruleId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
