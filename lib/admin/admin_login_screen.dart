
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../core/app_routes.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ADMIN LOGIN
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = context.read<SupabaseService>();

      if (!service.isConfigured) {
        throw Exception(
          'يرجى التأكد من إعداد Supabase في constants.dart',
        );
      }

      final success = await service.signInAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success && service.isAdmin) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.adminDashboard,
        );
      } else {
        setState(() {
          _errorMessage =
              'تعذر تسجيل الدخول. تحقق من بيانات الحساب وصلاحيات الإدارة.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      final error = e.toString();

      String message;

      if (error.contains('Invalid login credentials')) {
        message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (error.contains('Email not confirmed')) {
        message = 'يجب تأكيد البريد الإلكتروني أولاً';
      } else if (error.contains('Database error querying schema')) {
        message = 'يوجد خلل في إعدادات المصادقة بقاعدة البيانات';
      } else if (error.contains('لا يملك صلاحيات الإدارة')) {
        message = 'هذا الحساب ليس لديه صلاحيات الأدمن';
      } else if (error.contains('Supabase غير مهيأ')) {
        message = 'لم يتم إعداد الاتصال بقاعدة البيانات';
      } else {
        message = error.replaceFirst('Exception: ', '');
      }

      setState(() {
        _errorMessage = message;
      });

      debugPrint('Admin login screen error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // BACK TO STUDENT
  void _backToStudent() {
    if (_isLoading) return;

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.studentHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('admin_login'),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // HEADER ICON
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                          ],
                        ),
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TITLE
                  Text(
                    localizations.translate('admin_space'),

                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),

                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    localizations.translate('admin_login_sub'),

                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),

                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // ERROR MESSAGE
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: AppColors.error.withAlpha(120),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 22,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              _errorMessage!,

                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // EMAIL LABEL
                  Text(
                    localizations.translate('email'),

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // EMAIL INPUT
                  TextFormField(
                    controller: _emailController,

                    keyboardType: TextInputType.emailAddress,

                    textInputAction: TextInputAction.next,

                    autocorrect: false,

                    enabled: !_isLoading,

                    decoration: InputDecoration(
                      hintText: 'admin@example.com',

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }

                      return null;
                    },

                    onFieldSubmitted: (_) {
                      FocusScope.of(context).nextFocus();
                    },
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD LABEL
                  Text(
                    localizations.translate('password'),

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PASSWORD INPUT
                  TextFormField(
                    controller: _passwordController,

                    obscureText: _obscurePassword,

                    textInputAction: TextInputAction.done,

                    enabled: !_isLoading,

                    decoration: InputDecoration(
                      hintText: '••••••••',

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },

                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }

                      return null;
                    },

                    onFieldSubmitted: (_) {
                      _handleLogin();
                    },
                  ),

                  const SizedBox(height: 28),

                  // LOGIN BUTTON
                  SizedBox(
                    height: 54,

                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _handleLogin,

                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: _isLoading
                          ? const SizedBox(
                              width: 23,
                              height: 23,

                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [
                                const Icon(
                                  Icons.login_rounded,
                                  size: 20,
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  localizations.translate(
                                    'login_button',
                                  ),

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // STUDENT BUTTON
                  OutlinedButton(
                    onPressed:
                        _isLoading ? null : _backToStudent,

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      localizations.translate(
                        'enter_as_student',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FOOTER
                  Text(
                    'MCIL3 DIGITAL LIBRARY',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,

                      fontSize: 11,

                      letterSpacing: 1.5,

                      fontWeight: FontWeight.w600,
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
