import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../theme/theme_provider.dart';
import '../services/supabase_service.dart';
import '../services/download_service.dart';
import '../theme/app_colors.dart';
import '../core/app_routes.dart';
import '../widgets/language_dialog.dart';
import '../widgets/theme_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final downloadService = Provider.of<DownloadService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String langName = localeProvider.isArabic
        ? 'العربية (🇩🇿)'
        : (localeProvider.isFrench ? 'Français (🇫🇷)' : 'English (🇬🇧)');

    final String themeName = themeProvider.themeMode == ThemeMode.dark
        ? localizations.translate('dark_mode')
        : (themeProvider.themeMode == ThemeMode.light
            ? localizations.translate('light_mode')
            : localizations.translate('system_mode'));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          // 1. PREFERENCES SECTION
          _buildSectionHeader(context, localizations.translate('settings')),
          _buildCard(
            isDark,
            [
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: Text(localizations.translate('language')),
                subtitle: Text(langName),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => LanguageDialog.show(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppColors.secondary),
                title: Text(localizations.translate('theme')),
                subtitle: Text(themeName),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => ThemeDialog.show(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. OFFLINE STORAGE
          _buildSectionHeader(context, localizations.translate('downloads')),
          _buildCard(
            isDark,
            [
              ListTile(
                leading: const Icon(Icons.folder_special_outlined, color: AppColors.warning),
                title: Text(localizations.translate('downloads')),
                subtitle: Text('${downloadService.downloadedFiles.length} ملفات محفوظة محلياً'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.downloads),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. ADMIN PORTAL
          _buildSectionHeader(context, localizations.translate('admin_space')),
          _buildCard(
            isDark,
            [
              if (supabaseService.isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded, color: AppColors.examenBadge),
                  title: Text(localizations.translate('admin_dashboard')),
                  subtitle: Text(supabaseService.currentUserEmail ?? 'Admin'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminDashboard),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: Text(
                    localizations.translate('logout'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    await supabaseService.signOutAdmin();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
                  title: Text(localizations.translate('enter_as_admin')),
                  subtitle: Text(localizations.translate('admin_desc')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminLogin),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 4. SADAKA JARIYA & DEDICATION (صدقة جارية)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF064E3B).withAlpha(50), const Color(0xFF0F172A)]
                    : [const Color(0xFFECFDF5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withAlpha(isDark ? 80 : 120),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withAlpha(isDark ? 20 : 15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Color(0xFF059669),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'صدقة جارية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'إلى روح جدتي يايا (راشد فاطمة)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'رحمكِ الله رحمةً واسعة، وجعل ما يُنشر من علم نافع في ميزان حسناتكِ.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFF10B981).withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '« اللهم اجعل هذا العمل علماً نافعاً وأجراً لا ينقطع »',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.code_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Developed by: Aissani Abdelouadoud',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. ABOUT & APP VERSION
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MCIL 3 Digital Library',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 • Mobile & Desktop',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}
