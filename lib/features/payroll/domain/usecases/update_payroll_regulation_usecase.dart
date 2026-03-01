import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payroll_regulation_entity.dart';
import '../repositories/payroll_repository.dart';

class UpdatePayrollRegulationUseCase implements UseCase<PayrollRegulationEntity, PayrollRegulationEntity> {
  final PayrollRepository repository;
  UpdatePayrollRegulationUseCase(this.repository);

  @override
  Future<Either<Failure, PayrollRegulationEntity>> call(PayrollRegulationEntity regulation) async {
    return await repository.updatePayrollRegulation(regulation);
  }
}
