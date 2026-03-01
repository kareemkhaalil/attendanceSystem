import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.tenantId,
    required super.planId,
    super.paymentMethodId,
    required super.amount,
    super.currency,
    required super.status,
    super.providerTransactionId,
    super.screenshotUrl,
    super.adminNotes,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      planId: json['plan_id'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      status: json['status'] as String,
      providerTransactionId: json['provider_transaction_id'] as String?,
      screenshotUrl: json['screenshot_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'plan_id': planId,
      'payment_method_id': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'provider_transaction_id': providerTransactionId,
      'screenshot_url': screenshotUrl,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
