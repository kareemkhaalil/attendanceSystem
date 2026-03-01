import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String tenantId;
  final String planId;
  final String? paymentMethodId;
  final double amount;
  final String currency;
  final String status;
  final String? providerTransactionId;
  final String? screenshotUrl;
  final String? adminNotes;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.tenantId,
    required this.planId,
    this.paymentMethodId,
    required this.amount,
    this.currency = 'EGP',
    required this.status,
    this.providerTransactionId,
    this.screenshotUrl,
    this.adminNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        planId,
        paymentMethodId,
        amount,
        currency,
        status,
        providerTransactionId,
        screenshotUrl,
        adminNotes,
        createdAt,
      ];
}
