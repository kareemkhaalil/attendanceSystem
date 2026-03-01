import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/landing_repository.dart';

class UpdateLandingContentUseCase
    implements UseCase<void, UpdateLandingParams> {
  final LandingRepository repository;
  UpdateLandingContentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLandingParams params) async {
    return await repository.updateSection(
      section: params.section,
      content: params.content,
    );
  }
}

class UpdateLandingParams extends Equatable {
  final String section;
  final Map<String, dynamic> content;
  const UpdateLandingParams({required this.section, required this.content});

  @override
  List<Object> get props => [section, content];
}
