class User {
  final int userID;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String? email;
  final String? profilePicture;
  final List<String>? addresses;
  final Map<String, dynamic>? preferences;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  User({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    this.email,
    this.profilePicture,
    this.addresses,
    this.preferences,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      email: json['email'] as String?,
      profilePicture: json['profilePicture'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)?.cast<String>(),
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'email': email,
      'profilePicture': profilePicture,
      'addresses': addresses,
      'preferences': preferences,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({
    int? userID,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
    String? email,
    String? profilePicture,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return User(
      userID: userID ?? this.userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      addresses: addresses ?? this.addresses,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
} 