import 'package:dartz/dartz.dart';
import 'package:manzoma/features/payroll/data/datasources/payroll_details_datasource.dart';
import 'package:manzoma/features/payroll/data/datasources/payroll_remote_datasource.dart';
import 'package:manzoma/features/payroll/domain/repositories/payroll_details_repository.dart';
import '../../domain/entities/payroll_detail_entity.dart';

import '../models/payroll_detail_model.dart';
import '../../../../core/error/failures.dart';

class PayrollDetailRepositoryImpl implements PayrollDetailRepository {
  final PayrollDetailRemoteDataSource remoteDataSource;

  PayrollDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PayrollDetailEntity>>> getDetailsByPayrollId(
      String payrollId) async {
    try {
      final result = await remoteDataSource.getDetailsByPayrollId(payrollId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PayrollDetailEntity>> addDetail(
      PayrollDetailEntity detail) async {
    try {
      final model = PayrollDetailModel.fromEntity(detail);
      final result = await remoteDataSource.addDetail(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDetail(String detailId) async {
    try {
      await remoteDataSource.deleteDetail(detailId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
