import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/plan_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/transaction_entity.dart';
import '../entities/subscription_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PlanEntity>>> getPlans();
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required String planId,
    required String paymentMethodId,
    required double amount,
    String? screenshotUrl,
  });
  Future<Either<Failure, SubscriptionEntity>> getSubscription(String tenantId);
  Future<Either<Failure, void>> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? providerTransactionId,
  });
  // Admin Methods
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();
  Future<Either<Failure, void>> approveTransaction(String transactionId);
}
