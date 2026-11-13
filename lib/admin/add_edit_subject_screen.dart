
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject_model.dart';
import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final SubjectModel? subject;

  const AddEditSubjectScreen({
    super.key,
    this.subject,
  });

  @override
  State<AddEditSubjectScreen> createState() =>
      _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState
    extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameArController;
  late TextEditingController _nameFrController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descFrController;
  late TextEditingController _descEnController;
  late TextEditingController _coeffController;
  late TextEditingController _creditController;

  // Database allows only semester 1 and 2.
  int _semester = 1;

  String _selectedColorHex = '#2563EB';
  bool _isLoading = false;

  final List<String> _colorOptions = [
    '#2563EB',
    '#7C3AED',
    '#059669',
    '#DC2626',
    '#D97706',
    '#0891B2',
    '#4F46E5',
    '#E11D48',
  ];

  @override
  void initState() {
    super.initState();

    final s = widget.subject;

    _codeController =
        TextEditingController(text: s?.code ?? '');

    _nameArController =
        TextEditingController(text: s?.nameAr ?? '');

    _nameFrController =
        TextEditingController(text: s?.nameFr ?? '');

    _nameEnController =
        TextEditingController(text: s?.nameEn ?? '');

    _descArController =
        TextEditingController(text: s?.descriptionAr ?? '');

    _descFrController =
        TextEditingController(text: s?.descriptionFr ?? '');

    _descEnController =
        TextEditingController(text: s?.descriptionEn ?? '');

    _coeffController = TextEditingController(
      text: '${s?.coefficient ?? 2}',
    );

    _creditController = TextEditingController(
      text: '${s?.credit ?? 4}',
    );

    // Prevent invalid semester values when editing old records.
    _semester = (s?.semester == 1 || s?.semester == 2)
        ? s!.semester
        : 1;

    _selectedColorHex = s?.colorHex ?? '#2563EB';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameFrController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descFrController.dispose();
    _descEnController.dispose();
    _coeffController.dispose();
    _creditController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_semester != 1 && _semester != 2) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = Provider.of<SupabaseService>(
        context,
        listen: false,
      );

      final updated = SubjectModel(
        id: widget.subject?.id ??
            'sub-${DateTime.now().millisecondsSinceEpoch}',

        code: _codeController.text.trim().toUpperCase(),

        nameAr: _nameArController.text.trim(),
        nameFr: _nameFrController.text.trim(),
        nameEn: _nameEnController.text.trim(),

        descriptionAr: _descArController.text.trim(),
        descriptionFr: _descFrController.text.trim(),
        descriptionEn: _descEnController.text.trim(),

        semester: _semester,

        coefficient:
            int.tryParse(_coeffController.text) ?? 1,

        credit:
            int.tryParse(_creditController.text) ?? 1,

        colorHex: _selectedColorHex,

        createdAt:
            widget.subject?.createdAt ?? DateTime.now(),

        updatedAt: DateTime.now(),
      );

      final success = await service.saveSubject(updated);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate(
                'subject_saved_success',
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isNew = widget.subject == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew
              ? localizations.translate('add_subject')
              : localizations.translate('edit_subject'),
        ),
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
                  // SUBJECT CODE

                  const Text(
                    'رمز المادة (Code)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. GL301',
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'مطلوب'
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // ARABIC NAME

                  const Text(
                    'اسم المادة بالعربية (Ar)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _nameArController,
                    decoration: const InputDecoration(
                      hintText: 'اسم المادة بالعربية',
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'مطلوب'
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // FRENCH NAME

                  const Text(
                    'Nom du module en français (Fr)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _nameFrController,
                    decoration: const InputDecoration(
                      hintText: 'Nom du module',
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'مطلوب'
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // ENGLISH NAME

                  const Text(
                    'Subject name in English (En)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _nameEnController,
                    decoration: const InputDecoration(
                      hintText: 'Subject name',
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'مطلوب'
                            : null,
                  ),

                  const SizedBox(height: 20),

                  // SEMESTER, COEFFICIENT AND CREDITS

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('semester'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            DropdownButtonFormField<int>(
                              initialValue: _semester,

                              decoration:
                                  const InputDecoration(),

                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    localizations.translate(
                                      'semester_1',
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    localizations.translate(
                                      'semester_2',
                                    ),
                                  ),
                                ),
                              ],

                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() {
                                          _semester = val;
                                        });
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate(
                                'coefficient',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            TextFormField(
                              controller: _coeffController,
                              keyboardType:
                                  TextInputType.number,
                              decoration:
                                  const InputDecoration(
                                hintText: '3',
                              ),
                              validator: (value) {
                                final number =
                                    int.tryParse(value ?? '');

                                if (number == null ||
                                    number <= 0) {
                                  return 'رقم غير صالح';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('credits'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            TextFormField(
                              controller: _creditController,
                              keyboardType:
                                  TextInputType.number,
                              decoration:
                                  const InputDecoration(
                                hintText: '5',
                              ),
                              validator: (value) {
                                final number =
                                    int.tryParse(value ?? '');

                                if (number == null ||
                                    number <= 0) {
                                  return 'رقم غير صالح';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // COLOR SELECTOR

                  const Text(
                    'لون المادة (Accent Color)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children: _colorOptions.map((hex) {
                      final color = Color(
                        int.parse(
                          'FF${hex.replaceAll('#', '')}',
                          radix: 16,
                        ),
                      );

                      final isSelected =
                          _selectedColorHex == hex;

                      return InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedColorHex = hex;
                                });
                              },

                        borderRadius:
                            BorderRadius.circular(20),

                        child: Container(
                          width: 36,
                          height: 36,

                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,

                            border: isSelected
                                ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  )
                                : null,

                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withAlpha(150),
                                      blurRadius: 8,
                                      offset:
                                          const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),

                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // SAVE BUTTON

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _save,

                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),

                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              localizations.translate('save'),
                            ),
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
}
