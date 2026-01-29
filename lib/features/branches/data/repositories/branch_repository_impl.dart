import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_datasource.dart';
import '../models/branch_model.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BranchRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<BranchEntity>>> getBranches({
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final branches = await remoteDataSource.getBranches(
          tenantId: tenantId,
          limit: limit,
          offset: offset,
        );
        return Right(branches);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> getBranchById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final branch = await remoteDataSource.getBranchById(id);
        return Right(branch);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> createBranch(
      BranchEntity branch) async {
    if (await networkInfo.isConnected) {
      try {
        final branchModel = BranchModel(
          id: branch.id,
          tenantId: branch.tenantId,
          name: branch.name,
          latitude: branch.latitude,
          longitude: branch.longitude,
          address: branch.address,
          radiusMeters: branch.radiusMeters,
          details: branch.details,
          createdAt: branch.createdAt,
          updatedAt: branch.updatedAt,
        );

        final createdBranch = await remoteDataSource.createBranch(branchModel);
        return Right(createdBranch);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> updateBranch(
      String id, BranchEntity branch) async {
    if (await networkInfo.isConnected) {
      try {
        final branchModel = BranchModel(
          id: branch.id,
          tenantId: branch.tenantId,
          name: branch.name,
          latitude: branch.latitude,
          longitude: branch.longitude,
          address: branch.address,
          radiusMeters: branch.radiusMeters,
          details: branch.details,
          createdAt: branch.createdAt,
          updatedAt: branch.updatedAt,
        );

        final updatedBranch =
            await remoteDataSource.updateBranch(id, branchModel);
        return Right(updatedBranch);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBranch(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBranch(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<BranchEntity>>> searchBranches(
    String query, {
    String? tenantId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final branches = await remoteDataSource.searchBranches(
          query,
          tenantId: tenantId,
        );
        return Right(branches);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
