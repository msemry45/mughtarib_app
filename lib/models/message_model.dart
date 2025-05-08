class Message {
  final String id;
  final String senderId;
  final String senderType; // student, host_family, real_estate_office
  final String receiverId;
  final String receiverType; // student, host_family, real_estate_office
  final String content;
  final String? attachmentUrl;
  final String? attachmentType; // image, document, etc.
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverType: json['receiverType'] ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
