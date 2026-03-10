enum UserRole { admin, dentista, medico, recepcionista, auxiliar }

enum UserStatus { online, offline }

class Profile {
  final String id;
  final String fullName;
  final UserRole role;
  final UserStatus status;
  final DateTime? lastActive;
  final String clinicId;
  final bool active;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.status,
    this.lastActive,
    required this.clinicId,
    required this.active,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      role: UserRole.values.byName(json['role']),
      status: UserStatus.values.byName(json['status']),
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : null,
      clinicId: json['clinic_id'],
      active: json['active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role.name,
      'status': status.name,
      'last_active': lastActive?.toIso8601String(),
      'clinic_id': clinicId,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    UserRole? role,
    UserStatus? status,
    DateTime? lastActive,
    String? clinicId,
    bool? active,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      clinicId: clinicId ?? this.clinicId,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }
}
