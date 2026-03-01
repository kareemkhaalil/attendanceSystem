import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payroll_repository.dart';

class UpdateEmployeeSalaryComponentsParams {
  final String profileId;
  final List<String> ruleIds;
  UpdateEmployeeSalaryComponentsParams({required this.profileId, required this.ruleIds});
}

class UpdateEmployeeSalaryComponentsUseCase implements UseCase<void, UpdateEmployeeSalaryComponentsParams> {
  final PayrollRepository repository;
  UpdateEmployeeSalaryComponentsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmployeeSalaryComponentsParams params) async {
    return await repository.updateEmployeeSalaryComponents(params.profileId, params.ruleIds);
  }
}
