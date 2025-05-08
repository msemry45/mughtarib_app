import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/theme.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final response = await authService.loginRealEstateOffice(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response['success']) {
        Navigator.pushReplacementNamed(context, '/agencyHome');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'فشل تسجيل الدخول')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.loginWithGoogle(userType: 'realEstateOffice');

      if (result['success']) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/agencyHome');
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
      } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع';
      });
      } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                    'تسجيل دخول المكتب العقاري',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 32),
                  CustomTextField(
                      controller: _emailController,
                    label: 'البريد الإلكتروني',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _passwordController,
                    label: 'كلمة المرور',
                    isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('تسجيل الدخول'),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    child: _isGoogleLoading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/google_logo.png',
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text('تسجيل الدخول باستخدام Google'),
                            ],
                            ),
                    ),
                  const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                      Navigator.pushNamed(context, '/agencyRegister');
                      },
                      child: Text(
                        'ليس لديك حساب؟ سجل الآن',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
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