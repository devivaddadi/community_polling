enum DecisionStatus {
  proposed,
  inProgress,
  completed,
  cancelled,
}

class ActionItem {
  final String id;
  final String title;
  final String assignedTo;
  final DateTime dueDate;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      assignedTo: json['assignedTo'] as String? ?? 'Community Committee',
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 14)),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class DecisionModel {
  final String id;
  final String communityId;
  final String pollId;
  final String pollTitle;
  final String title;
  final String summary;
  final String rationale;
  final DecisionStatus status;
  final String decidedBy;
  final DateTime decidedAt;
  final List<ActionItem> actionItems;
  final String estimatedBudget;
  final String targetCompletionDate;

  DecisionModel({
    required this.id,
    required this.communityId,
    required this.pollId,
    required this.pollTitle,
    required this.title,
    required this.summary,
    required this.rationale,
    this.status = DecisionStatus.inProgress,
    required this.decidedBy,
    required this.decidedAt,
    required this.actionItems,
    this.estimatedBudget = '',
    this.targetCompletionDate = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'pollId': pollId,
      'pollTitle': pollTitle,
      'title': title,
      'summary': summary,
      'rationale': rationale,
      'status': status.name,
      'decidedBy': decidedBy,
      'decidedAt': decidedAt.toIso8601String(),
      'actionItems': actionItems.map((e) => e.toJson()).toList(),
      'estimatedBudget': estimatedBudget,
      'targetCompletionDate': targetCompletionDate,
    };
  }

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    DecisionStatus status;
    switch (json['status']) {
      case 'proposed':
        status = DecisionStatus.proposed;
        break;
      case 'completed':
        status = DecisionStatus.completed;
        break;
      case 'cancelled':
        status = DecisionStatus.cancelled;
        break;
      case 'inProgress':
      default:
        status = DecisionStatus.inProgress;
        break;
    }

    return DecisionModel(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      pollId: json['pollId'] as String,
      pollTitle: json['pollTitle'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      rationale: json['rationale'] as String? ?? '',
      status: status,
      decidedBy: json['decidedBy'] as String? ?? 'Admin Council',
      decidedAt: DateTime.tryParse(json['decidedAt'] as String? ?? '') ?? DateTime.now(),
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedBudget: json['estimatedBudget'] as String? ?? '',
      targetCompletionDate: json['targetCompletionDate'] as String? ?? '',
    );
  }
}
