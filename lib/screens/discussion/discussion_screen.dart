import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/comment_model.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/discussion_provider.dart';
import '../../providers/poll_provider.dart';
import '../../widgets/discussions/comment_tile.dart';

class DiscussionScreen extends StatefulWidget {
  final PollModel? poll;

  const DiscussionScreen({super.key, this.poll});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  int _selectedTab = 0; // 0: All Comments, 1: My Comments
  final _commentController = TextEditingController();
  CommentModel? _replyingToComment;
  late PollModel _activePoll;

  @override
  void initState() {
    super.initState();
    final pollProvider = context.read<PollProvider>();
    _activePoll = widget.poll ?? pollProvider.polls.first;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final discussionProvider = context.read<DiscussionProvider>();
    final user = auth.currentUser;

    if (_replyingToComment != null) {
      discussionProvider.addReply(
        commentId: _replyingToComment!.id,
        userId: user?.id ?? 'u_guest',
        userName: user?.name ?? 'Neighbor',
        userAvatar: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        text: text,
      );
    } else {
      discussionProvider.addComment(
        pollId: _activePoll.id,
        userId: user?.id ?? 'u_guest',
        userName: user?.name ?? 'Neighbor',
        userAvatar: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        text: text,
      );
    }

    _commentController.clear();
    setState(() {
      _replyingToComment = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final discussionProvider = context.watch<DiscussionProvider>();
    final pollProvider = context.watch<PollProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    final allComments = discussionProvider.getCommentsForPoll(_activePoll.id);
    final myComments = allComments.where((c) => c.userId == currentUserId).toList();
    final displayedComments = _selectedTab == 0 ? allComments : myComments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community Discussion'),
        leading: widget.poll != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          // Poll Context Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.poll == null) ...[
                  // Poll dropdown switcher if on standalone tab
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activePoll.id,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                        items: pollProvider.polls.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Row(
                              children: [
                                const Icon(Icons.how_to_vote_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p.question,
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            setState(() {
                              _activePoll = pollProvider.getPollById(id)!;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    _activePoll.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Tabs: [All Comments] | [My Comments]
                Row(
                  children: [
                    _buildTabButton(
                      label: 'All Comments (${allComments.length})',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    const SizedBox(width: 8),
                    _buildTabButton(
                      label: 'My Comments (${myComments.length})',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: displayedComments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.forum_outlined, size: 44, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _selectedTab == 0 ? 'No comments yet' : 'You have not commented yet',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share your perspective with fellow residents!',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: displayedComments.length,
                    itemBuilder: (context, index) {
                      final comment = displayedComments[index];
                      return CommentTile(
                        comment: comment,
                        currentUserId: currentUserId,
                        onLikeTap: () {
                          discussionProvider.toggleLike(
                            commentId: comment.id,
                            userId: currentUserId,
                          );
                        },
                        onReplyTap: () {
                          setState(() {
                            _replyingToComment = comment;
                          });
                        },
                        onReplyLikeTap: (replyId) {
                          discussionProvider.toggleReplyLike(
                            commentId: comment.id,
                            replyId: replyId,
                            userId: currentUserId,
                          );
                        },
                      );
                    },
                  ),
          ),

          // Reply indicator banner if replying
          if (_replyingToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: AppColors.primaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingToComment!.userName}...',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                    onPressed: () => setState(() => _replyingToComment = null),
                  ),
                ],
              ),
            ),

          // Sticky Bottom Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Add to the community conversation...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sendComment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
