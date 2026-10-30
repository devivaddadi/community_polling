import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';
import '../models/poll_model.dart';
import '../models/comment_model.dart';
import '../models/decision_model.dart';
import '../models/notification_model.dart';
import '../models/community_model.dart';
import '../models/vote_model.dart';
import 'mock_data_service.dart';

class RealtimeDatabaseService {
  static final RealtimeDatabaseService _instance = RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;
  RealtimeDatabaseService._internal();

  FirebaseDatabase? _db;
  bool _isInitialized = false;

  bool get isConnected => _isInitialized && _db != null;

  DatabaseReference get _usersRef => _db!.ref('users');
  DatabaseReference get _pollsRef => _db!.ref('polls');
  DatabaseReference get _commentsRef => _db!.ref('comments');
  DatabaseReference get _votesRef => _db!.ref('votes');
  DatabaseReference get _decisionsRef => _db!.ref('decisions');
  DatabaseReference get _communitiesRef => _db!.ref('communities');
  DatabaseReference get _notificationsRef => _db!.ref('notifications');

  /// Initialize Firebase app and database instance
  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 4));
      }
      final dbUrl = DefaultFirebaseOptions.currentPlatform.databaseURL;
      if (dbUrl != null && dbUrl.isNotEmpty) {
        _db = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: dbUrl,
        );
      } else {
        _db = FirebaseDatabase.instance;
      }
      _isInitialized = true;
      debugPrint('[RealtimeDatabaseService] Firebase initialized successfully.');

      // Check and seed initial data in background without blocking app startup
      unawaited(seedInitialDataIfEmpty());
      return true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('[RealtimeDatabaseService] Firebase init fallback: $e');
      return false;
    }
  }

  // ==========================================
  // HELPER: Deep Casting for RTDB Snapshots
  // ==========================================
  static Map<String, dynamic> deepCastMap(dynamic map) {
    if (map == null || map is! Map) return {};
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), deepCastMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), deepCastList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  static List<dynamic> deepCastList(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((item) {
      if (item is Map) return deepCastMap(item);
      if (item is List) return deepCastList(item);
      return item;
    }).toList();
  }

  // ==========================================
  // USERS & PROFILES
  // ==========================================
  Stream<List<UserModel>> getUsersStream() {
    if (!isConnected) return const Stream.empty();

    return _usersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <UserModel>[];

      final List<UserModel> list = [];
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            list.add(UserModel.fromJson(map));
          } catch (err) {
            debugPrint('Error parsing user $key: $err');
          }
        });
      }
      return list;
    });
  }

  Future<void> saveUser(UserModel user, {String? password}) async {
    if (!isConnected) return;
    try {
      final data = user.toJson();
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      await _usersRef.child(user.id).set(data).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error saving user to RTDB: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    if (!isConnected) return null;
    try {
      final snapshot = await _usersRef.get().timeout(const Duration(seconds: 4));
      if (!snapshot.exists || snapshot.value == null) return null;
      final data = snapshot.value;
      if (data is Map) {
        for (var val in data.values) {
          final map = deepCastMap(val);
          if ((map['email'] as String? ?? '').toLowerCase() == email.trim().toLowerCase()) {
            return UserModel.fromJson(map);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user by email: $e');
    }
    return null;
  }

  // ==========================================
  // POLLS
  // ==========================================
  Stream<List<PollModel>> getPollsStream({String? communityId}) {
    if (!isConnected) return const Stream.empty();

    return _pollsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <PollModel>[];

      final List<PollModel> result = [];
      final Set<String> seenIds = {};
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            final poll = PollModel.fromJson(map);
            if ((communityId == null || poll.communityId == communityId) &&
                seenIds.add(poll.id)) {
              result.add(poll);
            }
          } catch (err) {
            debugPrint('Error parsing poll $key: $err');
          }
        });
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    });
  }

  Future<void> createPoll(PollModel poll) async {
    if (!isConnected) return;
    await _pollsRef.child(poll.id).set(poll.toJson());
  }

  Future<void> deletePoll(String pollId) async {
    if (!isConnected) return;
    try {
      await _pollsRef.child(pollId).remove();
      await _commentsRef.child(pollId).remove();
      await _votesRef.child(pollId).remove();
    } catch (e) {
      debugPrint('Error deleting poll from RTDB: $e');
    }
  }

  Future<bool> submitVote({
    required String pollId,
    required String optionId,
    required String userId,
    String? customText,
    bool isAnonymous = false,
  }) async {
    if (!isConnected) return false;

    try {
      final pollSnapshot = await _pollsRef.child(pollId).get();
      if (!pollSnapshot.exists || pollSnapshot.value == null) return false;

      final pollMap = deepCastMap(pollSnapshot.value);
      final poll = PollModel.fromJson(pollMap);

      if (poll.hasUserVoted(userId)) {
        return false;
      }

      final voterUserIds = List<String>.from(poll.voterUserIds)..add(userId);
      final totalVotes = poll.totalVotes + 1;

      final updatedOptions = poll.options.map((opt) {
        if (opt.id == optionId) {
          final newCount = opt.voteCount + 1;
          final newPct = (newCount / totalVotes) * 100;
          return opt.copyWith(voteCount: newCount, percentage: newPct);
        } else {
          final newPct = totalVotes > 0 ? (opt.voteCount / totalVotes) * 100 : 0.0;
          return opt.copyWith(percentage: newPct);
        }
      }).toList();

      final updatedPoll = poll.copyWith(
        options: updatedOptions,
        totalVotes: totalVotes,
        voterUserIds: voterUserIds,
      );

      // Save updated poll in RTDB
      await _pollsRef.child(pollId).set(updatedPoll.toJson());

      // Record individual vote
      final vote = VoteModel(
        id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
        pollId: pollId,
        optionId: optionId,
        userId: userId,
        timestamp: DateTime.now(),
        customText: customText,
        isAnonymous: isAnonymous,
      );
      await _votesRef.child(pollId).child(userId).set(vote.toJson());

      return true;
    } catch (e) {
      debugPrint('Error submitting vote to RTDB: $e');
      return false;
    }
  }

  // ==========================================
  // DISCUSSIONS & COMMENTS
  // ==========================================
  Stream<List<CommentModel>> getCommentsStream(String pollId) {
    if (!isConnected) return const Stream.empty();

    return _commentsRef.child(pollId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <CommentModel>[];

      final List<CommentModel> list = [];
      final Set<String> seenIds = {};
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            final comment = CommentModel.fromJson(map);
            if (seenIds.add(comment.id)) {
              list.add(comment);
            }
          } catch (err) {
            debugPrint('Error parsing comment $key: $err');
          }
        });
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addComment(CommentModel comment) async {
    if (!isConnected) return;
    await _commentsRef.child(comment.pollId).child(comment.id).set(comment.toJson());
  }

  Future<void> addReply({
    required String pollId,
    required String commentId,
    required CommentReply reply,
  }) async {
    if (!isConnected) return;

    final commentSnapshot = await _commentsRef.child(pollId).child(commentId).get();
    if (!commentSnapshot.exists || commentSnapshot.value == null) return;

    final commentMap = deepCastMap(commentSnapshot.value);
    final comment = CommentModel.fromJson(commentMap);
    final updatedReplies = List<CommentReply>.from(comment.replies)..add(reply);

    await _commentsRef.child(pollId).child(commentId).update({
      'replies': updatedReplies.map((r) => r.toJson()).toList(),
    });
  }

  Future<void> toggleCommentLike({
    required String pollId,
    required String commentId,
    required String userId,
  }) async {
    if (!isConnected) return;

    final commentSnapshot = await _commentsRef.child(pollId).child(commentId).get();
    if (!commentSnapshot.exists || commentSnapshot.value == null) return;

    final commentMap = deepCastMap(commentSnapshot.value);
    final comment = CommentModel.fromJson(commentMap);

    final liked = List<String>.from(comment.likedByUserIds);
    int likes = comment.likesCount;

    if (liked.contains(userId)) {
      liked.remove(userId);
      likes = (likes - 1).clamp(0, 999999);
    } else {
      liked.add(userId);
      likes += 1;
    }

    await _commentsRef.child(pollId).child(commentId).update({
      'likesCount': likes,
      'likedByUserIds': liked,
    });
  }

  // ==========================================
  // GOVERNANCE DECISIONS
  // ==========================================
  Stream<List<DecisionModel>> getDecisionsStream({String? communityId}) {
    if (!isConnected) return const Stream.empty();

    return _decisionsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <DecisionModel>[];

      final List<DecisionModel> list = [];
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            final dec = DecisionModel.fromJson(map);
            if (communityId == null || dec.communityId == communityId) {
              list.add(dec);
            }
          } catch (err) {
            debugPrint('Error parsing decision $key: $err');
          }
        });
      }
      list.sort((a, b) => b.decidedAt.compareTo(a.decidedAt));
      return list;
    });
  }

  Future<void> recordDecision(DecisionModel decision) async {
    if (!isConnected) return;
    await _decisionsRef.child(decision.id).set(decision.toJson());
  }

  Future<void> toggleActionItem({
    required String decisionId,
    required String actionItemId,
    required bool isCompleted,
  }) async {
    if (!isConnected) return;

    final decSnapshot = await _decisionsRef.child(decisionId).get();
    if (!decSnapshot.exists || decSnapshot.value == null) return;

    final decMap = deepCastMap(decSnapshot.value);
    final decision = DecisionModel.fromJson(decMap);

    final updatedItems = decision.actionItems.map((item) {
      if (item.id == actionItemId) {
        item.isCompleted = isCompleted;
      }
      return item;
    }).toList();

    await _decisionsRef.child(decisionId).update({
      'actionItems': updatedItems.map((e) => e.toJson()).toList(),
    });
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================
  Stream<List<NotificationModel>> getNotificationsStream() {
    if (!isConnected) return const Stream.empty();

    return _notificationsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <NotificationModel>[];

      final List<NotificationModel> list = [];
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            list.add(NotificationModel.fromJson(map));
          } catch (err) {
            debugPrint('Error parsing notification $key: $err');
          }
        });
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (!isConnected) return;
    await _notificationsRef.child(notification.id).set(notification.toJson());
  }

  Future<void> markNotificationAsRead(String notifId) async {
    if (!isConnected) return;
    await _notificationsRef.child(notifId).update({'isRead': true});
  }

  // ==========================================
  // COMMUNITIES
  // ==========================================
  Stream<List<CommunityModel>> getCommunitiesStream() {
    if (!isConnected) return const Stream.empty();

    return _communitiesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <CommunityModel>[];

      final List<CommunityModel> list = [];
      if (data is Map) {
        data.forEach((key, val) {
          try {
            final map = deepCastMap(val);
            list.add(CommunityModel.fromJson(map));
          } catch (err) {
            debugPrint('Error parsing community $key: $err');
          }
        });
      }
      return list;
    });
  }

  // ==========================================
  // INITIAL DATA SEEDING (Auto-runs if DB is fresh)
  // ==========================================
  Future<void> seedInitialDataIfEmpty() async {
    if (!isConnected) return;

    try {
      final usersCheck = await _usersRef
          .limitToFirst(1)
          .get()
          .timeout(const Duration(seconds: 4));
      if (!usersCheck.exists || usersCheck.value == null) {
        debugPrint('[RealtimeDatabaseService] Seeding mock users into Firebase...');
        for (var u in MockDataService.getMockUsers()) {
          await _usersRef.child(u.id).set(u.toJson());
        }
      }

      final pollsCheck = await _pollsRef
          .limitToFirst(1)
          .get()
          .timeout(const Duration(seconds: 5));
      if (!pollsCheck.exists || pollsCheck.value == null) {
        debugPrint('[RealtimeDatabaseService] Seeding initial data into Firebase...');

        // 1. Seed Communities
        for (var c in MockDataService.getMockCommunities()) {
          await _communitiesRef.child(c.id).set(c.toJson());
        }

        // 2. Seed Polls
        for (var p in MockDataService.getMockPolls()) {
          await _pollsRef.child(p.id).set(p.toJson());
        }

        // 3. Seed Comments
        for (var comm in MockDataService.getMockComments()) {
          await _commentsRef.child(comm.pollId).child(comm.id).set(comm.toJson());
        }

        // 4. Seed Decisions
        for (var d in MockDataService.getMockDecisions()) {
          await _decisionsRef.child(d.id).set(d.toJson());
        }

        // 5. Seed Notifications
        for (var n in MockDataService.getMockNotifications()) {
          await _notificationsRef.child(n.id).set(n.toJson());
        }

        debugPrint('[RealtimeDatabaseService] Database seeded successfully!');
      }
    } catch (e) {
      debugPrint('[RealtimeDatabaseService] Error during data seeding: $e');
    }
  }
}
