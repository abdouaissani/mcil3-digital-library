import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // General & App Name
      'app_name': 'MCIL 3 المكتبة الرقمية',
      'app_tagline': 'جميع المصادر الأكاديمية لطلبة MCIL 3 في مكان واحد',
      'welcome': 'مرحباً بك',
      'student_space': 'فضاء الطالب',
      'admin_space': 'فضاء المسؤول (Admin)',
      'student_desc': 'تصفح وتحميل المحاضرات والتمارين والامتحانات بدون حساب',
      'admin_desc': 'إدارة المواد، رفع ملفات PDF، والتحكم في المحتوى',
      'enter_as_student': 'الدخول كطالب',
      'enter_as_admin': 'تسجيل دخول المسؤول',
      'language': 'اللغة',
      'theme': 'المظهر',
      'arabic': 'العربية',
      'french': 'الفرنسية (Français)',
      'english': 'الإنجليزية (English)',
      'light_mode': 'الوضع الفاتح',
      'dark_mode': 'الوضع الداكن',
      'system_mode': 'تلقائي (حسب النظام)',

      // Navigation & Sections
      'home': 'الرئيسية',
      'subjects': 'المواد الدراسية',
      'documents': 'الملفات والدروس',
      'downloads': 'الملفات المحمّلة',
      'search': 'بحث',
      'settings': 'الإعدادات',
      'admin_dashboard': 'لوحة الإدارة',
      'manage_subjects': 'إدارة المواد',
      'manage_documents': 'إدارة الملفات',

      // Academic Types
      'cours': 'المحاضرات',
      'td': 'الأعمال الموجهة (TD)',
      'tp': 'الأعمال التطبيقية (TP)',
      'examens': 'الامتحانات السابقة',
      'solutions': 'الحلول النموذجية',
      'all': 'الكل',
      'semester_1': 'السداسي الخامس (S5)',
      'semester_2': 'السداسي السادس (S6)',
      'semester_5': 'السداسي الخامس (S5)',
      'semester_6': 'السداسي السادس (S6)',
      'semester': 'السداسي',
      'coefficient': 'المعامل',
      'credits': 'الرصيد',

      // Actions & Buttons
      'view_pdf': 'عرض PDF',
      'download_pdf': 'تحميل الملف',
      'downloading': 'جاري التحميل...',
      'downloaded': 'تم التحميل',
      'view_solution': 'عرض الحل',
      'download_solution': 'تحميل الحل',
      'add_subject': 'إضافة مادة جديدة',
      'edit_subject': 'تعديل المادة',
      'delete_subject': 'حذف المادة',
      'upload_document': 'رفع ملف PDF جديد',
      'edit_document': 'تعديل الملف',
      'delete_document': 'حذف الملف',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'confirm_delete': 'تأكيد الحذف',
      'delete_confirm_msg': 'هل أنت متأكد من رغبتك في حذف هذا العنصر نهائياً؟',
      'retry': 'إعادة المحاولة',
      'filter': 'تصفية',
      'back': 'رجوع',

      // Search & Filters
      'search_placeholder': 'ابحث عن مادة، درس، تمرين، أو امتحان...',
      'no_results_found': 'لم يتم العثور على أي نتائج',
      'no_documents_yet': 'لا توجد ملفات متوفرة حالياً في هذا القسم',
      'no_downloads_yet': 'لم تقم بتحميل أي ملف بعد. يمكنك تصفح المواد وتحميل الملفات للدراسة بدون إنترنت.',
      'recent_additions': 'أحدث الإضافات الأكاديمية',
      'all_subjects': 'جميع المواد الدراسية',
      'popular_resources': 'المصادر الأكثر تحميلاً',

      // File Details
      'file_name': 'اسم الملف',
      'file_size': 'الحجم',
      'upload_date': 'تاريخ الإضافة',
      'status': 'الحالة',
      'published': 'منشور',
      'hidden': 'مخفي',
      'solution_available': 'يتوفر حل نموذجي',
      'no_solution': 'بدون حل',
      'chapter_series': 'الفصل / السلسلة',
      'academic_year': 'السنة الجامعية',

      // Admin & Auth
      'admin_login': 'تسجيل دخول المسؤول',
      'admin_login_sub': 'أدخل بيانات الحساب لإدارة مكتبة MCIL 3',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login_button': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'login_failed': 'فشل تسجيل الدخول. يرجى التحقق من البريد وكلمة المرور.',
      'stats_subjects': 'إجمالي المواد',
      'stats_documents': 'إجمالي الملفات',
      'stats_downloads': 'مرات التحميل',
      'stats_views': 'مرات المشاهدة',
      'select_pdf_file': 'اختيار ملف PDF',
      'select_solution_file': 'اختيار ملف الحل (اختياري)',
      'attach_solution_checkbox': 'إرفاق حل نموذجي لهذا الملف',
      'is_published_checkbox': 'نشر الملف فوراً للطلبة',
      'uploading_progress': 'جاري الرفع...',
      'upload_success': 'تم رفع وتحديث الملف بنجاح!',
      'subject_saved_success': 'تم حفظ بيانات المادة بنجاح!',

      // Offline
      'offline_ready': 'متوفر بدون إنترنت',
      'open_in_external_app': 'فتح في تطبيق خارجي',
      'delete_from_device': 'حذف من الجهاز',
    },
    'fr': {
      // General & App Name
      'app_name': 'Bibliothèque Numérique MCIL 3',
      'app_tagline': 'Toutes les ressources académiques de MCIL 3 en un seul endroit',
      'welcome': 'Bienvenue',
      'student_space': 'Espace Étudiant',
      'admin_space': 'Espace Administrateur',
      'student_desc': 'Consultez et téléchargez les cours, TD et examens sans compte',
      'admin_desc': 'Gérez les modules, téléversez des PDF et contrôlez le contenu',
      'enter_as_student': 'Entrer comme étudiant',
      'enter_as_admin': 'Connexion administrateur',
      'language': 'Langue',
      'theme': 'Thème',
      'arabic': 'Arabe (العربية)',
      'french': 'Français',
      'english': 'Anglais (English)',
      'light_mode': 'Mode Clair',
      'dark_mode': 'Mode Sombre',
      'system_mode': 'Automatique (Système)',

      // Navigation & Sections
      'home': 'Accueil',
      'subjects': 'Modules',
      'documents': 'Documents',
      'downloads': 'Téléchargements',
      'search': 'Recherche',
      'settings': 'Paramètres',
      'admin_dashboard': 'Tableau de bord',
      'manage_subjects': 'Gestion des modules',
      'manage_documents': 'Gestion des documents',

      // Academic Types
      'cours': 'Cours',
      'td': 'Travaux Dirigés (TD)',
      'tp': 'Travaux Pratiques (TP)',
      'examens': 'Examens',
      'solutions': 'Solutions',
      'all': 'Tous',
      'semester_1': 'Semestre 5 (S5)',
      'semester_2': 'Semestre 6 (S6)',
      'semester_5': 'Semestre 5 (S5)',
      'semester_6': 'Semestre 6 (S6)',
      'semester': 'Semestre',
      'coefficient': 'Coefficient',
      'credits': 'Crédits',

      // Actions & Buttons
      'view_pdf': 'Consulter PDF',
      'download_pdf': 'Télécharger',
      'downloading': 'Téléchargement...',
      'downloaded': 'Téléchargé',
      'view_solution': 'Voir la solution',
      'download_solution': 'Télécharger la solution',
      'add_subject': 'Ajouter un module',
      'edit_subject': 'Modifier le module',
      'delete_subject': 'Supprimer le module',
      'upload_document': 'Téléverser un PDF',
      'edit_document': 'Modifier le document',
      'delete_document': 'Supprimer le document',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'confirm_delete': 'Confirmer la suppression',
      'delete_confirm_msg': 'Êtes-vous sûr de vouloir supprimer définitivement cet élément ?',
      'retry': 'Réessayer',
      'filter': 'Filtrer',
      'back': 'Retour',

      // Search & Filters
      'search_placeholder': 'Rechercher un module, cours, TD ou examen...',
      'no_results_found': 'Aucun résultat trouvé',
      'no_documents_yet': 'Aucun document disponible dans cette section pour le moment',
      'no_downloads_yet': 'Aucun fichier téléchargé. Téléchargez vos cours pour les réviser hors-ligne.',
      'recent_additions': 'Récemment ajoutés',
      'all_subjects': 'Tous les modules',
      'popular_resources': 'Ressources les plus téléchargées',

      // File Details
      'file_name': 'Nom du fichier',
      'file_size': 'Taille',
      'upload_date': 'Date d\'ajout',
      'status': 'Statut',
      'published': 'Publié',
      'hidden': 'Masqué',
      'solution_available': 'Solution disponible',
      'no_solution': 'Sans solution',
      'chapter_series': 'Chapitre / Série',
      'academic_year': 'Année universitaire',

      // Admin & Auth
      'admin_login': 'Connexion Administrateur',
      'admin_login_sub': 'Connectez-vous pour administrer la bibliothèque MCIL 3',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'login_button': 'Se connecter',
      'logout': 'Se déconnecter',
      'login_failed': 'Échec de connexion. Vérifiez vos identifiants.',
      'stats_subjects': 'Total Modules',
      'stats_documents': 'Total Fichiers',
      'stats_downloads': 'Téléchargements',
      'stats_views': 'Consultations',
      'select_pdf_file': 'Sélectionner le PDF',
      'select_solution_file': 'Sélectionner la solution (optionnel)',
      'attach_solution_checkbox': 'Joindre une solution à ce document',
      'is_published_checkbox': 'Publier immédiatement pour les étudiants',
      'uploading_progress': 'Téléversement en cours...',
      'upload_success': 'Document enregistré avec succès !',
      'subject_saved_success': 'Module enregistré avec succès !',

      // Offline
      'offline_ready': 'Disponible hors-ligne',
      'open_in_external_app': 'Ouvrir dans une application externe',
      'delete_from_device': 'Supprimer du stockage',
    },
    'en': {
      // General & App Name
      'app_name': 'MCIL 3 Digital Library',
      'app_tagline': 'All MCIL 3 academic resources in one unified platform',
      'welcome': 'Welcome',
      'student_space': 'Student Portal',
      'admin_space': 'Admin Portal',
      'student_desc': 'Browse and download courses, tutorials, and exams without login',
      'admin_desc': 'Manage modules, upload PDF documents, and organize curriculum',
      'enter_as_student': 'Enter as Student',
      'enter_as_admin': 'Admin Login',
      'language': 'Language',
      'theme': 'Theme',
      'arabic': 'Arabic (العربية)',
      'french': 'French (Français)',
      'english': 'English',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'system_mode': 'System Default',

      // Navigation & Sections
      'home': 'Home',
      'subjects': 'Subjects',
      'documents': 'Documents',
      'downloads': 'Downloads',
      'search': 'Search',
      'settings': 'Settings',
      'admin_dashboard': 'Admin Dashboard',
      'manage_subjects': 'Manage Subjects',
      'manage_documents': 'Manage Documents',

      // Academic Types
      'cours': 'Lectures (Cours)',
      'td': 'Tutorials (TD)',
      'tp': 'Lab Practicals (TP)',
      'examens': 'Past Exams',
      'solutions': 'Solutions',
      'all': 'All',
      'semester_1': 'Semester 5 (S5)',
      'semester_2': 'Semester 6 (S6)',
      'semester_5': 'Semester 5 (S5)',
      'semester_6': 'Semester 6 (S6)',
      'semester': 'Semester',
      'coefficient': 'Coefficient',
      'credits': 'Credits',

      // Actions & Buttons
      'view_pdf': 'View PDF',
      'download_pdf': 'Download',
      'downloading': 'Downloading...',
      'downloaded': 'Downloaded',
      'view_solution': 'View Solution',
      'download_solution': 'Download Solution',
      'add_subject': 'Add New Subject',
      'edit_subject': 'Edit Subject',
      'delete_subject': 'Delete Subject',
      'upload_document': 'Upload New PDF',
      'edit_document': 'Edit Document',
      'delete_document': 'Delete Document',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm_delete': 'Confirm Deletion',
      'delete_confirm_msg': 'Are you sure you want to permanently delete this item?',
      'retry': 'Retry',
      'filter': 'Filter',
      'back': 'Back',

      // Search & Filters
      'search_placeholder': 'Search subject, lecture, tutorial, or exam...',
      'no_results_found': 'No results found',
      'no_documents_yet': 'No documents available in this section yet',
      'no_downloads_yet': 'No downloaded documents yet. Download lectures to study offline anytime.',
      'recent_additions': 'Recent Academic Additions',
      'all_subjects': 'All Subjects',
      'popular_resources': 'Most Downloaded Resources',

      // File Details
      'file_name': 'File Name',
      'file_size': 'File Size',
      'upload_date': 'Uploaded Date',
      'status': 'Status',
      'published': 'Published',
      'hidden': 'Hidden',
      'solution_available': 'Solution Available',
      'no_solution': 'No Solution',
      'chapter_series': 'Chapter / Series',
      'academic_year': 'Academic Year',

      // Admin & Auth
      'admin_login': 'Admin Login',
      'admin_login_sub': 'Sign in to manage the MCIL 3 Digital Library',
      'email': 'Email Address',
      'password': 'Password',
      'login_button': 'Sign In',
      'logout': 'Sign Out',
      'login_failed': 'Login failed. Please verify your email and password.',
      'stats_subjects': 'Total Subjects',
      'stats_documents': 'Total Documents',
      'stats_downloads': 'Total Downloads',
      'stats_views': 'Total Views',
      'select_pdf_file': 'Select PDF File',
      'select_solution_file': 'Select Solution File (Optional)',
      'attach_solution_checkbox': 'Attach a solution to this document',
      'is_published_checkbox': 'Publish immediately for students',
      'uploading_progress': 'Uploading...',
      'upload_success': 'Document uploaded and published successfully!',
      'subject_saved_success': 'Subject saved successfully!',

      // Offline
      'offline_ready': 'Available Offline',
      'open_in_external_app': 'Open in External Viewer',
      'delete_from_device': 'Delete from Device',
    },
  };

  String translate(String key) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  bool get isRtl => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
