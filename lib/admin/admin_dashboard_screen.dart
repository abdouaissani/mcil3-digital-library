import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/subject_model.dart';
import '../models/document_model.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';
import '../core/app_routes.dart';
import '../core/responsive.dart';
import '../widgets/document_list_tile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<SubjectModel> _subjects = [];
  List<DocumentModel> _documents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);
    final subjects = await service.getSubjects();
    final documents = await service.getDocuments(onlyPublished: false);

    if (mounted) {
      setState(() {
        _subjects = subjects;
        _documents = documents;
        _isLoading = false;
      });
    }
  }

  int get _totalDownloads {
    return _documents.fold(0, (sum, doc) => sum + doc.downloadCount);
  }

  int get _totalViews {
    return _documents.fold(0, (sum, doc) => sum + doc.viewCount);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('admin_dashboard')),
        actions: [
          // Switch to Student Mode preview
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.studentHome);
            },
            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
            label: Text(localizations.translate('student_space')),
          ),
          // Logout
          IconButton(
            tooltip: localizations.translate('logout'),
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await supabaseService.signOutAdmin();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 16,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Admin Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supabaseService.currentUserEmail ?? 'MCIL 3 Administrator',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  localizations.translate('admin_desc'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4 Stat Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 750 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              context,
                              isDark,
                              title: localizations.translate('stats_subjects'),
                              value: '${_subjects.length}',
                              icon: Icons.book_rounded,
                              color: AppColors.primary,
                            ),
                            _buildStatCard(
                              context,
                              isDark,
                              title: localizations.translate('stats_documents'),
                              value: '${_documents.length}',
                              icon: Icons.description_rounded,
                              color: AppColors.secondary,
                            ),
                            _buildStatCard(
                              context,
                              isDark,
                              title: localizations.translate('stats_downloads'),
                              value: '$_totalDownloads',
                              icon: Icons.download_rounded,
                              color: AppColors.solutionBadge,
                            ),
                            _buildStatCard(
                              context,
                              isDark,
                              title: localizations.translate('stats_views'),
                              value: '$_totalViews',
                              icon: Icons.visibility_rounded,
                              color: AppColors.examenBadge,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.of(context).pushNamed(
                                AppRoutes.addEditSubject,
                              );
                              if (result == true) _loadDashboardData();
                            },
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(localizations.translate('add_subject')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.of(context).pushNamed(
                                AppRoutes.uploadPdf,
                              );
                              if (result == true) _loadDashboardData();
                            },
                            icon: const Icon(Icons.upload_file_rounded, size: 20),
                            label: Text(localizations.translate('upload_document')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Management Tabs: Subjects vs Documents
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        tabs: [
                          Tab(text: localizations.translate('manage_subjects')),
                          Tab(text: localizations.translate('manage_documents')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab View content
                    SizedBox(
                      height: 550,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Subjects List
                          _subjects.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.book_outlined,
                                          size: 48, color: AppColors.primary),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'لا توجد مواد مسجلة بعد',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'ابدأ بإضافة أول مادة دراسية لتظهر للطلبة في التطبيق.',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.of(context).pushNamed(
                                            AppRoutes.addEditSubject,
                                          );
                                          if (result == true) _loadDashboardData();
                                        },
                                        icon: const Icon(Icons.add),
                                        label: Text(localizations.translate('add_subject')),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _subjects.length,
                                  itemBuilder: (context, index) {
                                    final s = _subjects[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: s.color.withAlpha(30),
                                          child: Text(
                                            s.code,
                                            style: TextStyle(
                                              color: s.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          s.getName(localeProvider.locale),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          '${localizations.translate('semester')} ${s.semester} • Coeff: ${s.coefficient}',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 20),
                                              onPressed: () async {
                                                final result = await Navigator.of(context).pushNamed(
                                                  AppRoutes.addEditSubject,
                                                  arguments: s,
                                                );
                                                if (result == true) _loadDashboardData();
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline,
                                                  size: 20, color: AppColors.error),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Text(localizations.translate('confirm_delete')),
                                                    content: Text(localizations.translate('delete_confirm_msg')),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx, false),
                                                        child: Text(localizations.translate('cancel')),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: AppColors.error,
                                                        ),
                                                        onPressed: () => Navigator.pop(ctx, true),
                                                        child: Text(localizations.translate('delete_subject')),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await supabaseService.deleteSubject(s.id);
                                                  _loadDashboardData();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                          // Tab 2: Documents List
                          _documents.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.upload_file_outlined,
                                          size: 48, color: AppColors.secondary),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'لا توجد ملفات PDF مرفوعة بعد',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'ارفع المحاضرات، سلاسل TD، تمارين TP أو الامتحانات السابقة.',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.of(context).pushNamed(
                                            AppRoutes.uploadPdf,
                                          );
                                          if (result == true) _loadDashboardData();
                                        },
                                        icon: const Icon(Icons.upload_file),
                                        label: Text(localizations.translate('upload_document')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                            itemCount: _documents.length,
                            itemBuilder: (context, index) {
                              final doc = _documents[index];
                              return DocumentListTile(
                                document: doc,
                                isAdminView: true,
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(localizations.translate('confirm_delete')),
                                      content: Text(localizations.translate('delete_confirm_msg')),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text(localizations.translate('cancel')),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                          ),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: Text(localizations.translate('delete_document')),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await supabaseService.deleteDocument(doc.id, doc.filePath);
                                    _loadDashboardData();
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
