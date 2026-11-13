class AppConstants {
  static const String appName = 'MCIL 3 Digital Library';
  static const String appVersion = '1.0.0';
  static const String appSubTitleAr = 'المكتبة الرقمية لطلبة MCIL 3';
  static const String appSubTitleFr = 'Bibliothèque Numérique MCIL 3';
  static const String appSubTitleEn = 'Digital Library for MCIL 3';

  // ===========================================================================
  // 🔑 بيانات الاتصال بـ SUPABASE الخاصة بك (Supabase Credentials)
  // الصق هنا رابط المشروع (Project URL) ومفتاح الوصول العام (anon public key)
  // تجدهما في لوحة تحكم Supabase -> Project Settings -> API
  // ===========================================================================
  static const String supabaseUrl = 'https://gukqsnxpvljhybjlmnop.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable__0hs5inUPdjZuHLSxnW_iQ_Y8y8Gfdb';
  static const String documentsBucket = 'mcil3_documents';

  // SharedPreferences Keys
  static const String keyLocale = 'user_locale';
  static const String keyThemeMode = 'user_theme_mode';
  static const String keyFirstLaunch = 'is_first_launch';
  static const String keyAdminRemember = 'admin_remember_login';
  static const String keyDownloadedFiles = 'downloaded_files_registry';

  // Document Types
  static const String docTypeCours = 'cours';
  static const String docTypeTd = 'td';
  static const String docTypeTp = 'tp';
  static const String docTypeExamen = 'examen';

  static const List<String> allDocTypes = [
    docTypeCours,
    docTypeTd,
    docTypeTp,
    docTypeExamen,
  ];
}
