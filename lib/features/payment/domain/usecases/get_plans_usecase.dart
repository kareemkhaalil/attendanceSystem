import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plan_entity.dart';
import '../repositories/payment_repository.dart';

class GetPlansUseCase implements UseCase<List<PlanEntity>, NoParams> {
  final PaymentRepository repository;
  GetPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlanEntity>>> call(NoParams params) async {
    return await repository.getPlans();
  }
}
