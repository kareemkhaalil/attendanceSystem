import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/features/users/domain/usecases/update_users_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUsersUseCase getUsersUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUsersUsecase updateUsersUsecase;
  final DeleteUserUseCase deleteUserUseCase;

  UserCubit({
    required this.getUsersUseCase,
    required this.createUserUseCase,
    required this.updateUsersUsecase,
    required this.deleteUserUseCase,
  }) : super(UserInitial());

  Future<void> getUsers({
    String? tenantId,
    String? branchId,
    UserRole? role,
    int? limit,
    int? offset,
  }) async {
    emit(UserLoading());

    final result = await getUsersUseCase(GetUsersParams(
      tenantId: tenantId,
      branchId: branchId,
      role: role,
      limit: limit,
      offset: offset,
    ));

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (users) => emit(UserLoaded(users: users)),
    );
  }

  Future<void> createUser(UserEntity user) async {
    emit(UserLoading());

    final result = await createUserUseCase(CreateUserParams(user: user));

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (createdUser) {
        // Refresh the users list after creating a new user
        if (state is UserCreated) {
          final currentUsers = (state as UserCreated).users;
          emit(UserCreated(users: [...currentUsers, createdUser]));
        } else {
          emit(UserCreated(users: [createdUser]));
        }
      },
    );
  }

  void resetState() {
    emit(UserInitial());
  }

  void updateUser(UserEntity user) async {
    emit(UserLoading());

    final result =
        await updateUsersUsecase(UpdateUserParams(id: user.id, user: user));

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (updatedUser) {
        // Refresh the users list after updating a user
        if (state is UserUpdated) {
          final currentUsers = (state as UserUpdated).users;
          emit(UserUpdated(users: [...currentUsers, updatedUser]));
        } else {
          emit(UserUpdated(users: [updatedUser]));
        }
      },
    );
  }

  Future<void> deleteUser(String userId) async {
    emit(UserLoading());

    final result = await deleteUserUseCase(DeleteUserParams(id: userId));

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (_) => emit(UserDeleted(userId: userId)),
    );
  }
}
