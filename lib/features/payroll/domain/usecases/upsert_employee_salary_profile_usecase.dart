import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_salary_profile_entity.dart';
import '../repositories/payroll_repository.dart';

class UpsertEmployeeSalaryProfileUseCase implements UseCase<EmployeeSalaryProfileEntity, EmployeeSalaryProfileEntity> {
  final PayrollRepository repository;
  UpsertEmployeeSalaryProfileUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeSalaryProfileEntity>> call(EmployeeSalaryProfileEntity profile) async {
    return await repository.upsertEmployeeSalaryProfile(profile);
  }
}
