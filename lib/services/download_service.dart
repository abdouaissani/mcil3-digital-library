import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../models/downloaded_file_model.dart';
import '../models/document_model.dart';

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, double> _downloadProgress = {};
  List<DownloadedFileModel> _downloadedFiles = [];

  List<DownloadedFileModel> get downloadedFiles => List.unmodifiable(_downloadedFiles);

  double getProgress(String documentId) => _downloadProgress[documentId] ?? 0.0;
  bool isDownloading(String documentId) => _downloadProgress.containsKey(documentId);

  Future<void> initialize() async {
    if (kIsWeb) return;
    await _loadDownloadedFilesFromPrefs();
  }

  Future<void> _loadDownloadedFilesFromPrefs() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(AppConstants.keyDownloadedFiles) ?? [];
    _downloadedFiles = list
        .map((item) => DownloadedFileModel.fromJson(item))
        .where((file) => File(file.localPath).existsSync())
        .toList();
    notifyListeners();
  }

  Future<void> _saveDownloadedFilesToPrefs() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final list = _downloadedFiles.map((f) => f.toJson()).toList();
    await prefs.setStringList(AppConstants.keyDownloadedFiles, list);
  }

  bool isDownloaded(String documentId) {
    if (kIsWeb) return false;
    return _downloadedFiles.any((f) => f.documentId == documentId && File(f.localPath).existsSync());
  }

  DownloadedFileModel? getDownloadedFile(String documentId) {
    if (kIsWeb) return null;
    try {
      return _downloadedFiles.firstWhere((f) => f.documentId == documentId);
    } catch (_) {
      return null;
    }
  }

  Future<String?> downloadDocument({
    required DocumentModel document,
    bool isSolution = false,
  }) async {
    final targetUrl = isSolution ? document.solutionFileUrl : document.fileUrl;
    final targetFileName = isSolution
        ? (document.solutionFileName ?? 'solution_${document.fileName}')
        : document.fileName;
    final fileId = isSolution ? '${document.id}_sol' : document.id;

    if (targetUrl == null || targetUrl.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return targetUrl;
    }

    try {
      _downloadProgress[fileId] = 0.05;
      notifyListeners();

      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/MCIL3_Library');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final sanitizedName = targetFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = '${downloadsDir.path}/$sanitizedName';

      await _dio.download(
        targetUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress[fileId] = received / total;
            notifyListeners();
          }
        },
      );

      final downloadedModel = DownloadedFileModel(
        documentId: fileId,
        title: isSolution ? '${document.title} (الحل)' : document.title,
        fileName: sanitizedName,
        localPath: savePath,
        fileSize: isSolution
            ? (document.solutionFileSizeReadable ?? '1 MB')
            : document.fileSizeReadable,
        downloadedAt: DateTime.now(),
        subjectName: document.subjectName ?? '',
        docType: document.docType,
      );

      _downloadedFiles.removeWhere((f) => f.documentId == fileId);
      _downloadedFiles.insert(0, downloadedModel);
      await _saveDownloadedFilesToPrefs();

      _downloadProgress.remove(fileId);
      notifyListeners();
      return savePath;
    } catch (e) {
      debugPrint('Download Error: $e');
      _downloadProgress.remove(fileId);
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteLocalFile(String documentId) async {
    if (kIsWeb) return false;
    try {
      final index = _downloadedFiles.indexWhere((f) => f.documentId == documentId);
      if (index >= 0) {
        final file = File(_downloadedFiles[index].localPath);
        if (await file.exists()) {
          await file.delete();
        }
        _downloadedFiles.removeAt(index);
        await _saveDownloadedFilesToPrefs();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting local file: $e');
      return false;
    }
  }

  Future<void> openExternalFile(String localPath) async {
    if (kIsWeb) {
      final uri = Uri.parse(localPath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    try {
      await OpenFilex.open(localPath);
    } catch (e) {
      debugPrint('Could not open file: $e');
    }
  }
}
