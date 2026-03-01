import 'package:equatable/equatable.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/features/payment/domain/entities/subscription_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final SubscriptionEntity? subscription;

  const AuthAuthenticated({required this.user, this.subscription});

  @override
  List<Object?> get props => [user, subscription];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
