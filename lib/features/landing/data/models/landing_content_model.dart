import '../../domain/entities/landing_content_entity.dart';

class LandingContentModel extends LandingContentEntity {
  const LandingContentModel({
    required super.id,
    required super.section,
    required super.content,
    required super.isActive,
    super.updatedAt,
  });

  factory LandingContentModel.fromJson(Map<String, dynamic> json) {
    return LandingContentModel(
      id: json['id'] as String,
      section: json['section'] as String,
      content: Map<String, dynamic>.from(json['content'] as Map),
      isActive: json['is_active'] as bool? ?? true,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section,
        'content': content,
        'is_active': isActive,
      };
}
