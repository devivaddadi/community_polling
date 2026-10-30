import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/polls/delete_poll_dialog.dart';
import '../../widgets/polls/poll_card.dart';
import '../polls/create_poll_screen.dart';
import '../polls/poll_results_screen.dart';

class UserPollsScreen extends StatelessWidget {
  const UserPollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pollProvider = context.watch<PollProvider>();
    final userId = auth.currentUser?.id ?? '';
    final myPolls = pollProvider.getUserCreatedPolls(userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Polls'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Poll'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePollScreen()),
          );
        },
      ),
      body: myPolls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No polls created yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Tap the button below to start a community poll', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myPolls.length,
              itemBuilder: (context, index) {
                final poll = myPolls[index];
                return PollCard(
                  poll: poll,
                  hasVoted: poll.hasUserVoted(userId),
                  onDelete: (auth.isAdmin || poll.creatorId == userId)
                      ? () async {
                          final confirm = await showDeletePollDialog(
                            context,
                            pollTitle: poll.question,
                          );
                          if (confirm == true) {
                            await pollProvider.deletePoll(poll.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Poll deleted successfully'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
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
