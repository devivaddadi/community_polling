import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import '../services/realtime_database_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<UserModel>>? _usersSub;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final List<UserModel> _allUsers = MockDataService.getMockUsers();
  List<UserModel> get allDemoUsers => _allUsers;

  AuthProvider() {
    // Default to Priya Patel (Admin from the reference design)
    _currentUser = _allUsers.firstWhere(
      (u) => u.id == 'u_priya',
      orElse: () => _allUsers.first,
    );
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      _usersSub = rtdb.getUsersStream().listen((firebaseUsers) {
        if (firebaseUsers.isNotEmpty) {
          for (final fu in firebaseUsers) {
            final idx = _allUsers.indexWhere((u) => u.id == fu.id);
            if (idx >= 0) {
              _allUsers[idx] = fu;
            } else {
              _allUsers.add(fu);
            }
          }
          if (_currentUser != null) {
            final updatedIdx = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
            if (updatedIdx >= 0) {
              _currentUser = _allUsers[updatedIdx];
            }
          }
          notifyListeners();
        }
      });
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final rtdb = RealtimeDatabaseService();
    UserModel? user;

    if (rtdb.isConnected) {
      user = await rtdb.getUserByEmail(email);
    }

    user ??= _allUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => UserModel(
        id: const Uuid().v4(),
        name: email.split('@').first,
        email: email,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        role: UserRole.member,
        communityId: 'c1',
        joinedAt: DateTime.now(),
      ),
    );

    final idx = _allUsers.indexWhere((u) => u.id == user!.id);
    if (idx < 0) {
      _allUsers.add(user);
      if (rtdb.isConnected) {
        await rtdb.saveUser(user, password: password);
      }
    }

    _currentUser = user;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    UserRole role = UserRole.member,
    String communityId = 'c1',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = UserModel(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 5)}',
        name: name,
        email: email,
        phone: phone,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        role: role,
        communityId: communityId,
        joinedAt: DateTime.now(),
      );

      // Save permanently to Firebase Realtime Database
      final rtdb = RealtimeDatabaseService();
      if (rtdb.isConnected) {
        await rtdb.saveUser(newUser, password: password);
      }

      final idx = _allUsers.indexWhere((u) => u.id == newUser.id);
      if (idx >= 0) {
        _allUsers[idx] = newUser;
      } else {
        _allUsers.add(newUser);
      }

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration error: $e';
      notifyListeners();
      return false;
    }
  }

  void switchUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void toggleAdminRole() {
    if (_currentUser == null) return;
    final newRole = _currentUser!.isAdmin ? UserRole.member : UserRole.admin;
    _currentUser = _currentUser!.copyWith(role: newRole);
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) {
      _allUsers[idx] = _currentUser!;
    }
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      rtdb.saveUser(_currentUser!);
    }
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? avatarUrl}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) {
      _allUsers[idx] = _currentUser!;
    }
    final rtdb = RealtimeDatabaseService();
    if (rtdb.isConnected) {
      rtdb.saveUser(_currentUser!);
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }
}
