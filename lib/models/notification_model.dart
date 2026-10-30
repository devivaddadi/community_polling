enum NotificationType {
  newPoll,
  pollClosing,
  resultsPublished,
  newComment,
  decisionRecorded,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final String? relatedPollId;
  final String? relatedDecisionId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedPollId,
    this.relatedDecisionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedPollId': relatedPollId,
      'relatedDecisionId': relatedDecisionId,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    switch (json['type']) {
      case 'pollClosing':
        type = NotificationType.pollClosing;
        break;
      case 'resultsPublished':
        type = NotificationType.resultsPublished;
        break;
      case 'newComment':
        type = NotificationType.newComment;
        break;
      case 'decisionRecorded':
        type = NotificationType.decisionRecorded;
        break;
      case 'newPoll':
      default:
        type = NotificationType.newPoll;
        break;
    }

    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: type,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      relatedPollId: json['relatedPollId'] as String?,
      relatedDecisionId: json['relatedDecisionId'] as String?,
    );
  }
}
