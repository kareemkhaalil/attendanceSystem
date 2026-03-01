import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/landing_content_entity.dart';
import '../../domain/repositories/landing_repository.dart';
import '../datasources/landing_remote_datasource.dart';

class LandingRepositoryImpl implements LandingRepository {
  final LandingRemoteDataSource remoteDataSource;
  LandingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LandingContentEntity>>>
      getLandingContent() async {
    try {
      final result = await remoteDataSource.getLandingContent();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSection({
    required String section,
    required Map<String, dynamic> content,
  }) async {
    try {
      await remoteDataSource.updateSection(section: section, content: content);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
