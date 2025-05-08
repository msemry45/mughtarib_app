class HostFamily {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String description;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final Map<String, dynamic>? location;
  final List<String>? amenities;
  final Map<String, dynamic>? availability;
  final DateTime createdAt;
  final DateTime updatedAt;

  HostFamily({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.description,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    this.location,
    this.amenities,
    this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HostFamily.fromJson(Map<String, dynamic> json) {
    return HostFamily(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      location: json['location'],
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
      availability: json['availability'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'description': description,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'location': location,
      'amenities': amenities,
      'availability': availability,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
