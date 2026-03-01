import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/shared_pref_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PlanEntity>>> getPlans() async {
    try {
      final plans = await remoteDataSource.getPlans();
      return Right(plans);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final methods = await remoteDataSource.getPaymentMethods();
      return Right(methods);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required String planId,
    required String paymentMethodId,
    required double amount,
    String? screenshotUrl,
  }) async {
    try {
      final user = SharedPrefHelper.getUser();
      if (user == null || user.tenantId == null) {
        return Left(AuthFailure(message: 'User session or tenant not found'));
      }
      final transaction = await remoteDataSource.createTransaction(
        planId: planId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        screenshotUrl: screenshotUrl,
        tenantId: user.tenantId!,
      );
      return Right(transaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscription(String tenantId) async {
    try {
      final subscription = await remoteDataSource.getSubscription(tenantId);
      if (subscription == null) {
        return Left(ServerFailure(message: 'No subscription found for this tenant'));
      }
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? providerTransactionId,
  }) async {
    try {
      await remoteDataSource.updateTransactionStatus(
        transactionId: transactionId,
        status: status,
        providerTransactionId: providerTransactionId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      final transactions = await remoteDataSource.getAllTransactions();
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveTransaction(String transactionId) async {
    try {
      await remoteDataSource.approveTransaction(transactionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
