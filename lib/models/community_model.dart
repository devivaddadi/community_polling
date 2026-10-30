class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String iconUrl;
  final int memberCount;
  final List<String> adminIds;
  final DateTime createdAt;
  final String category;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.iconUrl,
    required this.memberCount,
    required this.adminIds,
    required this.createdAt,
    this.category = 'Residential',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'iconUrl': iconUrl,
      'memberCount': memberCount,
      'adminIds': adminIds,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 1,
      adminIds: (json['adminIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      category: json['category'] as String? ?? 'Residential',
    );
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? iconUrl,
    int? memberCount,
    List<String>? adminIds,
    DateTime? createdAt,
    String? category,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      iconUrl: iconUrl ?? this.iconUrl,
      memberCount: memberCount ?? this.memberCount,
      adminIds: adminIds ?? this.adminIds,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
