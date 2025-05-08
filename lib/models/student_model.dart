import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String userID;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String password;
  final String role;

  Student({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    required this.password,
    this.role = 'student',
  });

  // Convert Firestore document to Student object
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      userID: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
      password: data['password'] ?? '',
      role: data['role'] ?? 'student',
    );
  }

  // Convert JSON to Student object
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userID: json['userID'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      password: json['password'] ?? '',
      role: json['role'] ?? 'student',
    );
  }

  // Convert Student object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  // Convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'role': role,
    };
  }
} 