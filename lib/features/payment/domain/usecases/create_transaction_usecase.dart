import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class CreateTransactionParams {
  final String planId;
  final String paymentMethodId;
  final double amount;
  final String? screenshotUrl;

  const CreateTransactionParams({
    required this.planId,
    required this.paymentMethodId,
    required this.amount,
    this.screenshotUrl,
  });
}

class CreateTransactionUseCase implements UseCase<TransactionEntity, CreateTransactionParams> {
  final PaymentRepository repository;
  CreateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(CreateTransactionParams params) async {
    return await repository.createTransaction(
      planId: params.planId,
      paymentMethodId: params.paymentMethodId,
      amount: params.amount,
      screenshotUrl: params.screenshotUrl,
    );
  }
}
