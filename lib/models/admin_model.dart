class Admin {
  final int adminID;
  final String adminName;
  final String email;
  final String phoneNumber;

  Admin({
    required this.adminID,
    required this.adminName,
    required this.email,
    required this.phoneNumber,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    adminID: int.parse(json['adminID'].toString()),
    adminName: json['adminName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
  );

  Map<String, dynamic> toJson() => {
    'adminID': adminID,
    'adminName': adminName,
    'email': email,
    'phoneNumber': phoneNumber,
  };
} 