class AnalyticsOverview {
  final int totalMembers;
  final int activePolls;
  final int totalPolls;
  final int totalVotes;
  final double participationRate;
  final List<double> votesOverTimeData;
  final List<String> votesOverTimeLabels;
  final Map<String, double> categoryDistribution;
  final Map<String, int> sentimentStats;
  final List<String> aiInsights;

  AnalyticsOverview({
    required this.totalMembers,
    required this.activePolls,
    required this.totalPolls,
    required this.totalVotes,
    required this.participationRate,
    required this.votesOverTimeData,
    required this.votesOverTimeLabels,
    required this.categoryDistribution,
    required this.sentimentStats,
    required this.aiInsights,
  });

  factory AnalyticsOverview.defaultSample() {
    return AnalyticsOverview(
      totalMembers: 128,
      activePolls: 3,
      totalPolls: 15,
      totalVotes: 842,
      participationRate: 68.0,
      votesOverTimeData: [120, 180, 135, 195, 212],
      votesOverTimeLabels: ['1 May', '10 May', '20 May', '31 May', 'Now'],
      categoryDistribution: {
        'Infrastructure': 40.0,
        'Environment': 25.0,
        'Events': 20.0,
        'Other': 15.0,
      },
      sentimentStats: {
        'Positive': 62,
        'Constructive': 28,
        'Critical': 10,
      },
      aiInsights: [
        'Residents show highest enthusiasm for safety and infrastructure improvements (+45% priority).',
        'Weekend community recycling initiatives received 78% favorable comments.',
        'Overall participation rate increased by 14% compared to the previous month.',
      ],
    );
  }
}
