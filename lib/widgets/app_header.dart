import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../theme/theme_provider.dart';
import '../services/download_service.dart';
import '../services/supabase_service.dart';
import '../core/app_routes.dart';
import '../theme/app_colors.dart';
import 'language_dialog.dart';
import 'theme_dialog.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final bool showSearch;
  final bool showDownloads;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.showSearch = true,
    this.showDownloads = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final downloadService = Provider.of<DownloadService>(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String flag = localeProvider.isArabic
        ? '🇩🇿'
        : (localeProvider.isFrench ? '🇫🇷' : '🇬🇧');

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      titleSpacing: 16,
      title: Row(
        children: [
          if (showBack)
            IconButton(
              icon: Icon(
                localeProvider.isRtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                size: 20,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'MCIL 3',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title ?? localizations.translate('app_name'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (showSearch)
          IconButton(
            tooltip: localizations.translate('search'),
            icon: const Icon(Icons.search_rounded, size: 22),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.search);
            },
          ),
        if (showDownloads)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: localizations.translate('downloads'),
                icon: const Icon(Icons.download_done_rounded, size: 22),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.downloads);
                },
              ),
              if (downloadService.downloadedFiles.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${downloadService.downloadedFiles.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        // Language Selector Button
        InkWell(
          onTap: () => LanguageDialog.show(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  localeProvider.locale.languageCode.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        // Theme Toggle Button
        IconButton(
          tooltip: localizations.translate('theme'),
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.nightlight_round
                : (themeProvider.themeMode == ThemeMode.light
                    ? Icons.wb_sunny_rounded
                    : Icons.brightness_auto_rounded),
            size: 20,
          ),
          onPressed: () => ThemeDialog.show(context),
        ),
        // Admin Quick Badge / Action
        if (supabaseService.isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 4.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.adminDashboard);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.examenBadge.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.examenBadge),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 14, color: AppColors.examenBadge),
                    SizedBox(width: 4),
                    Text(
                      'ADMIN',
                      style: TextStyle(
                        color: AppColors.examenBadge,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 6),
      ],
    );
  }
}
