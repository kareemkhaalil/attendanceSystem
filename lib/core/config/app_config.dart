/// مركز إعدادات التطبيق
/// 
/// في بيئة التطوير: يستخدم القيم الافتراضية (dev keys) تلقائياً
/// في بيئة الإنتاج: تجاوز القيم بـ --dart-define عند البناء:
///   flutter build apk
///     --dart-define=SUPABASE_URL=https://xxx.supabase.co
///     --dart-define=SUPABASE_ANON_KEY=your_prod_key
///
/// ملاحظة أمنية: الـ anonKey هي مفتاح نشر (publishable) وليست سراً.
/// السر الحقيقي هو service_role key الذي يجب ألا يكون في الكود أبداً.
class AppConfig {
  // مفاتيح التطوير كقيم افتراضية — يمكن تجاوزها بـ --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hqzbeqocswgpvizfkygm.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Bot-ptSnohhz23tTrFMDEA_LXj3OLrh',
  );
}
