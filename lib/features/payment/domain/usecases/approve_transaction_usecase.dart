import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class ApproveTransactionUseCase implements UseCase<void, String> {
  final PaymentRepository repository;
  ApproveTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String transactionId) async {
    return await repository.approveTransaction(transactionId);
  }
}
