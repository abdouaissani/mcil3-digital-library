import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/download_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import '../core/app_routes.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final downloadService = Provider.of<DownloadService>(context);
    final files = downloadService.downloadedFiles;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('downloads')),
      ),
      body: files.isEmpty
          ? EmptyStateView(
              icon: Icons.cloud_download_outlined,
              title: localizations.translate('no_downloads_yet'),
              description:
                  'قم بتصفح المواد وحفظ المحاضرات والتمارين لتتمكن من مراجعتها في أي وقت وبدون إنترنت.',
              buttonText: localizations.translate('all_subjects'),
              onButtonPressed: () {
                Navigator.of(context).pop();
              },
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                final file = files[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 12, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  localizations.translate('offline_ready'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (file.subjectName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                file.subjectName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            file.fileSize,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        file.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // 1. Open inside app
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.pdfViewer,
                                  arguments: {
                                    'title': file.title,
                                    'localPath': file.localPath,
                                  },
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf_rounded,
                                  size: 16),
                              label: Text(localizations.translate('view_pdf')),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. Open in external app
                          IconButton(
                            tooltip:
                                localizations.translate('open_in_external_app'),
                            onPressed: () {
                              downloadService.openExternalFile(file.localPath);
                            },
                            icon: const Icon(Icons.open_in_new_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey.withAlpha(30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // 3. Delete file
                          IconButton(
                            tooltip:
                                localizations.translate('delete_from_device'),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(localizations
                                      .translate('confirm_delete')),
                                  content: Text(localizations
                                      .translate('delete_confirm_msg')),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(
                                          localizations.translate('cancel')),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(localizations
                                          .translate('delete_document')),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await downloadService.deleteLocalFile(file.documentId);
                              }
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.error.withAlpha(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
    );
  }
}
