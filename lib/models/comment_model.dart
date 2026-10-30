class CommentReply {
  final String id;
  final String commentId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  int likesCount;
  List<String> likedByUserIds;

  CommentReply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likesCount = 0,
    this.likedByUserIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commentId': commentId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likesCount': likesCount,
      'likedByUserIds': likedByUserIds,
    };
  }

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      id: json['id'] as String,
      commentId: json['commentId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String? ?? 'https://i.pravatar.cc/150',
      text: json['text'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      likesCount: json['likesCount'] as int? ?? 0,
      likedByUserIds: (json['likedByUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CommentModel {
  final String id;
  final String pollId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  int likesCount;
  List<String> likedByUserIds;
  List<CommentReply> replies;

  CommentModel({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likesCount = 0,
    this.likedByUserIds = const [],
    this.replies = const [],
  });

  bool isLikedBy(String userId) => likedByUserIds.contains(userId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likesCount': likesCount,
      'likedByUserIds': likedByUserIds,
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String? ?? 'https://i.pravatar.cc/150',
      text: json['text'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      likesCount: json['likesCount'] as int? ?? 0,
      likedByUserIds: (json['likedByUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentReply.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  CommentModel copyWith({
    String? id,
    String? pollId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    DateTime? timestamp,
    int? likesCount,
    List<String>? likedByUserIds,
    List<CommentReply>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      replies: replies ?? this.replies,
    );
  }
}
