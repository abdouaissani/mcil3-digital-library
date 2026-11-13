import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String studentHome = '/student/home';
  static const String subjects = '/student/subjects';
  static const String subjectDetails = '/student/subject-details';
  static const String pdfViewer = '/student/pdf-viewer';
  static const String downloads = '/student/downloads';
  static const String search = '/student/search';
  static const String settings = '/settings';
  
  // Admin Routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String addEditSubject = '/admin/add-edit-subject';
  static const String uploadPdf = '/admin/upload-pdf';
  static const String manageDocuments = '/admin/manage-documents';

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void replaceWith(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }
}
