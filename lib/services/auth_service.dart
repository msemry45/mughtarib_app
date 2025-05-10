import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/student_model.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login student with university ID and password (Firestore only)
  Future<Map<String, dynamic>> loginStudent({
    required String identifier, // يمكن أن يكون رقم جامعي أو إيميل
    required String password,
  }) async {
    try {
      QuerySnapshot query;
      // إذا كان identifier يحتوي على @ اعتبره إيميل
      if (identifier.contains('@')) {
        query = await _firestore.collection('students')
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      } else {
        query = await _firestore.collection('students')
            .where('userId', isEqualTo: int.tryParse(identifier) ?? identifier)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        return {'success': false, 'message': 'المستخدم غير مسجل'};
      }

      final doc = query.docs.first;
      final student = Student.fromFirestore(doc);

      // تحقق من كلمة المرور
      if (student.password != password) {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }

      // تسجيل الدخول في Firebase Auth (إذا كان لديه إيميل)
      if (student.email != null && student.email!.isNotEmpty) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: student.email!,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            await _auth.createUserWithEmailAndPassword(
              email: student.email!,
              password: password,
            );
          } else {
            rethrow;
          }
        }
      }

      return {'success': true, 'student': student};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع: ${e.toString()}'};
    }
  }

  /// Register new student
  Future<Map<String, dynamic>> registerStudent({
    required String userID,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Check if userID already exists
      final idQuery = await _firestore
          .collection('students')
          .where('userID', isEqualTo: userID)
          .limit(1)
          .get();

      if (idQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'الرقم الجامعي مسجل مسبقاً'};
      }

      // Check if email already exists
      final emailQuery = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني مسجل مسبقاً'};
      }

      // Create Firebase auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create student document in Firestore
      await _firestore.collection('students').doc(userCredential.user?.uid).set({
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password, // Note: Consider hashing this
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'userId': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'فشل إنشاء الحساب';
      if (e.code == 'weak-password') message = 'كلمة المرور ضعيفة';
      if (e.code == 'email-already-in-use') message = 'البريد الإلكتروني مستخدم مسبقاً';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع: ${e.toString()}'};
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Get current student data
  Future<Map<String, dynamic>?> getCurrentStudent() async {
    if (_auth.currentUser == null) return null;
    
    final doc = await _firestore
        .collection('students')
        .doc(_auth.currentUser!.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }

  /// Login with Google
  Future<Map<String, dynamic>> loginWithGoogle({required String userType}) async {
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

      // Determine collection based on userType
      final collection = userType == 'student'
          ? 'students'
          : userType == 'hostFamily'
              ? 'hostFamilies'
              : 'realEstateOffices';

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection(collection)
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user record
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

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Navigate based on user role
  void navigateBasedOnRole(BuildContext context, String role) {
    if (role.contains('Admin')) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<Map<String, dynamic>> registerRealEstateOffice({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String address,
    required String city,
    required String licenseNumber,
    required String description,
    required List<String> services,
  }) async {
    try {
      // تحقق إذا كان البريد الإلكتروني مستخدم مسبقاً
      final emailQuery = await _firestore
          .collection('realEstateOffices')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني مستخدم مسبقاً'};
      }

      // إنشاء حساب في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إضافة بيانات المكتب العقاري إلى Firestore
      await _firestore.collection('realEstateOffices').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'licenseNumber': licenseNumber,
        'description': description,
        'services': services,
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
      return {'success': false, 'message': 'حدث خطأ غير متوقع: e.toString()'};
    }
  }

  Future<Map<String, dynamic>> loginHostFamily({
    required String email,
    required String password,
  }) async {
    try {
      // البحث عن الأسرة المضيفة بالبريد الإلكتروني
      final query = await _firestore
          .collection('hostFamilies')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني غير مسجل'};
      }

      final hostDoc = query.docs.first;
      final hostData = hostDoc.data();

      // تحقق من كلمة المرور
      if (hostData['password'] != password) {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }

      // تسجيل الدخول في Firebase Auth
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // إنشاء حساب إذا لم يكن موجوداً
          await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      return {
        'success': true,
        'userData': hostData,
        'userId': hostDoc.id,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'فشل تسجيل الدخول';
      if (e.code == 'wrong-password') message = 'كلمة المرور غير صحيحة';
      if (e.code == 'user-not-found') message = 'المستخدم غير موجود';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> registerHostFamily({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String address,
    required String city,
    required String description,
    required int maxGuests,
    required double pricePerNight,
    required List<String> amenities,
  }) async {
    try {
      // تحقق إذا كان البريد الإلكتروني مستخدم مسبقاً
      final emailQuery = await _firestore
          .collection('hostFamilies')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني مستخدم مسبقاً'};
      }

      // إنشاء حساب في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إضافة بيانات الأسرة المضيفة إلى Firestore
      await _firestore.collection('hostFamilies').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'description': description,
        'maxGuests': maxGuests,
        'pricePerNight': pricePerNight,
        'amenities': amenities,
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
      return {'success': false, 'message': 'حدث خطأ غير متوقع: ${e.toString()}'};
    }
  }
}