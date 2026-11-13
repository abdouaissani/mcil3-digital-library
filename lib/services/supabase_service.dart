
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../models/subject_model.dart';
import '../models/document_model.dart';

class SupabaseService extends ChangeNotifier {
  static final SupabaseService _instance =
      SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  bool _isInitialized = false;
  bool _isConfigured = false;
  bool _isAdmin = false;
  bool _isConnecting = false;

  String? _currentUserEmail;
  String? _connectionError;

  bool get isInitialized => _isInitialized;
  bool get isConfigured => _isConfigured;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _currentUserEmail != null;
  bool get isConnecting => _isConnecting;

  String? get currentUserEmail => _currentUserEmail;
  String? get connectionError => _connectionError;

  SupabaseClient get client => Supabase.instance.client;

  // INITIALIZATION

  Future<void> initialize() async {
    if (_isInitialized || _isConnecting) return;

    _isConnecting = true;
    _connectionError = null;
    notifyListeners();

    try {
      final url = AppConstants.supabaseUrl.trim();
      final key = AppConstants.supabaseAnonKey.trim();

      if (url.isEmpty ||
          key.isEmpty ||
          url.contains('YOUR_SUPABASE') ||
          key.contains('YOUR_SUPABASE')) {
        throw Exception(
          'Supabase URL أو API Key غير مضبوط',
        );
      }

      Uri parsedUrl;

      try {
        parsedUrl = Uri.parse(url);
      } catch (_) {
        throw Exception('Supabase URL غير صالح');
      }

      if (parsedUrl.scheme != 'https' ||
          parsedUrl.host.isEmpty) {
        throw Exception(
          'يجب استخدام رابط HTTPS صالح لمشروع Supabase',
        );
      }

      await Supabase.initialize(
        url: url,
        publishableKey: key,
      );

      _isConfigured = true;
      _connectionError = null;

      _updateSession(client.auth.currentSession);

      client.auth.onAuthStateChange.listen(
        (data) {
          _updateSession(data.session);
        },
        onError: (error) {
          debugPrint('Auth state error: $error');
        },
      );

      debugPrint('Supabase initialized successfully');

    } on SocketException catch (e) {
      _isConfigured = false;
      _connectionError =
          'تعذر الاتصال بالخادم. تحقق من الإنترنت وDNS.';

      debugPrint('Supabase SocketException: $e');

    } on AuthRetryableFetchException catch (e) {
      _isConfigured = false;
      _connectionError =
          'تعذر الوصول إلى خادم المصادقة. تحقق من الاتصال.';

      debugPrint('Supabase Auth connection error: $e');

    } catch (e, stackTrace) {
      _isConfigured = false;
      _connectionError = e.toString();

      debugPrint('Supabase initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

    } finally {
      _isInitialized = true;
      _isConnecting = false;
      notifyListeners();
    }
  }

  // SESSION

  void _updateSession(Session? session) {
    final user = session?.user;

    _currentUserEmail = user?.email;
    _isAdmin = user?.appMetadata['role'] == 'admin';

    notifyListeners();
  }

  // RETRY CONNECTION

  Future<bool> retryConnection() async {
    if (_isConnecting) return false;

    if (_isConfigured) return true;

    _isInitialized = false;
    _isConfigured = false;
    _connectionError = null;

    await initialize();

    return _isConfigured;
  }

  // AUTHENTICATION

  Future<bool> signInAdmin(
    String email,
    String password,
  ) async {
    _checkConfiguration();

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return false;
      }

      final role = user.appMetadata['role'];

      if (role != 'admin') {
        await client.auth.signOut();
        _updateSession(null);

        throw Exception(
          'هذا الحساب لا يملك صلاحيات الإدارة',
        );
      }

      _updateSession(response.session);

      return true;

    } on AuthRetryableFetchException catch (e) {
      _connectionError = 'تعذر الاتصال بخادم تسجيل الدخول';
      notifyListeners();

      debugPrint('Authentication connection error: $e');
      rethrow;

    } on AuthException catch (e) {
      debugPrint('Authentication error: ${e.message}');
      rethrow;

    } catch (e) {
      debugPrint('Admin login error: $e');
      rethrow;
    }
  }

  Future<void> signOutAdmin() async {
    if (!_isConfigured) return;

    try {
      await client.auth.signOut();
      _updateSession(null);
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // SUBJECTS

  Future<List<SubjectModel>> getSubjects({
    int? semester,
  }) async {
    if (!_isConfigured) return [];

    try {
      var query = client
          .from('subjects')
          .select('*, documents(count)');

      if (semester != null) {
        query = query.eq('semester', semester);
      }

      final data = await query.order(
        'code',
        ascending: true,
      );

      return (data as List).map((item) {
        final mutable = Map<String, dynamic>.from(item);

        int docCount = 0;
        final documents = mutable['documents'];

        if (documents is List && documents.isNotEmpty) {
          docCount = documents[0]['count'] ?? 0;
        }

        mutable['documents_count'] = docCount;

        return SubjectModel.fromJson(mutable);
      }).toList();

    } catch (e) {
      debugPrint('Get subjects error: $e');
      return [];
    }
  }

  Future<SubjectModel?> getSubjectById(String id) async {
    if (!_isConfigured) return null;

    try {
      final data = await client
          .from('subjects')
          .select()
          .eq('id', id)
          .single();

      return SubjectModel.fromJson(data);

    } catch (e) {
      debugPrint('Get subject error: $e');
      return null;
    }
  }

  Future<bool> saveSubject(SubjectModel subject) async {
    _requireAdmin();

    if (subject.id.isEmpty || subject.id.startsWith('sub-')) {
      await client.from('subjects').insert(subject.toJson());
    } else {
      await client
          .from('subjects')
          .update(subject.toJson())
          .eq('id', subject.id);
    }

    notifyListeners();
    return true;
  }

  Future<bool> deleteSubject(String id) async {
    _requireAdmin();

    await client.from('subjects').delete().eq('id', id);

    notifyListeners();
    return true;
  }

  // DOCUMENTS

  Future<List<DocumentModel>> getDocuments({
    String? subjectId,
    String? docType,
    bool onlyPublished = true,
  }) async {
    if (!_isConfigured) return [];

    try {
      var query = client
          .from('documents')
          .select('*, subjects(name_fr, name_ar)');

      if (subjectId != null) {
        query = query.eq('subject_id', subjectId);
      }

      if (docType != null &&
          docType.toLowerCase() != 'all') {
        query = query.eq(
          'doc_type',
          docType.toLowerCase(),
        );
      }

      if (onlyPublished && !_isAdmin) {
        query = query.eq('is_published', true);
      }

      final data = await query.order(
        'created_at',
        ascending: false,
      );

      return (data as List)
          .map((json) => DocumentModel.fromJson(json))
          .toList();

    } catch (e) {
      debugPrint('Get documents error: $e');
      return [];
    }
  }

  Future<List<DocumentModel>> searchDocuments(
    String query,
  ) async {
    if (!_isConfigured || query.trim().isEmpty) {
      return [];
    }

    try {
      final search = query.trim();

      final data = await client
          .from('documents')
          .select('*, subjects(name_fr, name_ar)')
          .or(
            'title.ilike.%$search%,'
            'chapter_or_series.ilike.%$search%',
          )
          .eq('is_published', true)
          .limit(30);

      return (data as List)
          .map((json) => DocumentModel.fromJson(json))
          .toList();

    } catch (e) {
      debugPrint('Search documents error: $e');
      return [];
    }
  }

  Future<List<DocumentModel>> getRecentDocuments({
    int limit = 5,
  }) async {
    if (!_isConfigured) return [];

    try {
      final data = await client
          .from('documents')
          .select('*, subjects(name_fr, name_ar)')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((json) => DocumentModel.fromJson(json))
          .toList();

    } catch (e) {
      debugPrint('Recent documents error: $e');
      return [];
    }
  }

  Future<bool> saveDocument(
    DocumentModel document,
  ) async {
    _requireAdmin();

    if (document.id.isEmpty ||
        document.id.startsWith('doc-')) {
      await client
          .from('documents')
          .insert(document.toJson());
    } else {
      await client
          .from('documents')
          .update(document.toJson())
          .eq('id', document.id);
    }

    notifyListeners();
    return true;
  }

  Future<bool> deleteDocument(
    String id,
    String? filePath,
  ) async {
    _requireAdmin();

    await client
        .from('documents')
        .delete()
        .eq('id', id);

    if (filePath != null && filePath.isNotEmpty) {
      try {
        await client.storage
            .from(AppConstants.documentsBucket)
            .remove([filePath]);
      } catch (e) {
        debugPrint('Storage deletion error: $e');
      }
    }

    notifyListeners();
    return true;
  }

  // STORAGE

  Future<String?> uploadStorageFile({
    required Uint8List bytes,
    required String path,
    required String fileName,
  }) async {
    _requireAdmin();

    final fullPath = '$path/$fileName';

    await client.storage
        .from(AppConstants.documentsBucket)
        .uploadBinary(
          fullPath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return client.storage
        .from(AppConstants.documentsBucket)
        .getPublicUrl(fullPath);
  }

  // COUNTERS

  Future<void> incrementDownloads(String docId) async {
    if (!_isConfigured) return;

    try {
      await client.rpc(
        'increment_download_count',
        params: {'doc_id': docId},
      );
    } catch (e) {
      debugPrint('Download counter error: $e');
    }
  }

  Future<void> incrementViews(String docId) async {
    if (!_isConfigured) return;

    try {
      await client.rpc(
        'increment_view_count',
        params: {'doc_id': docId},
      );
    } catch (e) {
      debugPrint('View counter error: $e');
    }
  }

  // HELPERS

  void _checkConfiguration() {
    if (!_isConfigured) {
      throw Exception(
        _connectionError ?? 'Supabase غير متصل',
      );
    }
  }

  void _requireAdmin() {
    _checkConfiguration();

    if (!_isAdmin || client.auth.currentUser == null) {
      throw Exception(
        'غير مصرح لك بتنفيذ هذه العملية',
      );
    }
  }
}
