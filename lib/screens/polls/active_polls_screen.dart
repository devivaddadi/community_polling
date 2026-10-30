import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/polls/category_chip.dart';
import '../../widgets/polls/delete_poll_dialog.dart';
import '../../widgets/polls/poll_card.dart';
import 'create_poll_screen.dart';
import 'poll_detail_screen.dart';
import 'poll_results_screen.dart';

class ActivePollsScreen extends StatefulWidget {
  const ActivePollsScreen({super.key});

  @override
  State<ActivePollsScreen> createState() => _ActivePollsScreenState();
}

class _ActivePollsScreenState extends State<ActivePollsScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pollProvider = context.watch<PollProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    final polls = pollProvider.filteredPolls;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community Polls'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  pollProvider.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.textPrimary),
            onPressed: () {
              _showFilterModal(context, pollProvider);
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.38),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'New Poll',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePollScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Optional Search Bar
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => pollProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by topic, keyword or category...',
                    hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              pollProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

          // Horizontal Category Chips
          Container(
            height: 52,
            margin: const EdgeInsets.only(top: 4, bottom: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: AppConstants.defaultCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = AppConstants.defaultCategories[index];
                final isSelected = pollProvider.selectedCategory == category;
                return CategoryChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => pollProvider.setCategory(category),
                );
              },
            ),
          ),

          // Status toggle filter (All / Active / Closed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                _buildStatusTab('All Polls', 'all', pollProvider),
                const SizedBox(width: 8),
                _buildStatusTab('Active Live', 'active', pollProvider),
                const SizedBox(width: 8),
                _buildStatusTab('Closed Results', 'closed', pollProvider),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Polls List
          Expanded(
            child: polls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.how_to_vote_outlined, size: 48, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No polls found matching criteria',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try clearing your search query or category filter',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: polls.length,
                    itemBuilder: (context, index) {
                      final poll = polls[index];
                      final hasVoted = poll.hasUserVoted(currentUserId);

                      return PollCard(
                        poll: poll,
                        hasVoted: hasVoted,
                        onDelete: authProvider.isAdmin
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
                          if (hasVoted || poll.isClosed) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PollResultsScreen(poll: poll),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PollDetailScreen(poll: poll),
                              ),
                            );
                          }
                        },
                        onVoteTap: () {
                          if (hasVoted || poll.isClosed) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PollResultsScreen(poll: poll),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PollDetailScreen(poll: poll),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String label, String statusKey, PollProvider provider) {
    final isSelected = provider.filterStatus == statusKey;
    return GestureDetector(
      onTap: () => provider.setFilterStatus(statusKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context, PollProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Filter Polls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Show All Polls', style: TextStyle(fontWeight: FontWeight.w600)),
              leading: const Icon(Icons.all_inclusive_rounded, color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                provider.setFilterStatus('all');
                provider.setCategory('All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active Voting Only', style: TextStyle(fontWeight: FontWeight.w600)),
              leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                provider.setFilterStatus('active');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Closed Archive Only', style: TextStyle(fontWeight: FontWeight.w600)),
              leading: const Icon(Icons.history_rounded, color: AppColors.warning),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                provider.setFilterStatus('closed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
