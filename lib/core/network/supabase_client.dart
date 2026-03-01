import 'package:manzoma/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ✅ المفاتيح تُقرأ من AppConfig (--dart-define) وليست مكتوبة هنا
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // التحقق من وجود المفاتيح قبل التهيئة
    AppConfig.validate();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
}

// Extension to make Supabase operations easier
extension SupabaseExtensions on SupabaseClient {
  // Auth helpers
  User? get currentUser => auth.currentUser;
  bool get isAuthenticated => auth.currentUser != null;

  // Database helpers
  SupabaseQueryBuilder table(String tableName) => from(tableName);

  // Storage helpers
  SupabaseStorageClient get storage => Supabase.instance.client.storage;
}
