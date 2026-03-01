import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payroll_repository.dart';

class GetEmployeeSalaryComponentIdsUseCase implements UseCase<List<String>, String> {
  final PayrollRepository repository;
  GetEmployeeSalaryComponentIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String profileId) async {
    return await repository.getEmployeeSalaryComponentIds(profileId);
  }
}
