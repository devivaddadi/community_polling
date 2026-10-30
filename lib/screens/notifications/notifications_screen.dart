import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/poll_provider.dart';
import '../admin/decision_tracking_screen.dart';
import '../polls/poll_detail_screen.dart';
import '../polls/poll_results_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterTab = 0; // 0: All, 1: Unread

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final pollProvider = context.watch<PollProvider>();
    final allNotifs = notifProvider.notifications;
    final unreadNotifs = allNotifs.where((n) => !n.isRead).toList();
    final displayedNotifs = _filterTab == 0 ? allNotifs : unreadNotifs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              _showNotificationSettings(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All / Unread)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All (${allNotifs.length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Unread (${unreadNotifs.length})', 1),
              ],
            ),
          ),

          Expanded(
            child: displayedNotifs.isEmpty
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
                          child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _filterTab == 0 ? 'No notifications yet' : 'No unread notifications',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You are all caught up on community updates!',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: displayedNotifs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = displayedNotifs[index];
                      return _buildNotificationItem(context, notif, notifProvider, pollProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _filterTab == index;

    return GestureDetector(
      onTap: () => setState(() => _filterTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppColors.softShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notif,
    NotificationProvider notifProvider,
    PollProvider pollProvider,
  ) {
    IconData iconData;
    Color iconColor;
    Color iconBg;

    switch (notif.type) {
      case NotificationType.newPoll:
        iconData = Icons.how_to_vote_rounded;
        iconColor = AppColors.primary;
        iconBg = const Color(0xFFEEF2FF);
        break;
      case NotificationType.pollClosing:
        iconData = Icons.access_alarm_rounded;
        iconColor = AppColors.warning;
        iconBg = AppColors.warningBg;
        break;
      case NotificationType.resultsPublished:
        iconData = Icons.bar_chart_rounded;
        iconColor = AppColors.success;
        iconBg = AppColors.successBg;
        break;
      case NotificationType.newComment:
        iconData = Icons.chat_bubble_outline_rounded;
        iconColor = AppColors.chartTeal;
        iconBg = const Color(0xFFE0F2FE);
        break;
      case NotificationType.decisionRecorded:
        iconData = Icons.assignment_turned_in_outlined;
        iconColor = AppColors.chartPurple;
        iconBg = const Color(0xFFF3E8FF);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: notif.isRead ? AppColors.border : AppColors.primaryLight.withValues(alpha: 0.45),
          width: notif.isRead ? 1 : 1.4,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            notifProvider.markAsRead(notif.id);

            if (notif.relatedPollId != null) {
              final poll = pollProvider.getPollById(notif.relatedPollId!);
              if (poll != null) {
                if (notif.type == NotificationType.resultsPublished) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PollResultsScreen(poll: poll)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PollDetailScreen(poll: poll)),
                  );
                }
              }
            } else if (notif.type == NotificationType.decisionRecorded) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DecisionTrackingScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.formatTimeAgo(notif.timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notif.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
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
            const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('New Poll Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Get notified when new polls open in your neighborhood', style: TextStyle(fontSize: 12)),
              value: true,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Poll Closing Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Reminder 6 hours before voting deadline closes', style: TextStyle(fontSize: 12)),
              value: true,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Discussion Replies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('When someone replies to your comment', style: TextStyle(fontSize: 12)),
              value: true,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
    );
  }
}
