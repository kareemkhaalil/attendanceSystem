import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/plan_model.dart';
import '../models/payment_method_model.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<TransactionModel> createTransaction({
    required String planId,
    required String paymentMethodId,
    required double amount,
    String? screenshotUrl,
    required String tenantId,
  });
  Future<SubscriptionModel?> getSubscription(String tenantId);
  Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? providerTransactionId,
  });
  // Admin Methods
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> approveTransaction(String transactionId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;
  PaymentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final response = await supabaseClient.from('plans').select().eq('is_active', true);
      return (response as List).map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await supabaseClient.from('payment_methods').select().eq('is_active', true);
      return (response as List).map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required String planId,
    required String paymentMethodId,
    required double amount,
    String? screenshotUrl,
    required String tenantId,
  }) async {
    try {
      final response = await supabaseClient
          .from('transactions')
          .insert({
            'plan_id': planId,
            'payment_method_id': paymentMethodId,
            'amount': amount,
            'screenshot_url': screenshotUrl,
            'tenant_id': tenantId,
            'status': 'pending',
          })
          .select()
          .single();
      return TransactionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SubscriptionModel?> getSubscription(String tenantId) async {
    try {
      final response = await supabaseClient
          .from('subscriptions')
          .select('*, plans(*)')
          .eq('tenant_id', tenantId)
          .maybeSingle();
      if (response == null) return null;
      return SubscriptionModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? providerTransactionId,
  }) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      if (providerTransactionId != null) {
        updateData['provider_transaction_id'] = providerTransactionId;
      }
      await supabaseClient.from('transactions').update(updateData).eq('id', transactionId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final response = await supabaseClient
          .from('transactions')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> approveTransaction(String transactionId) async {
    try {
      // 1. Get the transaction
      final trxResponse =
          await supabaseClient.from('transactions').select().eq('id', transactionId).single();
      final trx = TransactionModel.fromJson(trxResponse);

      // 2. Get the plan details
      final planResponse = await supabaseClient.from('plans').select().eq('id', trx.planId).single();
      final plan = PlanModel.fromJson(planResponse);

      // 3. Update Transaction Status
      await supabaseClient.from('transactions').update({'status': 'success'}).eq('id', transactionId);

      // 4. Upsert Subscription
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: plan.durationDays));

      await supabaseClient.from('subscriptions').upsert({
        'tenant_id': trx.tenantId,
        'plan_id': trx.planId,
        'status': 'active',
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'tenant_id');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
