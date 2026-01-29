import 'package:flutter_test/flutter_test.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:manzoma/features/auth/domain/repositories/auth_repository.dart';
import 'package:manzoma/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:manzoma/core/error/failures.dart';

import 'sign_in_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    id: '1',
    email: tEmail,
    name: 'Test User',
    role: UserRole.employee,
    tenantId: '',
  );

  test('should get user from the repository when sign in is successful',
      () async {
    // arrange
    when(mockAuthRepository.signIn(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => const Right(tUser));

    // act
    final result =
        await usecase(const SignInParams(email: tEmail, password: tPassword));

    // assert
    expect(result, const Right(tUser));
    verify(mockAuthRepository.signIn(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when sign in fails', () async {
    // arrange
    const tFailure = AuthFailure('Invalid credentials');
    when(mockAuthRepository.signIn(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result =
        await usecase(const SignInParams(email: tEmail, password: tPassword));

    // assert
    expect(result, const Left(tFailure));
    verify(mockAuthRepository.signIn(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
