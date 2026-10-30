import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Shows a confirmation dialog to delete a poll.
/// Returns `true` if the admin confirms deletion, or `false`/`null` if cancelled.
Future<bool?> showDeletePollDialog(BuildContext context, {String? pollTitle}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          SizedBox(width: 8),
          Text(
            'Delete Poll',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        pollTitle != null && pollTitle.trim().isNotEmpty
            ? 'Are you sure you want to delete "$pollTitle"? This action cannot be undone and will permanently remove all associated votes and discussions.'
            : 'Are you sure you want to delete this poll? This action cannot be undone and will permanently remove all associated votes and discussions.',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
