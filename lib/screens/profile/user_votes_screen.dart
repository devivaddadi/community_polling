import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/polls/poll_card.dart';
import '../polls/poll_results_screen.dart';

class UserVotesScreen extends StatelessWidget {
  const UserVotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pollProvider = context.watch<PollProvider>();
    final userId = auth.currentUser?.id ?? '';
    final votedPolls = pollProvider.getUserVotedPolls(userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Votes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: votedPolls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No votes recorded yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Participate in active polls to see your vote history here', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: votedPolls.length,
              itemBuilder: (context, index) {
                final poll = votedPolls[index];
                return PollCard(
                  poll: poll,
                  hasVoted: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PollResultsScreen(poll: poll)),
                    );
                  },
                  onVoteTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PollResultsScreen(poll: poll)),
                    );
                  },
                );
              },
            ),
    );
  }
}
