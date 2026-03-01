import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payroll_regulation_entity.dart';
import '../repositories/payroll_repository.dart';

class GetPayrollRegulationUseCase implements UseCase<PayrollRegulationEntity?, String> {
  final PayrollRepository repository;
  GetPayrollRegulationUseCase(this.repository);

  @override
  Future<Either<Failure, PayrollRegulationEntity?>> call(String tenantId) async {
    return await repository.getPayrollRegulation(tenantId);
  }
}
