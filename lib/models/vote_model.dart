class VoteModel {
  final String id;
  final String pollId;
  final String userId;
  final String optionId;
  final String? customText;
  final DateTime timestamp;
  final bool isAnonymous;

  VoteModel({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.optionId,
    this.customText,
    required this.timestamp,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'userId': isAnonymous ? 'anonymous' : userId,
      'optionId': optionId,
      'customText': customText,
      'timestamp': timestamp.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      userId: json['userId'] as String,
      optionId: json['optionId'] as String,
      customText: json['customText'] as String?,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
}
