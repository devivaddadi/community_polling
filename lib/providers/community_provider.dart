import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/community_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class CommunityProvider extends ChangeNotifier {
  final List<CommunityModel> _communities = MockDataService.getMockCommunities();
  late CommunityModel _currentCommunity;
  final List<UserModel> _members = MockDataService.getMockUsers();
  String _searchQuery = '';
  String _memberFilter = 'all'; // 'all', 'admin', 'member'

  List<CommunityModel> get communities => _communities;
  CommunityModel get currentCommunity => _currentCommunity;
  String get memberFilter => _memberFilter;
  String get searchQuery => _searchQuery;

  CommunityProvider() {
    _currentCommunity = _communities.first;
  }

  void selectCommunity(String communityId) {
    final comm = _communities.firstWhere(
      (c) => c.id == communityId,
      orElse: () => _communities.first,
    );
    _currentCommunity = comm;
    notifyListeners();
  }

  List<UserModel> get members => _members.where((m) => m.communityId == _currentCommunity.id).toList();

  int get totalMembersCount => 128; // matching design metric
  int get adminMembersCount => 3;
  int get regularMembersCount => 125;

  List<UserModel> get filteredMembers {
    return _members.where((member) {
      if (member.communityId != _currentCommunity.id) return false;

      // Filter by role tab
      if (_memberFilter == 'admin' && !member.isAdmin) return false;
      if (_memberFilter == 'member' && member.isAdmin) return false;

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = member.name.toLowerCase().contains(query);
        final emailMatch = member.email.toLowerCase().contains(query);
        return nameMatch || emailMatch;
      }

      return true;
    }).toList();
  }

  void setMemberFilter(String filter) {
    _memberFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void inviteMember({required String name, required String email, UserRole role = UserRole.member}) {
    final newUser = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      role: role,
      communityId: _currentCommunity.id,
      joinedAt: DateTime.now(),
    );
    _members.add(newUser);
    notifyListeners();
  }

  void updateMemberRole(String userId, UserRole newRole) {
    final index = _members.indexWhere((m) => m.id == userId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(role: newRole);
      notifyListeners();
    }
  }

  void removeMember(String userId) {
    _members.removeWhere((m) => m.id == userId);
    notifyListeners();
  }
}
