import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? _throwMissingEnvError('SUPABASE_URL');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? _throwMissingEnvError('SUPABASE_ANON_KEY');

  static Never _throwMissingEnvError(String key) {
    throw Exception(
      'Missing environment variable: $key. '
      'Please create a .env file with the required variables. '
      'See .env.example for reference.',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
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
