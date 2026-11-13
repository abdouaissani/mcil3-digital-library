import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String code;
  final String nameAr;
  final String nameFr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionFr;
  final String descriptionEn;
  final int semester;
  final int coefficient;
  final int credit;
  final String colorHex;
  final String iconName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int documentsCount;

  SubjectModel({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
    this.descriptionAr = '',
    this.descriptionFr = '',
    this.descriptionEn = '',
    this.semester = 5,
    this.coefficient = 1,
    this.credit = 1,
    this.colorHex = '#2563EB',
    this.iconName = 'book',
    required this.createdAt,
    this.updatedAt,
    this.documentsCount = 0,
  });

  String getName(Locale locale) {
    if (locale.languageCode == 'ar') return nameAr.isNotEmpty ? nameAr : nameFr;
    if (locale.languageCode == 'fr') return nameFr.isNotEmpty ? nameFr : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameFr;
  }

  String getDescription(Locale locale) {
    if (locale.languageCode == 'ar') return descriptionAr.isNotEmpty ? descriptionAr : descriptionFr;
    if (locale.languageCode == 'fr') return descriptionFr.isNotEmpty ? descriptionFr : descriptionEn;
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionFr;
  }

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2563EB);
    }
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameFr: json['name_fr'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionFr: json['description_fr'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      semester: (json['semester'] as num?)?.toInt() ?? 5,
      coefficient: (json['coefficient'] as num?)?.toInt() ?? 1,
      credit: (json['credit'] as num?)?.toInt() ?? 1,
      colorHex: json['color_hex'] as String? ?? '#2563EB',
      iconName: json['icon_name'] as String? ?? 'book',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      documentsCount: (json['documents_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name_ar': nameAr,
      'name_fr': nameFr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'description_en': descriptionEn,
      'semester': semester,
      'coefficient': coefficient,
      'credit': credit,
      'color_hex': colorHex,
      'icon_name': iconName,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? code,
    String? nameAr,
    String? nameFr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionFr,
    String? descriptionEn,
    int? semester,
    int? coefficient,
    int? credit,
    String? colorHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? documentsCount,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameFr: nameFr ?? this.nameFr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      semester: semester ?? this.semester,
      coefficient: coefficient ?? this.coefficient,
      credit: credit ?? this.credit,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentsCount: documentsCount ?? this.documentsCount,
    );
  }
}
