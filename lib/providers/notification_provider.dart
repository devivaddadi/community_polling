import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';
import '../services/realtime_database_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = MockDataService.getMockNotifications();
  StreamSubscription<List<NotificationModel>>? _notifsSub;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      _notifsSub = rtdb.getNotificationsStream().listen((firebaseNotifs) {
        if (firebaseNotifs.isNotEmpty) {
          _notifications = firebaseNotifs;
          notifyListeners();
        }
      });
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;

      final rtdb = RealtimeDatabaseService();
      if (rtdb.isConnected) {
        await rtdb.markNotificationAsRead(id);
      }

      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
      final rtdb = RealtimeDatabaseService();
      if (rtdb.isConnected) {
        rtdb.markNotificationAsRead(n.id);
      }
    }
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedPollId,
    String? relatedDecisionId,
  }) async {
    final newNotif = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      relatedPollId: relatedPollId,
      relatedDecisionId: relatedDecisionId,
    );

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.addNotification(newNotif);
    }

    _notifications.insert(0, newNotif);
    notifyListeners();
  }

  @override
  void dispose() {
    _notifsSub?.cancel();
    super.dispose();
  }
}
