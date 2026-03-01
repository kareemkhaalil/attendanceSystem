import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/features/auth/data/models/user_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../../payment/domain/usecases/get_subscription_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final GetSubscriptionUseCase _getSubscriptionUseCase;

  AuthCubit({
    SignInUseCase? signInUseCase,
    SignUpUseCase? signUpUseCase,
    SignOutUseCase? signOutUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
  })  : _signInUseCase = signInUseCase ?? sl<SignInUseCase>(),
        _signUpUseCase = signUpUseCase ?? sl<SignUpUseCase>(),
        _signOutUseCase = signOutUseCase ?? sl<SignOutUseCase>(),
        _getCurrentUserUseCase =
            getCurrentUserUseCase ?? sl<GetCurrentUserUseCase>(),
        _resetPasswordUseCase =
            resetPasswordUseCase ?? sl<ResetPasswordUseCase>(),
        _getSubscriptionUseCase = sl<GetSubscriptionUseCase>(),
        super(AuthInitial());

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final localUser = SharedPrefHelper.getUser();
    if (localUser != null) {
      final subResult = await _getSubscriptionUseCase(localUser.tenantId);
      final subscription = subResult.fold((l) => null, (r) => r);
      emit(AuthAuthenticated(user: localUser, subscription: subscription));
      return;
    }

    final result = await _getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) async {
        if (user != null) {
          SharedPrefHelper.saveUser(UserModel.fromEntity(user));
          final subResult = await _getSubscriptionUseCase(user.tenantId);
          final subscription = subResult.fold((l) => null, (r) => r);
          emit(AuthAuthenticated(user: user, subscription: subscription));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  /// Sign in user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _signInUseCase(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) async {
        await SharedPrefHelper.saveUser(UserModel.fromEntity(user));
        final subResult = await _getSubscriptionUseCase(user.tenantId);
        final subscription = subResult.fold((l) => null, (r) => r);
        emit(AuthAuthenticated(user: user, subscription: subscription));
      },
    );
  }

  /// Sign up user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    emit(AuthLoading());

    final result = await _signUpUseCase(
      SignUpParams(
        email: email,
        password: password,
        name: name,
        role: role,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) async {
        await SharedPrefHelper.saveUser(UserModel.fromEntity(user));
        final subResult = await _getSubscriptionUseCase(user.tenantId);
        final subscription = subResult.fold((l) => null, (r) => r);
        emit(AuthAuthenticated(user: user, subscription: subscription));
      },
    );
  }

  /// Sign out user
  Future<void> signOut() async {
    emit(AuthLoading());

    final result = await _signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) async {
        await SharedPrefHelper.clearUser();
        emit(AuthUnauthenticated());
      },
    );
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(email: email),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }
}
