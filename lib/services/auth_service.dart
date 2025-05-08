import 'dart:convert';
import '../services/api_service.dart';
import '../models/student_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Student? _currentUser;
  String? _sessionToken;
  DateTime? _tokenExpiry;

  // Initialize the service
  Future<void> init() async {
    try {
      await _apiService.init();
      await _loadSession();
      
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user == null) {
          _currentUser = null;
          _sessionToken = null;
          _tokenExpiry = null;
        }
      });
    } catch (e) {
      print('Error initializing AuthService: $e');
      rethrow;
    }
  }

  // Get current user
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  Student? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;

  // Load session from storage
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session_token');
      final userJson = prefs.getString('current_user');
      final expiry = prefs.getString('token_expiry');

      if (token != null && userJson != null && expiry != null) {
        _sessionToken = token;
        _currentUser = Student.fromJson(jsonDecode(userJson));
        _tokenExpiry = DateTime.parse(expiry);

        if (_isTokenExpired()) {
          await logout();
        } else {
          await _refreshToken();
        }
      }
    } catch (e) {
      print('Error loading session: $e');
      await logout();
    }
  }

  // Save session to storage
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sessionToken != null && _currentUser != null && _tokenExpiry != null) {
        await prefs.setString('session_token', _sessionToken!);
        await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Check if token is expired
  bool _isTokenExpired() {
    return _tokenExpiry == null || _tokenExpiry!.isBefore(DateTime.now());
  }

  // Refresh token
  Future<void> _refreshToken() async {
    try {
      final response = await _apiService.post('Auth/refresh', {
        'token': _sessionToken,
      });
      _sessionToken = response['token'];
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
      await _saveSession();
    } catch (e) {
      print('Error refreshing token: $e');
      await logout();
    }
  }

  /// تسجيل دخول الطالب باستخدام البريد الإلكتروني وكلمة المرور
  Future<Map<String, dynamic>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore.collection('students').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'لا يوجد بيانات لهذا المستخدم'};
      }
      final data = doc.data()!;
      return {
        'success': true,
        'user': userCredential.user,
        'studentData': data,
        'role': data['role'] ?? 'student',
      };
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') msg = 'المستخدم غير موجود';
      if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل طالب جديد
  Future<Map<String, dynamic>> registerStudent({
    required String email,
    required String password,
    required String userID,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('students').doc(userCredential.user!.uid).set({
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل إنشاء الحساب';
      if (e.code == 'email-already-in-use') msg = 'البريد الإلكتروني مستخدم مسبقاً';
      if (e.code == 'weak-password') msg = 'كلمة المرور ضعيفة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// جلب بيانات الطالب الحالي
  Future<Map<String, dynamic>?> getCurrentStudentData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('students').doc(user.uid).get();
    return doc.data();
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// التحقق من الدور وتوجيه المستخدم
  void navigateByRole(BuildContext context, String role) {
    if (role == 'Admin') {
      Navigator.pushReplacementNamed(context, '/adminHome');
    } else {
      Navigator.pushReplacementNamed(context, '/studentHome');
    }
  }

  // Login with university ID and password
  Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionToken = data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        _currentUser = await getUserProfile();
        await _saveSession();
        return {'success': true, 'message': 'تم تسجيل الدخول بنجاح'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'فشل تسجيل الدخول'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء تسجيل الدخول'};
    }
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionToken = data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        _currentUser = await getUserProfile();
        await _saveSession();
        return {'success': true, 'message': 'تم التسجيل بنجاح'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'فشل التسجيل'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء التسجيل'};
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _apiService.post('Auth/reset-password', {
        'email': email,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // Get user profile
  Future<Student> getUserProfile() async {
    try {
      final response = await _apiService.get('Students/${_apiService.userId}');
      _currentUser = Student.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update user profile
  Future<Student> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? profilePicture,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (profilePicture != null) data['profilePicture'] = profilePicture;
      if (addresses != null) data['addresses'] = addresses;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _apiService.put('Students/${_apiService.userId}', data);
      _currentUser = Student.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _currentUser = null;
      _sessionToken = null;
      _tokenExpiry = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
      await prefs.remove('current_user');
      await prefs.remove('token_expiry');
      await _apiService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Continue with logout even if there's an error
      _currentUser = null;
      _sessionToken = null;
      _tokenExpiry = null;
    }
  }

  /// تسجيل دخول الطالب بالرقم الجامعي وكلمة المرور (من Firestore فقط)
  Future<Map<String, dynamic>> loginStudentByUserID({
    required String userID,
    required String password,
  }) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('userID', isEqualTo: userID)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {'success': false, 'message': 'الرقم الجامعي غير موجود'};
      }

      final data = query.docs.first.data();
      if (data['password'] != password) {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }

      return {
        'success': true,
        'studentData': data,
        'role': data['role'] ?? 'student',
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء تسجيل الدخول'};
    }
  }

  /// تسجيل دخول بالبريد الإلكتروني وكلمة المرور (للأسر المضيفة أو المكاتب العقارية)
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
    required String userType, // 'hostFamily' or 'realEstateOffice'
  }) async {
    try {
      print('Attempting to sign in with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase Auth successful for user: ${userCredential.user?.uid}');
      
      final collection = userType == 'hostFamily' ? 'hostFamilies' : 'realEstateOffices';
      final doc = await _firestore.collection(collection).doc(userCredential.user!.uid).get();
      
      if (!doc.exists) {
        print('No user data found in Firestore for: ${userCredential.user?.uid}');
        return {'success': false, 'message': 'لا يوجد بيانات لهذا المستخدم'};
      }
      
      final data = doc.data()!;
      print('User data retrieved successfully: ${data.toString()}');
      
      return {
        'success': true,
        'user': userCredential.user,
        'userData': data,
        'role': data['role'] ?? userType,
      };
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String msg = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') msg = 'المستخدم غير موجود';
      if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
      if (e.code == 'invalid-email') msg = 'البريد الإلكتروني غير صحيح';
      if (e.code == 'user-disabled') msg = 'تم تعطيل هذا الحساب';
      return {'success': false, 'message': msg};
    } catch (e) {
      print('Unexpected error during login: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل دخول عبر Google لأي نوع مستخدم
  Future<Map<String, dynamic>> loginWithGoogle({
    required String userType, // 'student' أو 'hostFamily' أو 'realEstateOffice'
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'تم إلغاء تسجيل الدخول عبر Google'};
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      String collection = userType == 'student'
          ? 'students'
          : userType == 'hostFamily'
              ? 'hostFamilies'
              : 'realEstateOffices';
      final docRef = _firestore.collection(collection).doc(userCredential.user!.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? '',
          'role': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final userData = (await docRef.get()).data()!;
      return {
        'success': true,
        'user': userCredential.user,
        'userData': userData,
        'role': userType,
      };
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ أثناء تسجيل الدخول عبر Google'};
    }
  }

  /// تسجيل أسرة مضيفة جديدة
  Future<Map<String, dynamic>> registerHostFamily({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String city,
    required String description,
    required List<String> amenities,
    required int maxGuests,
    required double pricePerNight,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('hostFamilies').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'description': description,
        'amenities': amenities,
        'maxGuests': maxGuests,
        'pricePerNight': pricePerNight,
        'role': 'hostFamily',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل إنشاء الحساب';
      if (e.code == 'email-already-in-use') msg = 'البريد الإلكتروني مستخدم مسبقاً';
      if (e.code == 'weak-password') msg = 'كلمة المرور ضعيفة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل دخول أسرة مضيفة
  Future<Map<String, dynamic>> loginHostFamily({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore.collection('hostFamilies').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'لا يوجد بيانات لهذه الأسرة المضيفة'};
      }
      final data = doc.data()!;
      return {
        'success': true,
        'user': userCredential.user,
        'hostFamilyData': data,
        'role': 'hostFamily',
      };
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') msg = 'المستخدم غير موجود';
      if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل مكتب عقاري جديد
  Future<Map<String, dynamic>> registerRealEstateOffice({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String city,
    required String licenseNumber,
    required String description,
    required List<String> services,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('realEstateOffices').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'licenseNumber': licenseNumber,
        'description': description,
        'services': services,
        'role': 'realEstateOffice',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل إنشاء الحساب';
      if (e.code == 'email-already-in-use') msg = 'البريد الإلكتروني مستخدم مسبقاً';
      if (e.code == 'weak-password') msg = 'كلمة المرور ضعيفة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل مكتب عقاري
  Future<Map<String, dynamic>> loginRealEstateOffice({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore.collection('realEstateOffices').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'لا يوجد بيانات لهذا المكتب العقاري'};
      }
      final data = doc.data()!;
      return {
        'success': true,
        'user': userCredential.user,
        'officeData': data,
        'role': 'realEstateOffice',
      };
    } on FirebaseAuthException catch (e) {
      String msg = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') msg = 'المستخدم غير موجود';
      if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
      return {'success': false, 'message': msg};
    } catch (_) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }
}
