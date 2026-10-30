import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/decision_model.dart';
import '../services/mock_data_service.dart';
import '../services/realtime_database_service.dart';

class DecisionProvider extends ChangeNotifier {
  List<DecisionModel> _decisions = MockDataService.getMockDecisions();
  StreamSubscription<List<DecisionModel>>? _decisionsSub;

  List<DecisionModel> get decisions => _decisions;

  DecisionProvider() {
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      _decisionsSub = rtdb.getDecisionsStream().listen((firebaseDecisions) {
        if (firebaseDecisions.isNotEmpty) {
          _decisions = firebaseDecisions;
          notifyListeners();
        }
      });
    }
  }

  List<DecisionModel> getDecisionsForCommunity(String communityId) {
    return _decisions.where((d) => d.communityId == communityId).toList();
  }

  DecisionModel? getDecisionForPoll(String pollId) {
    try {
      return _decisions.firstWhere((d) => d.pollId == pollId);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordDecision({
    required String communityId,
    required String pollId,
    required String pollTitle,
    required String title,
    required String summary,
    required String rationale,
    required String decidedBy,
    required List<String> actionTitles,
    String estimatedBudget = '',
    String targetCompletionDate = '',
  }) async {
    final now = DateTime.now();
    final actionItems = actionTitles.map((t) {
      return ActionItem(
        id: const Uuid().v4(),
        title: t,
        assignedTo: 'Executive Council',
        dueDate: now.add(const Duration(days: 14)),
        isCompleted: false,
      );
    }).toList();

    final newDecision = DecisionModel(
      id: const Uuid().v4(),
      communityId: communityId,
      pollId: pollId,
      pollTitle: pollTitle,
      title: title,
      summary: summary,
      rationale: rationale,
      status: DecisionStatus.inProgress,
      decidedBy: decidedBy,
      decidedAt: now,
      actionItems: actionItems,
      estimatedBudget: estimatedBudget,
      targetCompletionDate: targetCompletionDate,
    );

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.recordDecision(newDecision);
    }

    _decisions.insert(0, newDecision);
    notifyListeners();
  }

  Future<void> toggleActionItem(String decisionId, String actionItemId) async {
    final decIndex = _decisions.indexWhere((d) => d.id == decisionId);
    if (decIndex == -1) return;

    final decision = _decisions[decIndex];
    final actIndex = decision.actionItems.indexWhere((a) => a.id == actionItemId);
    if (actIndex == -1) return;

    final item = decision.actionItems[actIndex];
    final newStatus = !item.isCompleted;
    item.isCompleted = newStatus;

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.toggleActionItem(
        decisionId: decisionId,
        actionItemId: actionItemId,
        isCompleted: newStatus,
      );
    }

    notifyListeners();
  }

  Future<void> updateDecisionStatus(String decisionId, DecisionStatus status) async {
    final decIndex = _decisions.indexWhere((d) => d.id == decisionId);
    if (decIndex != -1) {
      final updated = DecisionModel(
        id: _decisions[decIndex].id,
        communityId: _decisions[decIndex].communityId,
        pollId: _decisions[decIndex].pollId,
        pollTitle: _decisions[decIndex].pollTitle,
        title: _decisions[decIndex].title,
        summary: _decisions[decIndex].summary,
        rationale: _decisions[decIndex].rationale,
        status: status,
        decidedBy: _decisions[decIndex].decidedBy,
        decidedAt: _decisions[decIndex].decidedAt,
        actionItems: _decisions[decIndex].actionItems,
        estimatedBudget: _decisions[decIndex].estimatedBudget,
        targetCompletionDate: _decisions[decIndex].targetCompletionDate,
      );
      _decisions[decIndex] = updated;

      final rtdb = RealtimeDatabaseService();
      if (rtdb.isConnected) {
        await rtdb.recordDecision(updated);
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _decisionsSub?.cancel();
    super.dispose();
  }
}
