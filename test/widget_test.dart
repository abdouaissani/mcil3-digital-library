import 'package:flutter_test/flutter_test.dart';
import 'package:student_admin_app/models/subject_model.dart';
import 'package:student_admin_app/models/document_model.dart';

void main() {
  group('MCIL 3 Models Tests', () {
    test('SubjectModel default semester should be 5 and serialization works', () {
      final now = DateTime.now();
      final subject = SubjectModel(
        id: 'sub-1',
        code: 'COMPIL',
        nameAr: 'مترجمات',
        nameFr: 'Compilation',
        nameEn: 'Compilation',
        semester: 5,
        coefficient: 3,
        credit: 5,
        createdAt: now,
      );

      expect(subject.semester, 5);
      expect(subject.code, 'COMPIL');

      final json = subject.toJson();
      expect(json['semester'], 5);
      expect(json['code'], 'COMPIL');

      final fromJson = SubjectModel.fromJson(json);
      expect(fromJson.semester, 5);
      expect(fromJson.nameAr, 'مترجمات');
    });

    test('SubjectModel S6 semester check', () {
      final now = DateTime.now();
      final subject = SubjectModel(
        id: 'sub-2',
        code: 'BDD',
        nameAr: 'قواعد بيانات',
        nameFr: 'Bases de Données',
        nameEn: 'Databases',
        semester: 6,
        createdAt: now,
      );

      expect(subject.semester, 6);
      final json = subject.toJson();
      expect(json['semester'], 6);
    });

    test('DocumentModel serialization works', () {
      final now = DateTime.now();
      final doc = DocumentModel(
        id: 'doc-1',
        subjectId: 'sub-1',
        title: 'Chapitre 01: Introduction',
        docType: 'cours',
        chapterOrSeries: 'Chapitre 01',
        filePath: 'subjects/compil/chap1.pdf',
        fileUrl: 'https://example.com/chap1.pdf',
        fileName: 'chap1.pdf',
        createdAt: now,
      );

      expect(doc.docType, 'cours');

      final json = doc.toJson();
      expect(json['doc_type'], 'cours');
      expect(json['file_name'], 'chap1.pdf');

      final fromJson = DocumentModel.fromJson(json);
      expect(fromJson.title, 'Chapitre 01: Introduction');
      expect(fromJson.docType, 'cours');
    });
  });
}
