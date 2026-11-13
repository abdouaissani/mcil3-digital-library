import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject_model.dart';
import '../models/document_model.dart';
import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/empty_state_view.dart';
import '../core/app_routes.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final SubjectModel subject;

  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<DocumentModel> _allDocuments = [];

  final List<String> _tabs = ['cours', 'td', 'tp', 'examen'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);
    final docs = await service.getDocuments(
      subjectId: widget.subject.id,
      onlyPublished: true,
    );
    if (mounted) {
      setState(() {
        _allDocuments = docs;
        _isLoading = false;
      });
    }
  }

  List<DocumentModel> _getDocsForType(String type) {
    return _allDocuments
        .where((d) => d.docType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subjectName = widget.subject.getName(localeProvider.locale);
    final subjectDesc = widget.subject.getDescription(localeProvider.locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.code),
        actions: [
          if (supabaseService.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: localizations.translate('upload_document'),
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRoutes.uploadPdf,
                  arguments: widget.subject,
                );
                if (result == true) {
                  _loadDocuments();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    // Subject Header Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.subject.color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: widget.subject.color.withAlpha(80)),
                                ),
                                child: Text(
                                  widget.subject.code,
                                  style: TextStyle(
                                    color: widget.subject.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${localizations.translate('semester')} ${widget.subject.semester}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${localizations.translate('coefficient')}: ${widget.subject.coefficient}  •  ${localizations.translate('credits')}: ${widget.subject.credit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subjectName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (subjectDesc.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              subjectDesc,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 4 Academic Tabs (Cours, TD, TP, Examens)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: [
                          Tab(text: localizations.translate('cours')),
                          Tab(text: localizations.translate('td')),
                          Tab(text: localizations.translate('tp')),
                          Tab(text: localizations.translate('examens')),
                        ],
                      ),
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabs.map((type) {
                          final docs = _getDocsForType(type);
                          if (docs.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.folder_open_rounded,
                              title: localizations.translate('no_documents_yet'),
                              description:
                                  'يمكن للمسؤول رفع ملفات جديدة وسيتم تحديثها فوراً.',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 750;
                                if (isWide) {
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      mainAxisExtent: 155,
                                    ),
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      return DocumentListTile(
                                        document: docs[index],
                                        isAdminView: supabaseService.isLoggedIn,
                                      );
                                    },
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    return DocumentListTile(
                                      document: docs[index],
                                      isAdminView: supabaseService.isLoggedIn,
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
                                          await supabaseService.deleteDocument(
                                            docs[index].id,
                                            docs[index].filePath,
                                          );
                                          _loadDocuments();
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
