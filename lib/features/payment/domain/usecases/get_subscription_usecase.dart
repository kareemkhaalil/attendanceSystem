import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';

class GetSubscriptionUseCase implements UseCase<SubscriptionEntity, String> {
  final PaymentRepository repository;
  GetSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(String tenantId) async {
    return await repository.getSubscription(tenantId);
  }
}
