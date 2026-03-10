
class Message {
  final String id;
  final String clinicId;
  final String senderId;
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final String? senderName;
  final String? senderRole;

  Message({
    required this.id,
    required this.clinicId,
    required this.senderId,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    this.senderName,
    this.senderRole,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      // These might come from a join in the query
      senderName: json['profiles']?['full_name'] as String?,
      senderRole: json['profiles']?['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? clinicId,
    String? senderId,
    String? content,
    String? mediaUrl,
    DateTime? createdAt,
    String? senderName,
    String? senderRole,
  }) {
    return Message(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
    );
  }
}
