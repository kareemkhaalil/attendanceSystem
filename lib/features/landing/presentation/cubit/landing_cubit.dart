import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_landing_content_usecase.dart';
import '../../domain/usecases/update_landing_content_usecase.dart';
import 'landing_state.dart';

class LandingCubit extends Cubit<LandingState> {
  final GetLandingContentUseCase _getContent;
  final UpdateLandingContentUseCase _updateContent;

  LandingCubit({
    GetLandingContentUseCase? getContent,
    UpdateLandingContentUseCase? updateContent,
  })  : _getContent = getContent ?? sl<GetLandingContentUseCase>(),
        _updateContent = updateContent ?? sl<UpdateLandingContentUseCase>(),
        super(LandingInitial());

  Future<void> loadContent() async {
    emit(LandingLoading());
    final result = await _getContent(const NoParams());
    result.fold(
      (failure) => emit(LandingError(message: failure.message)),
      (sections) => emit(LandingLoaded(sections: sections)),
    );
  }

  Future<void> updateSection(
      String section, Map<String, dynamic> content) async {
    final result = await _updateContent(
      UpdateLandingParams(section: section, content: content),
    );
    result.fold(
      (failure) => emit(LandingError(message: failure.message)),
      (_) {
        emit(LandingUpdateSuccess());
        loadContent(); // أعد تحميل الكونتنت بعد الحفظ
      },
    );
  }
}
