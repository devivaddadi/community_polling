import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dateTime);
    }
  }

  static String formatClosesIn(DateTime endDateTime) {
    final now = DateTime.now();
    final difference = endDateTime.difference(now);

    if (difference.isNegative) {
      return 'Closed';
    } else if (difference.inDays > 0) {
      return 'Closes in ${difference.inDays} ${difference.inDays == 1 ? "day" : "days"}';
    } else if (difference.inHours > 0) {
      return 'Closes in ${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"}';
    } else if (difference.inMinutes > 0) {
      return 'Closes in ${difference.inMinutes} mins';
    } else {
      return 'Closing soon';
    }
  }
}
