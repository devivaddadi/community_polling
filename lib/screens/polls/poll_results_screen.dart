import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/decision_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/charts/donut_chart_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/polls/delete_poll_dialog.dart';
import '../../widgets/polls/poll_progress_bar.dart';
import '../admin/decision_tracking_screen.dart';
import '../discussion/discussion_screen.dart';

class PollResultsScreen extends StatefulWidget {
  final PollModel poll;

  const PollResultsScreen({super.key, required this.poll});

  @override
  State<PollResultsScreen> createState() => _PollResultsScreenState();
}

class _PollResultsScreenState extends State<PollResultsScreen> {
  int _viewMode = 0; // 0: List View, 1: Chart View

  @override
  Widget build(BuildContext context) {
    final pollProvider = context.watch<PollProvider>();
    final auth = context.watch<AuthProvider>();
    final decisionProvider = context.watch<DecisionProvider>();

    final poll = pollProvider.getPollById(widget.poll.id) ?? widget.poll;
    final decision = decisionProvider.getDecisionForPoll(poll.id);

    final optionValues = poll.options.map((o) => o.voteCount.toDouble()).toList();
    final optionLabels = poll.options.map((o) => o.text).toList();
    final chartColors = [
      AppColors.chartBlue,
      AppColors.chartGreen,
      AppColors.chartTeal,
      AppColors.chartAmber,
      AppColors.chartPurple,
      AppColors.chartPink,
    ];

    // Sorted options for list view
    final sortedOptions = List.of(poll.options)..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    final winner = sortedOptions.isNotEmpty ? sortedOptions.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Poll Results & Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              tooltip: 'Delete Poll',
              onPressed: () async {
                final confirm = await showDeletePollDialog(
                  context,
                  pollTitle: poll.question,
                );
                if (confirm == true) {
                  await pollProvider.deletePoll(poll.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Poll deleted successfully')),
                    );
                  }
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poll results summary copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control (List View vs Chart View)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Ranked Breakdown',
                      icon: Icons.format_list_bulleted_rounded,
                      isSelected: _viewMode == 0,
                      onTap: () => setState(() => _viewMode = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Chart View',
                      icon: Icons.pie_chart_outline_rounded,
                      isSelected: _viewMode == 1,
                      onTap: () => setState(() => _viewMode = 1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Poll Question Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        text: poll.isActive ? 'Active Poll' : 'Voting Closed',
                        type: poll.isActive ? BadgeType.active : BadgeType.closed,
                        isSmall: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${poll.totalVotes} verified votes',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        poll.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    poll.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.35,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Winner / Leading Choice Callout Banner
            if (winner != null && poll.totalVotes > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Leading Resident Choice',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            winner.text,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF78350F),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${winner.percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // View Content (List View or Chart View)
            if (_viewMode == 0) ...[
              // LIST VIEW (Ranked Breakdown)
              ...sortedOptions.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final option = entry.value;
                final color = chartColors[entry.key % chartColors.length];

                Color rankBadgeBg;
                Color rankBadgeFg;
                if (rank == 1) {
                  rankBadgeBg = const Color(0xFFFEF3C7);
                  rankBadgeFg = const Color(0xFFB45309);
                } else if (rank == 2) {
                  rankBadgeBg = const Color(0xFFF1F5F9);
                  rankBadgeFg = const Color(0xFF475569);
                } else {
                  rankBadgeBg = const Color(0xFFF8FAFC);
                  rankBadgeFg = const Color(0xFF94A3B8);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: rank == 1 ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.border,
                      width: rank == 1 ? 1.5 : 1,
                    ),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: rankBadgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: rankBadgeFg,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.text,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${option.percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                              Text(
                                '${option.voteCount} votes',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PollProgressBar(
                        percentage: option.percentage,
                        color: color,
                        height: 9,
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              // CHART VIEW
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: DonutChartWidget(
                  values: optionValues,
                  labels: optionLabels,
                  colors: chartColors,
                  centerTitle: '${poll.totalVotes}',
                  centerSubtitle: 'Total Votes Cast',
                ),
              ),
            ],

            const SizedBox(height: 20),

            // AI Insights Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDD6FE)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'AI Consensus & Recommendation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'High consensus identified around ${poll.options.first.text} with 82% favorable resident discussions. Suggested follow-up: Request municipal vendor proposals and finalize quorum.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4C1D95),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Discussion & Decision Action Row
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Discussion',
                    variant: ButtonVariant.secondary,
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscussionScreen(poll: poll),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: decision != null
                        ? 'View Decision'
                        : (auth.isAdmin ? 'Record Decision' : 'Action Plan'),
                    icon: Icons.assignment_turned_in_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DecisionTrackingScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Decentralized Community Governance • Realtime Verified',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? AppColors.softShadow : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
