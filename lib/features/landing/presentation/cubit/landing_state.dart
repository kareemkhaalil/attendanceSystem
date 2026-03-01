import 'package:equatable/equatable.dart';
import '../../domain/entities/landing_content_entity.dart';

abstract class LandingState extends Equatable {
  const LandingState();
  @override
  List<Object?> get props => [];
}

class LandingInitial extends LandingState {}

class LandingLoading extends LandingState {}

class LandingLoaded extends LandingState {
  final List<LandingContentEntity> sections;
  const LandingLoaded({required this.sections});

  /// بيجيب الكونتنت بتاع سيكشن معين
  Map<String, dynamic> getSection(String section) {
    try {
      return sections.firstWhere((s) => s.section == section).content;
    } catch (_) {
      return {};
    }
  }

  @override
  List<Object?> get props => [sections];
}

class LandingError extends LandingState {
  final String message;
  const LandingError({required this.message});
  @override
  List<Object?> get props => [message];
}

class LandingUpdateSuccess extends LandingState {}
