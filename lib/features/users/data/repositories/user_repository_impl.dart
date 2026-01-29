import 'package:dartz/dartz.dart';
import 'package:manzoma/core/enums/user_role.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({
    String? tenantId,
    String? branchId,
    UserRole? role,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getUsers(
          tenantId: tenantId,
          branchId: branchId,
          role: role,
          limit: limit,
          offset: offset,
        );
        return Right(users);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserById(id);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel(
          id: user.id,
          tenantId: user.tenantId,
          branchId: user.branchId,
          email: user.email,
          password: user.password, // إذا كان مطلوب
          role: user.role,
          name: user.name,
          phone: user.phone,
          avatar: user.avatar,
          baseSalary: user.baseSalary,
          allowances: user.allowances,
          deductions: user.deductions,
          workSchedule: user.workSchedule,
          isActive: user.isActive,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );

        final createdUser = await remoteDataSource.createUser(userModel);
        return Right(createdUser);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(
      String id, UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel(
          id: user.id,
          tenantId: user.tenantId,
          branchId: user.branchId,
          email: user.email,
          role: user.role,
          name: user.name,
          phone: user.phone,
          avatar: user.avatar,
          baseSalary: user.baseSalary,
          allowances: user.allowances,
          deductions: user.deductions,
          workSchedule: user.workSchedule,
          isActive: user.isActive,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );

        final updatedUser = await remoteDataSource.updateUser(id, userModel);
        return Right(updatedUser);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUser(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(
    String query, {
    String? tenantId,
    String? role,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.searchUsers(
          query,
          tenantId: tenantId,
          role: role,
        );
        return Right(users);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
