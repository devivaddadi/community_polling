import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../common/status_badge.dart';
import '../common/user_avatar.dart';

class MemberTile extends StatelessWidget {
  final UserModel member;
  final VoidCallback? onToggleRole;
  final VoidCallback? onRemove;

  const MemberTile({
    super.key,
    required this.member,
    this.onToggleRole,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: member.avatarUrl,
            name: member.name,
            radius: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            text: member.isAdmin ? 'Admin' : 'Resident',
            type: member.isAdmin ? BadgeType.admin : BadgeType.member,
            isSmall: true,
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            onSelected: (value) {
              if (value == 'role' && onToggleRole != null) {
                onToggleRole!();
              } else if (value == 'remove' && onRemove != null) {
                onRemove!();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'role',
                child: Row(
                  children: [
                    Icon(
                      member.isAdmin ? Icons.person_outline_rounded : Icons.admin_panel_settings_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      member.isAdmin ? 'Change to Resident' : 'Promote to Admin',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove_rounded, size: 18, color: AppColors.danger),
                    const SizedBox(width: 10),
                    const Text(
                      'Remove from Community',
                      style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

