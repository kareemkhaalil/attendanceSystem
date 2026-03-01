import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/get_subscription_usecase.dart';
import '../../domain/usecases/get_all_transactions_usecase.dart';
import '../../domain/usecases/approve_transaction_usecase.dart';
import '../../data/datasources/paymob_service.dart';
import '../../../../core/storage/shared_pref_helper.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetPlansUseCase _getPlans;
  final GetPaymentMethodsUseCase _getMethods;
  final CreateTransactionUseCase _createTransaction;
  final GetSubscriptionUseCase _getSubscription;
  final GetAllTransactionsUseCase _getAllTransactions;
  final ApproveTransactionUseCase _approveTransaction;
  final PaymobService? _paymobService; // Can be null if not configured

  PaymentCubit({
    required GetPlansUseCase getPlans,
    required GetPaymentMethodsUseCase getMethods,
    required CreateTransactionUseCase createTransaction,
    required GetSubscriptionUseCase getSubscription,
    required GetAllTransactionsUseCase getAllTransactions,
    required ApproveTransactionUseCase approveTransaction,
    PaymobService? paymobService,
  })  : _getPlans = getPlans,
        _getMethods = getMethods,
        _createTransaction = createTransaction,
        _getSubscription = getSubscription,
        _getAllTransactions = getAllTransactions,
        _approveTransaction = approveTransaction,
        _paymobService = paymobService,
        super(PaymentInitial());

  Future<void> loadPlans() async {
    emit(PaymentLoading());
    final result = await _getPlans(const NoParams());
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (plans) => emit(PlansLoaded(plans)),
    );
  }

  Future<void> loadPaymentMethods() async {
    emit(PaymentLoading());
    final result = await _getMethods(const NoParams());
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (methods) => emit(PaymentMethodsLoaded(methods)),
    );
  }

  Future<void> startPayment({
    required PlanEntity plan,
    required PaymentMethodEntity method,
    String? screenshotUrl,
  }) async {
    emit(PaymentLoading());
    final result = await _createTransaction(CreateTransactionParams(
      planId: plan.id,
      paymentMethodId: method.id,
      amount: plan.price,
      screenshotUrl: screenshotUrl,
    ));
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (transaction) => emit(TransactionCreated(transaction)),
    );
  }

  Future<void> checkSubscriptionStatus(String tenantId) async {
    emit(PaymentLoading());
    final result = await _getSubscription(tenantId);
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (subscription) => emit(SubscriptionLoaded(subscription)),
    );
  }

  // Admin Methods
  Future<void> fetchAllTransactions() async {
    emit(PaymentLoading());
    final result = await _getAllTransactions(const NoParams());
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (transactions) => emit(AllTransactionsLoaded(transactions)),
    );
  }

  Future<void> approvePayment(String transactionId) async {
    emit(PaymentLoading());
    final result = await _approveTransaction(transactionId);
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (_) {
        emit(PaymentSuccess());
        fetchAllTransactions(); // Refresh list
      },
    );
  }

  // Paymob Logic
  Future<void> checkoutWithPaymob({
    required PlanEntity plan,
  }) async {
    if (_paymobService == null) {
      emit(const PaymentError('Paymob is not configured.'));
      return;
    }

    emit(PaymentLoading());
    try {
      final user = SharedPrefHelper.getUser();
      if (user == null) {
        emit(const PaymentError('User session not found.'));
        return;
      }

      // 1. Get Payment Key
      final name = user.name ?? 'User';
      final names = name.split(' ');
      final firstName = names.first;
      final lastName = names.length > 1 ? names.last : 'User';

      final paymentKey = await _paymobService!.getPaymentKey(
        amount: plan.price,
        currency: plan.currency,
        firstName: firstName,
        lastName: lastName,
        email: user.email ?? 'no-email@manzoma.com',
        phoneNumber: '01000000000', // Placeholder or add to user model
      );

      // 2. Return the iframe URL
      final url = _paymobService!.getIframeUrl(paymentKey);
      // In a real app, emit a state to open the WebView
      emit(PaymentError('Paymob URL generated: $url (Navigate manually or via WebView)'));
    } catch (e) {
      emit(PaymentError('Paymob Error: $e'));
    }
  }
}
