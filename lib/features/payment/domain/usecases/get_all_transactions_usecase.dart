import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class GetAllTransactionsUseCase implements UseCase<List<TransactionEntity>, NoParams> {
  final PaymentRepository repository;
  GetAllTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getAllTransactions();
  }
}
