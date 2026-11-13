
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/app_routes.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'services/supabase_service.dart';
import 'services/download_service.dart';

import 'splash_screen.dart';
import 'welcome_screen.dart';
import 'student/student_home_screen.dart';
import 'student/subject_details_screen.dart';
import 'student/pdf_viewer_screen.dart';
import 'student/downloads_screen.dart';
import 'student/search_screen.dart';
import 'student/settings_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/add_edit_subject_screen.dart';
import 'admin/upload_pdf_screen.dart';
import 'models/subject_model.dart';
import 'models/document_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  runApp(Mcil3DigitalLibraryApp(
    supabaseService: supabaseService,
  ));
}

class Mcil3DigitalLibraryApp extends StatelessWidget {
  final SupabaseService supabaseService;

  const Mcil3DigitalLibraryApp({
    super.key,
    required this.supabaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: supabaseService),
        ChangeNotifierProvider(create: (_) => DownloadService()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('fr'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );

                case AppRoutes.welcome:
                  return MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  );

                case AppRoutes.studentHome:
                  return MaterialPageRoute(
                    builder: (_) => const StudentHomeScreen(),
                  );

                case AppRoutes.subjectDetails:
                  final subject = settings.arguments as SubjectModel;
                  return MaterialPageRoute(
                    builder: (_) =>
                        SubjectDetailsScreen(subject: subject),
                  );

                case AppRoutes.pdfViewer:
                  final args =
                      settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(
                      title: args['title'] as String? ?? 'Document',
                      url: args['url'] as String?,
                      localPath: args['localPath'] as String?,
                      document: args['document'] as DocumentModel?,
                      isSolution:
                          args['isSolution'] as bool? ?? false,
                    ),
                  );

                case AppRoutes.downloads:
                  return MaterialPageRoute(
                    builder: (_) => const DownloadsScreen(),
                  );

                case AppRoutes.search:
                  return MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  );

                case AppRoutes.settings:
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );

                case AppRoutes.adminLogin:
                  return MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  );

                case AppRoutes.adminDashboard:
                  return MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  );

                case AppRoutes.addEditSubject:
                  final subject = settings.arguments as SubjectModel?;
                  return MaterialPageRoute(
                    builder: (_) =>
                        AddEditSubjectScreen(subject: subject),
                  );

                case AppRoutes.uploadPdf:
                  final subject = settings.arguments as SubjectModel?;
                  return MaterialPageRoute(
                    builder: (_) =>
                        UploadPdfScreen(preselectedSubject: subject),
                  );

                default:
                  return MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
