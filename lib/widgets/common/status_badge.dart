import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeType { active, closed, admin, member, inProgress, completed, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.active,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.active:
      case BadgeType.completed:
        bg = AppColors.successBg;
        fg = AppColors.successText;
        break;
      case BadgeType.closed:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case BadgeType.admin:
        bg = const Color(0xFFEEF2FF);
        fg = AppColors.primary;
        break;
      case BadgeType.inProgress:
        bg = AppColors.warningBg;
        fg = AppColors.warningText;
        break;
      case BadgeType.member:
      case BadgeType.info:
        bg = const Color(0xFFF1F5F9);
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
