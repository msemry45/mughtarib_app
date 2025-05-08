class UniversityClinic {
  final int clinicID;
  final String clinicName;
  final String location;
  final String phoneNumber;

  UniversityClinic({
    required this.clinicID,
    required this.clinicName,
    required this.location,
    required this.phoneNumber,
  });

  factory UniversityClinic.fromJson(Map<String, dynamic> json) => UniversityClinic(
    clinicID: int.parse(json['clinicID'].toString()),
    clinicName: json['clinicName'],
    location: json['location'],
    phoneNumber: json['phoneNumber'],
  );

  Map<String, dynamic> toJson() => {
    'clinicID': clinicID,
    'clinicName': clinicName,
    'location': location,
    'phoneNumber': phoneNumber,
  };
}
