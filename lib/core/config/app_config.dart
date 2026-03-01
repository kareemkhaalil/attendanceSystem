/// مركز إعدادات التطبيق - يقرأ المفاتيح من --dart-define عند البناء
/// طريقة الاستخدام عند البناء:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key
/// أو عبر ملف launch.json في VS Code / run configuration في Android Studio
class AppConfig {
  // ✅ المفاتيح الحساسة تُقرأ من --dart-define وليست مكتوبة في الكود
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // لا قيمة افتراضية في الإنتاج
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// التحقق من أن المفاتيح محددة قبل تشغيل التطبيق
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception(
        '❌ SUPABASE_URL غير محدد.\n'
        'شغّل التطبيق هكذا:\n'
        'flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception(
        '❌ SUPABASE_ANON_KEY غير محدد.\n'
        'شغّل التطبيق هكذا:\n'
        'flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }
}
