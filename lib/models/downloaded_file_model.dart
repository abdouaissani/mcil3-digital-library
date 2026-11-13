import 'dart:convert';

class DownloadedFileModel {
  final String documentId;
  final String title;
  final String fileName;
  final String localPath;
  final String fileSize;
  final DateTime downloadedAt;
  final String subjectName;
  final String docType;

  DownloadedFileModel({
    required this.documentId,
    required this.title,
    required this.fileName,
    required this.localPath,
    required this.fileSize,
    required this.downloadedAt,
    required this.subjectName,
    required this.docType,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'title': title,
      'fileName': fileName,
      'localPath': localPath,
      'fileSize': fileSize,
      'downloadedAt': downloadedAt.toIso8601String(),
      'subjectName': subjectName,
      'docType': docType,
    };
  }

  factory DownloadedFileModel.fromMap(Map<String, dynamic> map) {
    return DownloadedFileModel(
      documentId: map['documentId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      localPath: map['localPath'] as String? ?? '',
      fileSize: map['fileSize'] as String? ?? '',
      downloadedAt: map['downloadedAt'] != null
          ? DateTime.tryParse(map['downloadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      subjectName: map['subjectName'] as String? ?? '',
      docType: map['docType'] as String? ?? 'cours',
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadedFileModel.fromJson(String source) =>
      DownloadedFileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
