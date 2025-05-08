import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import '../models/university_clinic_model.dart';
import '../models/host_family_model.dart';
import '../models/real_estate_office_model.dart';
import '../models/property_model.dart';
import '../models/admin_model.dart';
import '../models/review_model.dart';
import '../models/message_model.dart';
import '../models/student_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Authentication Methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول بواسطة المستخدم');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول باستخدام Google: ${e.toString()}');
    }
  }

  // Firestore Methods
  Future<List<Student>> getStudents() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('students')
          .get();
      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('فشل جلب بيانات الطلاب: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي: ${e.toString()}');
    }
  }

  // Storage Methods
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('فشل رفع الصورة: ${e.toString()}');
    }
  }

  // Messaging Methods
  Future<void> initializeMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null && _auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'fcmToken': token});
      }
    }
  }

  // Analytics Methods
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Real-time Updates
  Stream<QuerySnapshot> getStudentsStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'student')
        .snapshots();
  }

  // Batch Operations
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    WriteBatch batch = _firestore.batch();
    
    for (var update in updates) {
      DocumentReference docRef = _firestore.collection('users').doc(update['id']);
      batch.update(docRef, update['data']);
    }

    await batch.commit();
  }

  // University Clinics
  Future<List<UniversityClinic>> fetchClinics() async {
    try {
      final snapshot = await _firestore.collection('universityClinics').get();
      return snapshot.docs.map((doc) => UniversityClinic.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching clinics: $e');
      return [];
    }
  }

  // Host Families
  Future<List<HostFamily>> fetchHostFamilies() async {
    try {
      final snapshot = await _firestore.collection('hostFamilies').get();
      return snapshot.docs.map((doc) => HostFamily.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching host families: $e');
      return [];
    }
  }

  // Real Estate Offices
  Future<List<RealEstateOffice>> fetchRealEstateOffices() async {
    try {
      final snapshot = await _firestore.collection('realEstateOffices').get();
      return snapshot.docs.map((doc) => RealEstateOffice.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching real estate offices: $e');
      return [];
    }
  }

  // Properties
  Future<List<Property>> fetchProperties() async {
    try {
      final snapshot = await _firestore.collection('properties').get();
      return snapshot.docs.map((doc) => Property.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  // Students
  Future<List<Student>> fetchStudents() async {
    try {
      final snapshot = await _firestore.collection('students').get();
      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  // Admins
  Future<List<Admin>> fetchAdmins() async {
    try {
      final snapshot = await _firestore.collection('admins').get();
      return snapshot.docs.map((doc) => Admin.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  // Reviews
  Future<List<Review>> fetchReviews() async {
    try {
      final snapshot = await _firestore.collection('reviews').get();
      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Messages
  Future<List<Message>> fetchMessages() async {
    try {
      final snapshot = await _firestore.collection('messages').get();
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
} 