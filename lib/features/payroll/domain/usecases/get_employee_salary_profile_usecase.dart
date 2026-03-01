import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_salary_profile_entity.dart';
import '../repositories/payroll_repository.dart';

class GetEmployeeSalaryProfileUseCase implements UseCase<EmployeeSalaryProfileEntity?, String> {
  final PayrollRepository repository;
  GetEmployeeSalaryProfileUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeSalaryProfileEntity?>> call(String userId) async {
    return await repository.getEmployeeSalaryProfile(userId);
  }
}
