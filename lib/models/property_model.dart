class Property {
  final String id;
  final String title;
  final String description;
  final String type; // apartment, house, villa, etc.
  final String status; // available, rented, etc.
  final double price;
  final String currency;
  final String address;
  final String city;
  final Map<String, dynamic>? location;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String areaUnit; // m², ft², etc.
  final List<String> amenities;
  final String ownerId;
  final String ownerType; // host_family, real_estate_office
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final Map<String, dynamic>? availability;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.currency,
    required this.address,
    required this.city,
    this.location,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.areaUnit,
    required this.amenities,
    required this.ownerId,
    required this.ownerType,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
      currency: json['currency'] ?? 'SAR',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      location: json['location'],
      images: List<String>.from(json['images'] ?? []),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['area'] ?? 0.0).toDouble(),
      areaUnit: json['areaUnit'] ?? 'm²',
      amenities: List<String>.from(json['amenities'] ?? []),
      ownerId: json['ownerId'] ?? '',
      ownerType: json['ownerType'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      availability: json['availability'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'price': price,
      'currency': currency,
      'address': address,
      'city': city,
      'location': location,
      'images': images,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'areaUnit': areaUnit,
      'amenities': amenities,
      'ownerId': ownerId,
      'ownerType': ownerType,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'availability': availability,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
