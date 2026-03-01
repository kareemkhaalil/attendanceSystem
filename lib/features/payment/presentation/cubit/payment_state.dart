part of 'payment_cubit.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PlansLoaded extends PaymentState {
  final List<PlanEntity> plans;
  const PlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> methods;
  const PaymentMethodsLoaded(this.methods);

  @override
  List<Object?> get props => [methods];
}

class TransactionCreated extends PaymentState {
  final TransactionEntity transaction;
  const TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class AllTransactionsLoaded extends PaymentState {
  final List<TransactionEntity> transactions;
  const AllTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class SubscriptionLoaded extends PaymentState {
  final SubscriptionEntity subscription;
  const SubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentSuccess extends PaymentState {}
