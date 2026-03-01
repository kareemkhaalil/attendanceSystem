import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/landing_content_entity.dart';

abstract class LandingRepository {
  Future<Either<Failure, List<LandingContentEntity>>> getLandingContent();
  Future<Either<Failure, void>> updateSection({
    required String section,
    required Map<String, dynamic> content,
  });
}
