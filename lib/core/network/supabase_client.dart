import 'package:manzoma/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
}

// Extension to make Supabase operations easier
extension SupabaseExtensions on SupabaseClient {
  User? get currentUser => auth.currentUser;
  bool get isAuthenticated => auth.currentUser != null;

  SupabaseQueryBuilder table(String tableName) => from(tableName);

  SupabaseStorageClient get storage => Supabase.instance.client.storage;
}
