import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/subject_model.dart';
import '../models/document_model.dart';
import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';

class UploadPdfScreen extends StatefulWidget {
  final SubjectModel? preselectedSubject;

  const UploadPdfScreen({super.key, this.preselectedSubject});

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSubjectId;
  String _selectedDocType = 'cours';
  final _titleController = TextEditingController();
  final _chapterController = TextEditingController();
  final _yearController = TextEditingController(text: '2023-2024');

  // Primary PDF file
  String? _pickedPdfName;
  Uint8List? _pickedPdfBytes;
  int _pickedPdfSize = 0;

  // Solution PDF file (Optional)
  bool _attachSolution = false;
  String? _pickedSolutionName;
  Uint8List? _pickedSolutionBytes;
  int _pickedSolutionSize = 0;

  bool _isPublished = true;
  bool _isUploading = false;
  List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.preselectedSubject?.id;
    _loadSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _chapterController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final service = Provider.of<SupabaseService>(context, listen: false);
    final subs = await service.getSubjects();
    if (mounted) {
      setState(() {
        _subjects = subs;
        if (_selectedSubjectId == null && _subjects.isNotEmpty) {
          _selectedSubjectId = _subjects.first.id;
        }
      });
    }
  }

  Future<void> _pickMainPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.xFile.readAsBytes();
      final size = await file.length() ?? bytes.length;
      setState(() {
        _pickedPdfName = file.name;
        _pickedPdfBytes = bytes;
        _pickedPdfSize = size;
        if (_titleController.text.isEmpty) {
          _titleController.text =
              file.name.replaceAll('.pdf', '').replaceAll('_', ' ');
        }
      });
    }
  }

  Future<void> _pickSolutionPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.xFile.readAsBytes();
      final size = await file.length() ?? bytes.length;
      setState(() {
        _pickedSolutionName = file.name;
        _pickedSolutionBytes = bytes;
        _pickedSolutionSize = size;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Future<void> _submitUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المادة الدراسية')),
      );
      return;
    }
    if (_pickedPdfBytes == null || _pickedPdfName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد ملف PDF الأساسي')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final service = Provider.of<SupabaseService>(context, listen: false);
      final subject = _subjects.firstWhere((s) => s.id == _selectedSubjectId);

      // 1. Upload main PDF
      final mainUrl = await service.uploadStorageFile(
        bytes: _pickedPdfBytes!,
        path: 'subjects/${subject.code.toLowerCase()}',
        fileName: _pickedPdfName!,
      );

      // 2. Upload optional solution if provided
      String? solUrl;
      String? solName;
      String? solSize;
      if (_attachSolution && _pickedSolutionBytes != null && _pickedSolutionName != null) {
        solUrl = await service.uploadStorageFile(
          bytes: _pickedSolutionBytes!,
          path: 'subjects/${subject.code.toLowerCase()}/solutions',
          fileName: _pickedSolutionName!,
        );
        solName = _pickedSolutionName;
        solSize = _formatSize(_pickedSolutionSize);
      }

      // 3. Save Document Model
      final newDoc = DocumentModel(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        subjectId: _selectedSubjectId!,
        subjectName: subject.nameFr,
        title: _titleController.text.trim(),
        docType: _selectedDocType,
        chapterOrSeries: _chapterController.text.trim(),
        academicYear: _yearController.text.trim(),
        filePath: 'subjects/${subject.code.toLowerCase()}/$_pickedPdfName',
        fileUrl: mainUrl ?? '',
        fileName: _pickedPdfName!,
        fileSizeBytes: _pickedPdfSize,
        fileSizeReadable: _formatSize(_pickedPdfSize),
        hasSolution: _attachSolution && solUrl != null,
        solutionFileUrl: solUrl,
        solutionFileName: solName,
        solutionFileSizeReadable: solSize,
        isPublished: _isPublished,
        createdAt: DateTime.now(),
      );

      final success = await service.saveDocument(newDoc);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('upload_success'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final docTypes = [
      {'key': 'cours', 'label': localizations.translate('cours')},
      {'key': 'td', 'label': localizations.translate('td')},
      {'key': 'tp', 'label': localizations.translate('tp')},
      {'key': 'examen', 'label': localizations.translate('examens')},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('upload_document')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Subject Dropdown
              Text(localizations.translate('subjects'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubjectId,
                items: _subjects.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.code} - ${s.getName(localeProvider.locale)}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedSubjectId = val);
                },
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // 2. Document Type
              Text('نوع المحتوى (Document Type)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: docTypes.map((type) {
                  final isSelected = _selectedDocType == type['key'];
                  return ChoiceChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedDocType = type['key']!),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 3. Document Title
              Text('عنوان الملف (Title)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Chapitre 01 : Introduction aux Design Patterns',
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // 4. Chapter / Series & Academic Year Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.translate('chapter_series'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _chapterController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Chapitre 01 / Série TD 01',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.translate('academic_year'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            hintText: '2023-2024',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Main PDF Picker Box
              Text('الملف الأساسي (Primary PDF File)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickMainPdf,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _pickedPdfName != null
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: _pickedPdfName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedPdfName != null
                                  ? _pickedPdfName!
                                  : localizations.translate('select_pdf_file'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _pickedPdfName != null
                                    ? AppColors.primary
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_pickedPdfName != null)
                              Text(
                                _formatSize(_pickedPdfSize),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.folder_open_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 6. Optional Solution Checkbox & Picker
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _attachSolution,
                          activeColor: AppColors.solutionBadge,
                          onChanged: (val) {
                            setState(() => _attachSolution = val ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            localizations.translate('attach_solution_checkbox'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (_attachSolution) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickSolutionPdf,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.solutionBadge.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.solutionBadge.withAlpha(80)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded,
                                  color: AppColors.solutionBadge),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _pickedSolutionName != null
                                      ? '$_pickedSolutionName (${_formatSize(_pickedSolutionSize)})'
                                      : localizations.translate('select_solution_file'),
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.attach_file, color: AppColors.solutionBadge),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 7. Publish Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  localizations.translate('is_published_checkbox'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  _isPublished
                      ? 'الملف سيكون مرئياً ومتاحاً للتحميل فوراً لجميع الطلبة'
                      : 'الملف سيبقى مخفياً ولن يظهر للطلبة حتى يتم تفعيله',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _isPublished,
                activeThumbColor: AppColors.success,
                onChanged: (val) => setState(() => _isPublished = val),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _submitUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    _isUploading
                        ? localizations.translate('uploading_progress')
                        : localizations.translate('upload_document'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
