import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document_model.dart';
import '../services/download_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String? url;
  final String? localPath;
  final DocumentModel? document;
  final bool isSolution;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.localPath,
    this.document,
    this.isSolution = false,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final downloadService = Provider.of<DownloadService>(context);

    final bool hasLocalFile = !kIsWeb &&
        widget.localPath != null &&
        File(widget.localPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Zoom In
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            tooltip: 'Zoom In',
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
            },
          ),
          // Zoom Out
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            tooltip: 'Zoom Out',
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
            },
          ),
          // Open in External App / New Tab
          if (hasLocalFile)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: localizations.translate('open_in_external_app'),
              onPressed: () {
                downloadService.openExternalFile(widget.localPath!);
              },
            )
          else if (kIsWeb && widget.url != null)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'فتح في تبويب جديد',
              onPressed: () {
                launchUrl(Uri.parse(widget.url!), mode: LaunchMode.externalApplication);
              },
            ),
          // Download action if remote and document model is provided
          if (!hasLocalFile && widget.document != null)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: localizations.translate('download_pdf'),
              onPressed: () async {
                final path = await downloadService.downloadDocument(
                  document: widget.document!,
                  isSolution: widget.isSolution,
                );
                if (path != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('downloaded')),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (!kIsWeb && hasLocalFile)
            SfPdfViewer.file(
              File(widget.localPath!),
              controller: _pdfViewerController,
              onDocumentLoaded: (details) {
                setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              },
            )
          else if (widget.url != null)
            SfPdfViewer.network(
              widget.url!,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) {
                setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              },
            )
          else
            Center(
              child: Text(localizations.translate('no_results_found')),
            ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (_errorMessage != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'خطأ أثناء تحميل ملف PDF',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                      },
                      child: Text(localizations.translate('retry')),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
