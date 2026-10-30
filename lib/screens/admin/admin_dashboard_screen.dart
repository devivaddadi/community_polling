import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/community_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/admin/metric_stat_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/polls/delete_poll_dialog.dart';
import '../polls/create_poll_screen.dart';
import '../polls/poll_results_screen.dart';
import 'analytics_screen.dart';
import 'community_members_screen.dart';
import 'decision_tracking_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pollProvider = context.watch<PollProvider>();
    final communityProvider = context.watch<CommunityProvider>();

    final totalMembers = communityProvider.totalMembersCount;
    final activePolls = pollProvider.activePollsCount;
    final totalPolls = pollProvider.totalPollsCount;
    final totalVotes = pollProvider.totalVotesCount;
    final recentPolls = pollProvider.polls;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Metric Cards Grid
            Row(
              children: [
                Expanded(
                  child: MetricStatCard(
                    title: 'Total Members',
                    value: '$totalMembers',
                    icon: Icons.people_alt_outlined,
                    iconColor: AppColors.primary,
                    iconBgColor: const Color(0xFFEEF2FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CommunityMembersScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricStatCard(
                    title: 'Active Polls',
                    value: '$activePolls',
                    icon: Icons.how_to_vote_outlined,
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricStatCard(
                    title: 'Total Polls',
                    value: '$totalPolls',
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.chartBlue,
                    iconBgColor: const Color(0xFFE0F2FE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricStatCard(
                    title: 'Total Votes',
                    value: '$totalVotes',
                    icon: Icons.emoji_events_outlined,
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warningBg,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Management Hub
            const Text(
              'Management Tools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildToolCard(
                    icon: Icons.insights_rounded,
                    label: 'Analytics',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildToolCard(
                    icon: Icons.group_add_outlined,
                    label: 'Members',
                    color: AppColors.chartTeal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CommunityMembersScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildToolCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Decisions',
                    color: AppColors.chartPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DecisionTrackingScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildToolCard(
                    icon: Icons.add_chart_rounded,
                    label: 'New Poll',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreatePollScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent Polls Section
            SectionHeader(
              title: 'Recent Polls',
              actionText: 'View all',
              onActionTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            if (recentPolls.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No polls found',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              ...recentPolls.map((poll) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PollResultsScreen(poll: poll)),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poll.question,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${poll.totalVotes} votes',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${poll.category}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          text: poll.isActive ? 'Active' : 'Closed',
                          type: poll.isActive ? BadgeType.active : BadgeType.closed,
                          isSmall: true,
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                          tooltip: 'Delete Poll',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () async {
                            final confirm = await showDeletePollDialog(
                              context,
                              pollTitle: poll.question,
                            );
                            if (confirm == true) {
                              await pollProvider.deletePoll(poll.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Poll deleted successfully')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
