import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({Key? key}) : super(key: key);

  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  // Cache commonly used styles
  final _titleStyle = GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final _inputDecoration = InputDecoration(
    labelStyle: GoogleFonts.cairo(color: Colors.white70),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  void initState() {
    super.initState();
    // Preload Google Fonts
    GoogleFonts.pendingFonts([
      GoogleFonts.cairo(),
    ]);
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final response = await authService.loginStudent(
        email: _studentIdController.text,
        password: _passwordController.text,
      );
      if (response['success']) {
        Navigator.pushReplacementNamed(context, '/home');
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onBackground;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'تسجيل دخول الطلاب',
          style: GoogleFonts.cairo(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
              ),
            ),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
          ),
      body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                SizedBox(height: 32),
                Center(
                  child: Image.asset(
                    'images/mughtarib_logo.png',
                    height: 100,
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'مرحباً بالطالب!',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                    Text(
                  'يرجى تسجيل الدخول للمتابعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                      textAlign: TextAlign.center,
                    ),
                SizedBox(height: 32),
                    TextFormField(
                      controller: _studentIdController,
                  decoration: InputDecoration(
                        labelText: 'الرقم الجامعي',
                    prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                      ),
                  style: TextStyle(color: textColor),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الرقم الجامعي';
                        }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'الرقم الجامعي يجب أن يحتوي على أرقام فقط';
                        }
                        return null;
                      },
                    ),
                SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                  style: TextStyle(color: textColor),
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
                SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                            )
                          : Text(
                              'تسجيل الدخول',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                              ),
                            ),
                    ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: GoogleFonts.cairo(
                        color: colorScheme.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'سجل الآن',
                        style: GoogleFonts.cairo(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 