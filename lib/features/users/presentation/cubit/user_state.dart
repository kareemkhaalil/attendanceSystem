part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;

  const UserLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class UserCreated extends UserState {
  final List<UserEntity> users;

  const UserCreated({required this.users});

  @override
  List<Object> get props => [users];
}

class UserUpdated extends UserState {
  final List<UserEntity> users;

  const UserUpdated({required this.users});

  @override
  List<Object> get props => [users];
}

class UserDeleted extends UserState {
  final String userId;

  const UserDeleted({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object> get props => [message];
}
