import 'package:flutter/material.dart';
import '../models/analytics_model.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsOverview _overview = AnalyticsOverview.defaultSample();
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime(2024, 5, 1),
    end: DateTime(2024, 5, 31),
  );
  bool _isGeneratingAi = false;

  AnalyticsOverview get overview => _overview;
  DateTimeRange get selectedRange => _selectedRange;
  bool get isGeneratingAi => _isGeneratingAi;

  void updateDateRange(DateTimeRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  Future<void> refreshAiInsights() async {
    _isGeneratingAi = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _overview = AnalyticsOverview(
      totalMembers: _overview.totalMembers,
      activePolls: _overview.activePolls,
      totalPolls: _overview.totalPolls,
      totalVotes: _overview.totalVotes + 5,
      participationRate: 71.4,
      votesOverTimeData: [120, 180, 135, 195, 240],
      votesOverTimeLabels: ['1 May', '10 May', '20 May', '31 May', 'Now'],
      categoryDistribution: _overview.categoryDistribution,
      sentimentStats: {
        'Positive': 68,
        'Constructive': 24,
        'Critical': 8,
      },
      aiInsights: [
        'Residents overwhelmingly prioritize lighting (45%) and clean water (25%) over other amenities.',
        'High positive sentiment (68%) indicates strong community trust in decision transparency.',
        'Weekend polling drives +32% higher engagement than weekday mornings.',
      ],
    );

    _isGeneratingAi = false;
    notifyListeners();
  }
}
