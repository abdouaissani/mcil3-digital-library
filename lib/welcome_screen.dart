import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'theme/theme_provider.dart';
import 'theme/app_colors.dart';
import 'core/app_routes.dart';
import 'widgets/language_dialog.dart';
import 'widgets/theme_dialog.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String flag = localeProvider.isArabic
        ? '🇩🇿'
        : (localeProvider.isFrench ? '🇫🇷' : '🇬🇧');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Toolbar: Language & Theme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Pill
                      InkWell(
                        onTap: () => LanguageDialog.show(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(flag, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                localeProvider.locale.languageCode.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                      // Theme Switcher Button
                      IconButton(
                        tooltip: localizations.translate('theme'),
                        icon: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.nightlight_round
                              : (themeProvider.themeMode == ThemeMode.light
                                  ? Icons.wb_sunny_rounded
                                  : Icons.brightness_auto_rounded),
                        ),
                        onPressed: () => ThemeDialog.show(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Brand Logo & Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'MCIL 3',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Digital Library • المكتبة الرقمية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localizations.translate('app_tagline'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // 1. STUDENT SPACE CARD
                  _buildOptionCard(
                    context,
                    isDark: isDark,
                    title: localizations.translate('student_space'),
                    description: localizations.translate('student_desc'),
                    icon: Icons.school_rounded,
                    iconColor: AppColors.primary,
                    buttonLabel: localizations.translate('enter_as_student'),
                    isPrimary: true,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.studentHome);
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. ADMIN SPACE CARD
                  _buildOptionCard(
                    context,
                    isDark: isDark,
                    title: localizations.translate('admin_space'),
                    description: localizations.translate('admin_desc'),
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: AppColors.examenBadge,
                    buttonLabel: localizations.translate('enter_as_admin'),
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.adminLogin);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Dedication & Sadaka Jariya Banner
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.volunteer_activism_rounded,
                                  color: Color(0xFF059669)),
                              SizedBox(width: 10),
                              Text(
                                'صدقة جارية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إلى روح جدتي يايا (راشد فاطمة)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'رحمكِ الله رحمةً واسعة، وجعل ما يُنشر من علم نافع في ميزان حسناتكِ.\n\n« اللهم اجعل هذا العمل علماً نافعاً وأجراً لا ينقطع »',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              const Text(
                                'Developed by: Aissani Abdelouadoud',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('آمين يارب'),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(isDark ? 20 : 15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF10B981).withAlpha(80),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.volunteer_activism_rounded,
                              size: 18, color: Color(0xFF059669)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'صدقة جارية • إلى روح جدتي يايا (راشد فاطمة)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Developed by: Aissani Abdelouadoud',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Color(0xFF059669)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer note
                  Text(
                    'Spécialité MCIL 3 • Master Informatique\nAndroid & Windows Desktop',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String buttonLabel,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withAlpha(120)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? ElevatedButton(
                    onPressed: onTap,
                    child: Text(buttonLabel),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    child: Text(buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
