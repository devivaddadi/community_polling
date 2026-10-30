import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/poll_model.dart';
import '../models/vote_model.dart';
import '../services/mock_data_service.dart';
import '../services/realtime_database_service.dart';

class PollProvider extends ChangeNotifier {
  List<PollModel> _polls = MockDataService.getMockPolls();
  final List<VoteModel> _submittedVotes = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'active', 'closed'
  StreamSubscription<List<PollModel>>? _pollsSub;

  List<PollModel> get polls => _polls;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  List<PollModel> get activePolls => _polls.where((p) => p.isActive).toList();
  List<PollModel> get closedPolls => _polls.where((p) => p.isClosed).toList();

  int get totalPollsCount => _polls.length;
  int get activePollsCount => _polls.where((p) => p.isActive).length;
  int get totalVotesCount {
    final liveTotal = _polls.fold<int>(0, (sum, p) => sum + p.totalVotes);
    return liveTotal > 842 ? liveTotal : 842;
  }

  PollProvider() {
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      _pollsSub = rtdb.getPollsStream().listen((firebasePolls) {
        if (firebasePolls.isNotEmpty) {
          _polls = firebasePolls;
          notifyListeners();
        }
      });
    }
  }

  /// Re-sync with Firebase once connected
  void connectFirebase() {
    _pollsSub?.cancel();
    _initFirebaseListener();
  }

  List<PollModel> get filteredPolls {
    return _polls.where((poll) {
      // Category filter
      if (_selectedCategory != 'All' &&
          poll.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // Status filter
      if (_filterStatus == 'active' && !poll.isActive) return false;
      if (_filterStatus == 'closed' && poll.isActive) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchQuestion = poll.question.toLowerCase().contains(query);
        final matchDesc = poll.description.toLowerCase().contains(query);
        final matchCategory = poll.category.toLowerCase().contains(query);
        return matchQuestion || matchDesc || matchCategory;
      }

      return true;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  PollModel? getPollById(String id) {
    try {
      return _polls.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PollModel> getUserVotedPolls(String userId) {
    return _polls.where((p) => p.hasUserVoted(userId)).toList();
  }

  List<PollModel> getUserCreatedPolls(String userId) {
    return _polls.where((p) => p.creatorId == userId).toList();
  }

  VoteModel? getUserVoteForPoll(String pollId, String userId) {
    try {
      return _submittedVotes.firstWhere(
        (v) => v.pollId == pollId && v.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitVote({
    required String pollId,
    required String optionId,
    required String userId,
    String? customText,
    bool isAnonymous = false,
  }) async {
    final rtdb = RealtimeDatabaseService();

    // 1. If Firebase Realtime Database is connected, submit via RTDB
    if (rtdb.isConnected) {
      final success = await rtdb.submitVote(
        pollId: pollId,
        optionId: optionId,
        userId: userId,
        customText: customText,
        isAnonymous: isAnonymous,
      );

      if (success) {
        _submittedVotes.add(
          VoteModel(
            id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
            pollId: pollId,
            userId: userId,
            optionId: optionId,
            customText: customText,
            timestamp: DateTime.now(),
            isAnonymous: isAnonymous,
          ),
        );
      }
      return success;
    }

    // 2. Fallback in-memory behavior
    final pollIndex = _polls.indexWhere((p) => p.id == pollId);
    if (pollIndex == -1) return false;

    final poll = _polls[pollIndex];

    // Check if user already voted
    if (poll.hasUserVoted(userId)) {
      return false;
    }

    final newVoters = List<String>.from(poll.voterUserIds)..add(userId);
    final newTotalVotes = poll.totalVotes + 1;

    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        final newVoteCount = opt.voteCount + 1;
        return opt.copyWith(
          voteCount: newVoteCount,
          percentage: (newVoteCount / newTotalVotes) * 100,
        );
      } else {
        return opt.copyWith(
          percentage: (opt.voteCount / newTotalVotes) * 100,
        );
      }
    }).toList();

    for (var opt in updatedOptions) {
      opt.percentage = double.parse(opt.percentage.toStringAsFixed(1));
    }

    _polls[pollIndex] = poll.copyWith(
      totalVotes: newTotalVotes,
      voterUserIds: newVoters,
      options: updatedOptions,
    );

    _submittedVotes.add(
      VoteModel(
        id: const Uuid().v4(),
        pollId: pollId,
        userId: userId,
        optionId: optionId,
        customText: customText,
        timestamp: DateTime.now(),
        isAnonymous: isAnonymous,
      ),
    );

    notifyListeners();
    return true;
  }

  Future<PollModel> createPoll({
    required String communityId,
    required String creatorId,
    required String creatorName,
    required String creatorAvatar,
    required String question,
    String description = '',
    required String category,
    required List<String> optionTexts,
    PollType pollType = PollType.public,
    required DateTime endsAt,
    bool allowCustomOption = false,
  }) async {
    final pollId = const Uuid().v4();
    final options = optionTexts.asMap().entries.map((entry) {
      return PollOption(
        id: '${pollId}_opt_${entry.key}',
        text: entry.value,
        voteCount: 0,
        percentage: 0.0,
      );
    }).toList();

    final newPoll = PollModel(
      id: pollId,
      communityId: communityId,
      creatorId: creatorId,
      creatorName: creatorName,
      creatorAvatar: creatorAvatar,
      question: question,
      description: description,
      category: category,
      options: options,
      pollType: pollType,
      createdAt: DateTime.now(),
      endsAt: endsAt,
      totalVotes: 0,
      status: PollStatus.active,
      voterUserIds: [],
      allowCustomOption: allowCustomOption,
    );

    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.createPoll(newPoll);
    }

    _polls.insert(0, newPoll);
    notifyListeners();
    return newPoll;
  }

  void closePoll(String pollId) {
    final index = _polls.indexWhere((p) => p.id == pollId);
    if (index != -1) {
      _polls[index] = _polls[index].copyWith(status: PollStatus.closed);
      final rtdb = RealtimeDatabaseService();
      if (rtdb.isConnected) {
        rtdb.createPoll(_polls[index]);
      }
      notifyListeners();
    }
  }

  Future<void> deletePoll(String pollId) async {
    _polls.removeWhere((p) => p.id == pollId);
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      await rtdb.deletePoll(pollId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pollsSub?.cancel();
    super.dispose();
  }
}
