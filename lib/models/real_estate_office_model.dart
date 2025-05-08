class RealEstateOffice {
  final int officeID;
  final String officeName;
  final String location;
  final String phoneNumber;
  final String email;

  RealEstateOffice({
    required this.officeID,
    required this.officeName,
    required this.location,
    required this.phoneNumber,
    required this.email,
  });

  factory RealEstateOffice.fromJson(Map<String, dynamic> json) {
    return RealEstateOffice(
      officeID: json['officeID'],
      officeName: json['officeName'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'officeID': officeID,
      'officeName': officeName,
      'location': location,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
