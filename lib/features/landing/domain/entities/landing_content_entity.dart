class LandingContentEntity {
  final String id;
  final String section; // 'hero' | 'features' | 'pricing' | 'stats' | 'cta'
  final Map<String, dynamic> content;
  final bool isActive;
  final DateTime? updatedAt;

  const LandingContentEntity({
    required this.id,
    required this.section,
    required this.content,
    required this.isActive,
    this.updatedAt,
  });
}
