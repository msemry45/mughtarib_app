class Review {
  final String id;
  final String userId;
  final String userType; // student, host_family, real_estate_office
  final String targetId; // property_id, host_family_id, real_estate_office_id
  final String targetType; // property, host_family, real_estate_office
  final double rating;
  final String comment;
  final List<String>? images;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.userType,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    this.images,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      targetId: json['targetId'] ?? '',
      targetType: json['targetType'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userType': userType,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'images': images,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
