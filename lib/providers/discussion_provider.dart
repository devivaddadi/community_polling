import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';
import '../services/mock_data_service.dart';
import '../services/realtime_database_service.dart';

class DiscussionProvider extends ChangeNotifier {
  final List<CommentModel> _comments = MockDataService.getMockComments();
  final Map<String, StreamSubscription<List<CommentModel>>> _pollCommentSubs = {};

  List<CommentModel> get comments => _comments;

  List<CommentModel> getCommentsForPoll(String pollId) {
    _listenToPollComments(pollId);
    return _comments.where((c) => c.pollId == pollId).toList();
  }

  void _listenToPollComments(String pollId) {
    if (_pollCommentSubs.containsKey(pollId)) return;

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      _pollCommentSubs[pollId] = rtdb.getCommentsStream(pollId).listen((firebaseComments) {
        if (firebaseComments.isNotEmpty) {
          // Merge / update comments for this poll
          _comments.removeWhere((c) => c.pollId == pollId);
          _comments.addAll(firebaseComments);
          notifyListeners();
        }
      });
    }
  }

  List<CommentModel> getUserComments(String userId) {
    return _comments.where((c) => c.userId == userId).toList();
  }

  Future<void> addComment({
    required String pollId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String text,
  }) async {
    final newComment = CommentModel(
      id: const Uuid().v4(),
      pollId: pollId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      timestamp: DateTime.now(),
      likesCount: 0,
      likedByUserIds: [],
      replies: [],
    );

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.addComment(newComment);
    }

    _comments.add(newComment);
    notifyListeners();
  }

  Future<void> addReply({
    required String commentId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String text,
  }) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final newReply = CommentReply(
      id: const Uuid().v4(),
      commentId: commentId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      timestamp: DateTime.now(),
      likesCount: 0,
      likedByUserIds: [],
    );

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.addReply(
        pollId: comment.pollId,
        commentId: commentId,
        reply: newReply,
      );
    }

    comment.replies.add(newReply);
    notifyListeners();
  }

  Future<void> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final liked = comment.likedByUserIds.contains(userId);

    if (liked) {
      comment.likedByUserIds.remove(userId);
      comment.likesCount = (comment.likesCount - 1).clamp(0, 999999);
    } else {
      comment.likedByUserIds.add(userId);
      comment.likesCount += 1;
    }

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.toggleCommentLike(
        pollId: comment.pollId,
        commentId: commentId,
        userId: userId,
      );
    }

    notifyListeners();
  }

  Future<void> toggleReplyLike({
    required String commentId,
    required String replyId,
    required String userId,
  }) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final replyIndex = comment.replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final reply = comment.replies[replyIndex];
    final liked = reply.likedByUserIds.contains(userId);

    if (liked) {
      reply.likedByUserIds.remove(userId);
      reply.likesCount = (reply.likesCount - 1).clamp(0, 999999);
    } else {
      reply.likedByUserIds.add(userId);
      reply.likesCount += 1;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    for (var sub in _pollCommentSubs.values) {
      sub.cancel();
    }
    _pollCommentSubs.clear();
    super.dispose();
  }
}
