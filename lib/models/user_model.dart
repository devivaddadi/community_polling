enum UserRole { admin, member }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String avatarUrl;
  final UserRole role;
  final String communityId;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.avatarUrl,
    required this.role,
    required this.communityId,
    required this.joinedAt,
  });

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'communityId': communityId,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? 'https://i.pravatar.cc/150',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.member,
      communityId: json['communityId'] as String? ?? 'c1',
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? communityId,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      communityId: communityId ?? this.communityId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
