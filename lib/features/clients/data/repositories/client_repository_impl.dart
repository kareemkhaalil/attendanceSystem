import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ClientEntity>>> getClients({
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final clients = await remoteDataSource.getClients(
          limit: limit,
          offset: offset,
        );
        return Right(clients);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> getClientById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.getClientById(id);
        return Right(client);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> createClient({
    required String name,
    required String plan,
    required DateTime subscriptionStart,
    required DateTime subscriptionEnd,
    required double billingAmount,
    required String billingInterval,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.createClient(
          name: name,
          plan: plan,
          subscriptionStart: subscriptionStart,
          subscriptionEnd: subscriptionEnd,
          billingAmount: billingAmount,
          billingInterval: billingInterval,
        );
        return Right(client);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> updateClient({
    required String id,
    String? name,
    String? plan,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    double? billingAmount,
    String? billingInterval,
    bool? isActive,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.updateClient(
          id: id,
          name: name,
          plan: plan,
          subscriptionStart: subscriptionStart,
          subscriptionEnd: subscriptionEnd,
          billingAmount: billingAmount,
          billingInterval: billingInterval,
          isActive: isActive,
        );
        return Right(client);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteClient(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
