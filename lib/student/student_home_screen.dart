import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/download_service.dart';
import '../models/subject_model.dart';
import '../models/document_model.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../core/app_routes.dart';
import '../widgets/app_header.dart';
import '../widgets/subject_card.dart';
import '../widgets/document_list_tile.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedSemester = 0; // 0 = All, 5 = S5, 6 = S6
  bool _isLoading = true;
  List<SubjectModel> _subjects = [];
  List<DocumentModel> _recentDocs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);
    final subjects = await service.getSubjects(
      semester: _selectedSemester == 0 ? null : _selectedSemester,
    );
    final recents = await service.getRecentDocuments(limit: 6);

    if (mounted) {
      setState(() {
        _subjects = subjects;
        _recentDocs = recents;
        _isLoading = false;
      });
    }
  }

  void _onSemesterChanged(int index) {
    if (_selectedSemester == index) return;
    setState(() {
      _selectedSemester = index;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final downloadService = Provider.of<DownloadService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideDesktop = screenWidth >= 850;

    final mainContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWideDesktop ? 36 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HERO BANNER
                      _buildHeroBanner(context, isDark, isWideDesktop),
                      const SizedBox(height: 24),

                      // 2. SEARCH BAR SHORTCUT
                      _buildSearchBar(context, isDark, localizations),
                      const SizedBox(height: 24),

                      // 3. SEMESTER FILTER CHIPS
                      _buildSemesterFilter(context, localizations),
                      const SizedBox(height: 24),

                      // 4. RECENT ADDITIONS SECTION
                      if (_recentDocs.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.translate('recent_additions'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.search);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: Text(localizations.translate('all')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Adaptive Recent Documents (Grid on desktop, List on mobile)
                        if (isWideDesktop)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              mainAxisExtent: 155,
                            ),
                            itemCount: _recentDocs.length,
                            itemBuilder: (context, index) {
                              return DocumentListTile(
                                  document: _recentDocs[index]);
                            },
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentDocs.length,
                            itemBuilder: (context, index) {
                              return DocumentListTile(
                                  document: _recentDocs[index]);
                            },
                          ),
                        const SizedBox(height: 28),
                      ],

                      // 5. SUBJECTS SECTION HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.translate('all_subjects'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_subjects.length} ${localizations.translate('subjects')}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid of Subject Cards or Empty State
                      if (_subjects.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_stories_outlined,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد مواد مضافة بعد',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'سيتم تحديث ونشر المواد والمحاضرات فور رفعها من قبل مسؤول المكتبة.',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            if (constraints.maxWidth > 1400) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth > 1050) {
                              crossAxisCount = 3;
                            } else if (constraints.maxWidth > 650) {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 195,
                              ),
                              itemCount: _subjects.length,
                              itemBuilder: (context, index) {
                                return SubjectCard(subject: _subjects[index]);
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );

    // Desktop Layout (with sidebar navigation rail)
    if (isWideDesktop) {
      return Scaffold(
        appBar: const AppHeader(showSearch: false),
        body: Row(
          children: [
            // Desktop Navigation Rail
            NavigationRail(
              selectedIndex: 0,
              backgroundColor:
                  isDark ? AppColors.darkSurface : Colors.white,
              indicatorColor: AppColors.primary.withAlpha(25),
              extended: screenWidth >= 1150,
              minWidth: 72,
              minExtendedWidth: 190,
              onDestinationSelected: (index) {
                if (index == 1) {
                  Navigator.of(context).pushNamed(AppRoutes.search);
                } else if (index == 2) {
                  Navigator.of(context).pushNamed(AppRoutes.downloads);
                } else if (index == 3) {
                  Navigator.of(context).pushNamed(AppRoutes.settings);
                }
              },
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon:
                      const Icon(Icons.home_rounded, color: AppColors.primary),
                  label: Text(localizations.translate('home')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.search_rounded),
                  selectedIcon:
                      const Icon(Icons.search_rounded, color: AppColors.primary),
                  label: Text(localizations.translate('search')),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: downloadService.downloadedFiles.isNotEmpty,
                    label: Text('${downloadService.downloadedFiles.length}'),
                    child: const Icon(Icons.download_done_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: downloadService.downloadedFiles.isNotEmpty,
                    label: Text('${downloadService.downloadedFiles.length}'),
                    child: const Icon(Icons.download_done_rounded,
                        color: AppColors.primary),
                  ),
                  label: Text(localizations.translate('downloads')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon:
                      const Icon(Icons.settings_rounded, color: AppColors.primary),
                  label: Text(localizations.translate('settings')),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),

            // Main Content Area
            Expanded(child: mainContent),
          ],
        ),
      );
    }

    // Mobile Layout (with Bottom Navigation Bar)
    return Scaffold(
      appBar: const AppHeader(),
      body: mainContent,
      bottomNavigationBar: _buildBottomNav(context, localizations, isDark),
    );
  }

  Widget _buildHeroBanner(
      BuildContext context, bool isDark, bool isWideDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWideDesktop ? 32 : 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '📚 MCIL 3 • Université',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'MCIL 3 – Digital Library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWideDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).translate('app_tagline'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isWideDesktop)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, bool isDark, AppLocalizations localizations) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.search);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 15 : 5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.translate('search_placeholder'),
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterFilter(
      BuildContext context, AppLocalizations localizations) {
    final filters = [
      {'index': 0, 'label': localizations.translate('all')},
      {'index': 5, 'label': localizations.translate('semester_5')},
      {'index': 6, 'label': localizations.translate('semester_6')},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedSemester == f['index'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: ChoiceChip(
              label: Text(f['label'] as String),
              selected: isSelected,
              onSelected: (_) => _onSemesterChanged(f['index'] as int),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNav(
      BuildContext context, AppLocalizations localizations, bool isDark) {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      indicatorColor: AppColors.primary.withAlpha(30),
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context).pushNamed(AppRoutes.search);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(AppRoutes.downloads);
        } else if (index == 3) {
          Navigator.of(context).pushNamed(AppRoutes.settings);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon:
              const Icon(Icons.home_rounded, color: AppColors.primary),
          label: localizations.translate('home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_rounded),
          selectedIcon:
              const Icon(Icons.search_rounded, color: AppColors.primary),
          label: localizations.translate('search'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.download_done_rounded),
          selectedIcon: const Icon(Icons.download_done_rounded,
              color: AppColors.primary),
          label: localizations.translate('downloads'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon:
              const Icon(Icons.settings_rounded, color: AppColors.primary),
          label: localizations.translate('settings'),
        ),
      ],
    );
  }
}
