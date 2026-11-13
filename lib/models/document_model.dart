import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';

class DocumentModel {
  final String id;
  final String subjectId;
  final String? subjectName;
  final String title;
  final String docType; // 'cours', 'td', 'tp', 'examen'
  final String chapterOrSeries; // e.g. "Chapitre 01", "Série TD 01"
  final String academicYear; // e.g. "2023-2024"
  final String filePath;
  final String fileUrl;
  final String fileName;
  final int fileSizeBytes;
  final String fileSizeReadable;
  final bool isSolution;
  final bool hasSolution;
  final String? solutionFileUrl;
  final String? solutionFileName;
  final String? solutionFileSizeReadable;
  final bool isPublished;
  final int downloadCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DocumentModel({
    required this.id,
    required this.subjectId,
    this.subjectName,
    required this.title,
    required this.docType,
    this.chapterOrSeries = '',
    this.academicYear = '',
    required this.filePath,
    required this.fileUrl,
    required this.fileName,
    this.fileSizeBytes = 0,
    this.fileSizeReadable = '0 KB',
    this.isSolution = false,
    this.hasSolution = false,
    this.solutionFileUrl,
    this.solutionFileName,
    this.solutionFileSizeReadable,
    this.isPublished = true,
    this.downloadCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Color get badgeColor {
    switch (docType.toLowerCase()) {
      case 'cours':
        return AppColors.coursBadge;
      case 'td':
        return AppColors.tdBadge;
      case 'tp':
        return AppColors.tpBadge;
      case 'examen':
        return AppColors.examenBadge;
      default:
        return AppColors.primary;
    }
  }

  String getLocalizedType(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (docType.toLowerCase()) {
      case 'cours':
        return localizations.translate('cours');
      case 'td':
        return localizations.translate('td');
      case 'tp':
        return localizations.translate('tp');
      case 'examen':
        return localizations.translate('examens');
      default:
        return docType.toUpperCase();
    }
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      subjectName: json['subjects'] != null
          ? (json['subjects'] is Map ? json['subjects']['name_fr'] : null)
          : null,
      title: json['title'] as String? ?? '',
      docType: json['doc_type'] as String? ?? 'cours',
      chapterOrSeries: json['chapter_or_series'] as String? ?? '',
      academicYear: json['academic_year'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      fileSizeReadable: json['file_size_readable'] as String? ?? '0 KB',
      isSolution: json['is_solution'] as bool? ?? false,
      hasSolution: json['has_solution'] as bool? ?? false,
      solutionFileUrl: json['solution_file_url'] as String?,
      solutionFileName: json['solution_file_name'] as String?,
      solutionFileSizeReadable: json['solution_file_size_readable'] as String?,
      isPublished: json['is_published'] as bool? ?? true,
      downloadCount: (json['download_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'title': title,
      'doc_type': docType,
      'chapter_or_series': chapterOrSeries,
      'academic_year': academicYear,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size_bytes': fileSizeBytes,
      'file_size_readable': fileSizeReadable,
      'is_solution': isSolution,
      'has_solution': hasSolution,
      'solution_file_url': solutionFileUrl,
      'solution_file_name': solutionFileName,
      'solution_file_size_readable': solutionFileSizeReadable,
      'is_published': isPublished,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? title,
    String? docType,
    String? chapterOrSeries,
    String? academicYear,
    String? filePath,
    String? fileUrl,
    String? fileName,
    int? fileSizeBytes,
    String? fileSizeReadable,
    bool? isSolution,
    bool? hasSolution,
    String? solutionFileUrl,
    String? solutionFileName,
    String? solutionFileSizeReadable,
    bool? isPublished,
    int? downloadCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      docType: docType ?? this.docType,
      chapterOrSeries: chapterOrSeries ?? this.chapterOrSeries,
      academicYear: academicYear ?? this.academicYear,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileSizeReadable: fileSizeReadable ?? this.fileSizeReadable,
      isSolution: isSolution ?? this.isSolution,
      hasSolution: hasSolution ?? this.hasSolution,
      solutionFileUrl: solutionFileUrl ?? this.solutionFileUrl,
      solutionFileName: solutionFileName ?? this.solutionFileName,
      solutionFileSizeReadable: solutionFileSizeReadable ?? this.solutionFileSizeReadable,
      isPublished: isPublished ?? this.isPublished,
      downloadCount: downloadCount ?? this.downloadCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
