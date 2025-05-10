import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// تسجيل دخول المكتب العقاري
  Future<Map<String, dynamic>> loginRealEstateOffice({
    required String email,
    required String password,
  }) async {
    try {
      // 1. تسجيل الدخول باستخدام Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. جلب بيانات المكتب من Firestore
      final officeDoc = await _firestore
          .collection('realEstateOffices')
          .doc(userCredential.user?.uid)
          .get();

      if (!officeDoc.exists) {
        return {
          'success': false,
          'message': 'لا يوجد بيانات لهذا المكتب العقاري'
        };
      }

      final officeData = officeDoc.data()!;

      // 3. التحقق من تطابق كلمة المرور
      if (officeData['password'] != password) {
        await _auth.signOut(); // تسجيل الخروج إذا كانت كلمة المرور غير متطابقة
        return {
          'success': false,
          'message': 'كلمة المرور غير صحيحة'
        };
      }

      return {
        'success': true,
        'officeData': officeData,
        'userId': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') message = 'البريد الإلكتروني غير مسجل';
      if (e.code == 'wrong-password') message = 'كلمة المرور غير صحيحة';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل مكتب عقاري جديد
  Future<Map<String, dynamic>> registerRealEstateOffice({
    required String email,
    required String password,
    required String officeName,
    required String location,
    required String phoneNumber,
    required int officeID,
  }) async {
    try {
      // 1. إنشاء حساب في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. إنشاء مستند في Firestore
      await _firestore
          .collection('realEstateOffices')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'password': password, // Note: Consider hashing in production
        'officeName': officeName,
        'location': location,
        'phoneNumber': phoneNumber,
        'officeID': officeID,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'userId': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'فشل إنشاء الحساب';
      if (e.code == 'email-already-in-use') message = 'البريد الإلكتروني مستخدم مسبقاً';
      if (e.code == 'weak-password') message = 'كلمة المرور ضعيفة';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل الدخول باستخدام Google
  Future<Map<String, dynamic>> loginWithGoogle({
    required String userType, // 'student', 'hostFamily', or 'realEstateOffice'
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'تم إلغاء تسجيل الدخول'};
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // تحديد المجموعة بناءً على نوع المستخدم
      final collection = userType == 'student'
          ? 'students'
          : userType == 'hostFamily'
              ? 'hostFamilies'
              : 'realEstateOffices';

      // التحقق من وجود المستخدم في Firestore
      final userDoc = await _firestore
          .collection(collection)
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        // إنشاء مستند جديد إذا لم يكن موجوداً
        await _firestore
            .collection(collection)
            .doc(userCredential.user?.uid)
            .set({
          'email': userCredential.user?.email,
          'name': googleUser.displayName ?? '',
          'role': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'userId': userCredential.user?.uid,
      };
    } catch (e) {
      return {'success': false, 'message': 'فشل تسجيل الدخول عبر Google'};
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// جلب بيانات المكتب الحالي
  Future<Map<String, dynamic>?> getCurrentOffice() async {
    if (_auth.currentUser == null) return null;
    
    final doc = await _firestore
        .collection('realEstateOffices')
        .doc(_auth.currentUser!.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({Key? key}) : super(key: key);

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
      final response = await _authService.loginRealEstateOffice(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response['success']) {
        Navigator.pushReplacementNamed(context, '/agencyHome');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'فشل تسجيل الدخول';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل دخول مكتب عقاري'),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
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
                  Icon(Icons.business, size: 80, color: colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'مرحباً بك في تسجيل دخول المكاتب العقارية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/agencyRegister');
                    },
                    child: Text(
                      'ليس لديك حساب؟ سجل مكتب جديد',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
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