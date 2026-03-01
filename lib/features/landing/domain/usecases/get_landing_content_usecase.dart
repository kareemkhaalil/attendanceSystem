import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/landing_content_entity.dart';
import '../repositories/landing_repository.dart';

class GetLandingContentUseCase
    implements UseCase<List<LandingContentEntity>, NoParams> {
  final LandingRepository repository;
  GetLandingContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<LandingContentEntity>>> call(
      NoParams params) async {
    return await repository.getLandingContent();
  }
}
