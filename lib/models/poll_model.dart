class PollOption {
  final String id;
  final String text;
  int voteCount;
  double percentage;

  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.percentage = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'voteCount': voteCount,
      'percentage': percentage,
    };
  }

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: json['voteCount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  PollOption copyWith({
    String? id,
    String? text,
    int? voteCount,
    double? percentage,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      percentage: percentage ?? this.percentage,
    );
  }
}

enum PollStatus { active, closed }
enum PollType { public, anonymous }

class PollModel {
  final String id;
  final String communityId;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final String question;
  final String description;
  final String category;
  final List<PollOption> options;
  final PollType pollType;
  final DateTime createdAt;
  final DateTime endsAt;
  final int totalVotes;
  final PollStatus status;
  final List<String> voterUserIds;
  final bool allowCustomOption;

  PollModel({
    required this.id,
    required this.communityId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    required this.question,
    this.description = '',
    required this.category,
    required this.options,
    this.pollType = PollType.public,
    required this.createdAt,
    required this.endsAt,
    this.totalVotes = 0,
    this.status = PollStatus.active,
    this.voterUserIds = const [],
    this.allowCustomOption = true,
  });

  bool get isActive => status == PollStatus.active && endsAt.isAfter(DateTime.now());
  bool get isClosed => !isActive;
  bool get isAnonymous => pollType == PollType.anonymous;

  bool hasUserVoted(String userId) {
    return voterUserIds.contains(userId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'question': question,
      'description': description,
      'category': category,
      'options': options.map((e) => e.toJson()).toList(),
      'pollType': pollType.name,
      'createdAt': createdAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
      'totalVotes': totalVotes,
      'status': status.name,
      'voterUserIds': voterUserIds,
      'allowCustomOption': allowCustomOption,
    };
  }

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorAvatar: json['creatorAvatar'] as String? ?? 'https://i.pravatar.cc/150',
      question: json['question'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      pollType: json['pollType'] == 'anonymous' ? PollType.anonymous : PollType.public,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      totalVotes: json['totalVotes'] as int? ?? 0,
      status: json['status'] == 'closed' ? PollStatus.closed : PollStatus.active,
      voterUserIds: (json['voterUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      allowCustomOption: json['allowCustomOption'] as bool? ?? true,
    );
  }

  PollModel copyWith({
    String? id,
    String? communityId,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    String? question,
    String? description,
    String? category,
    List<PollOption>? options,
    PollType? pollType,
    DateTime? createdAt,
    DateTime? endsAt,
    int? totalVotes,
    PollStatus? status,
    List<String>? voterUserIds,
    bool? allowCustomOption,
  }) {
    return PollModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      question: question ?? this.question,
      description: description ?? this.description,
      category: category ?? this.category,
      options: options ?? this.options,
      pollType: pollType ?? this.pollType,
      createdAt: createdAt ?? this.createdAt,
      endsAt: endsAt ?? this.endsAt,
      totalVotes: totalVotes ?? this.totalVotes,
      status: status ?? this.status,
      voterUserIds: voterUserIds ?? this.voterUserIds,
      allowCustomOption: allowCustomOption ?? this.allowCustomOption,
    );
  }
}
