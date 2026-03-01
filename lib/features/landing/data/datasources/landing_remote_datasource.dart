import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/landing_content_model.dart';

abstract class LandingRemoteDataSource {
  Future<List<LandingContentModel>> getLandingContent();
  Future<void> updateSection({
    required String section,
    required Map<String, dynamic> content,
  });
}

class LandingRemoteDataSourceImpl implements LandingRemoteDataSource {
  final SupabaseClient supabaseClient;
  LandingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<LandingContentModel>> getLandingContent() async {
    try {
      final response = await supabaseClient
          .from('landing_content')
          .select()
          .eq('is_active', true)
          .order('section');

      return (response as List)
          .map((e) => LandingContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateSection({
    required String section,
    required Map<String, dynamic> content,
  }) async {
    try {
      // Upsert: update if exists, insert if not
      await supabaseClient.from('landing_content').upsert({
        'section': section,
        'content': content,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'section');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
