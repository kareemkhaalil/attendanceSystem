import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String type; // 'paymob', 'manual'
  final String name;
  final Map<String, dynamic> details;
  final bool isActive;

  const PaymentMethodEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, type, name, details, isActive];
}
