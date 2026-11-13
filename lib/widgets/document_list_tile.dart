import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../services/download_service.dart';
import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../core/app_routes.dart';

class DocumentListTile extends StatelessWidget {
  final DocumentModel document;
  final bool isAdminView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentListTile({
    super.key,
    required this.document,
    this.isAdminView = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final downloadService = Provider.of<DownloadService>(context);
    final supabaseService = Provider.of<SupabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDownloaded = downloadService.isDownloaded(document.id);
    final isDownloading = downloadService.isDownloading(document.id);
    final progress = downloadService.getProgress(document.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 6),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges Row
          Row(
            children: [
              // Type Badge (Cours / TD / TP / Examen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: document.badgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: document.badgeColor.withAlpha(80)),
                ),
                child: Text(
                  document.getLocalizedType(context),
                  style: TextStyle(
                    color: document.badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chapter or Series Badge
              if (document.chapterOrSeries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    document.chapterOrSeries,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),

              // Solution Available Pill
              if (document.hasSolution) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.solutionBadge.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.solutionBadge.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 12, color: AppColors.solutionBadge),
                      const SizedBox(width: 4),
                      Text(
                        localizations.translate('solution_available'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.solutionBadge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Published / Hidden Indicator in Admin View
              if (isAdminView)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: document.isPublished
                        ? AppColors.success.withAlpha(25)
                        : AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    document.isPublished
                        ? localizations.translate('published')
                        : localizations.translate('hidden'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: document.isPublished ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            document.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.3,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
          ),

          const SizedBox(height: 8),

          // File metadata row: Size, Subject name, Academic year
          Row(
            children: [
              Icon(Icons.insert_drive_file_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              const SizedBox(width: 4),
              Text(
                document.fileSizeReadable,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              if (document.academicYear.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_outlined,
                    size: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 4),
                Text(
                  document.academicYear,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              if (document.subjectName != null && document.subjectName!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    document.subjectName!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons Bar
          Row(
            children: [
              // 1. View PDF Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    supabaseService.incrementViews(document.id);
                    Navigator.of(context).pushNamed(
                      AppRoutes.pdfViewer,
                      arguments: {
                        'title': document.title,
                        'url': document.fileUrl,
                        'document': document,
                      },
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: Text(
                    localizations.translate('view_pdf'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Download / Offline status Button
              if (isDownloading)
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              else
                IconButton(
                  tooltip: isDownloaded
                      ? localizations.translate('downloaded')
                      : localizations.translate('download_pdf'),
                  onPressed: isDownloaded
                      ? () {
                          // Already downloaded: open local copy
                          final localFile = downloadService.getDownloadedFile(document.id);
                          if (localFile != null) {
                            Navigator.of(context).pushNamed(
                              AppRoutes.pdfViewer,
                              arguments: {
                                'title': document.title,
                                'localPath': localFile.localPath,
                                'document': document,
                              },
                            );
                          }
                        }
                      : () async {
                          final path = await downloadService.downloadDocument(document: document);
                          if (path != null) {
                            supabaseService.incrementDownloads(document.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${localizations.translate('downloaded')}: ${document.title}',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        },
                  icon: Icon(
                    isDownloaded
                        ? Icons.check_circle_rounded
                        : Icons.file_download_outlined,
                    color: isDownloaded ? AppColors.success : AppColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDownloaded
                        ? AppColors.success.withAlpha(20)
                        : AppColors.primary.withAlpha(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

              // 3. Optional Solution Button
              if (document.hasSolution && document.solutionFileUrl != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: localizations.translate('view_solution'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.pdfViewer,
                      arguments: {
                        'title': '${document.title} (${localizations.translate('solutions')})',
                        'url': document.solutionFileUrl,
                        'document': document,
                        'isSolution': true,
                      },
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.solutionBadge),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.solutionBadge.withAlpha(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],

              // Admin specific controls (Edit / Delete)
              if (isAdminView) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: localizations.translate('edit_document'),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  tooltip: localizations.translate('delete_document'),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
