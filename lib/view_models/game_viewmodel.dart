import 'package:flutter/material.dart';
import 'package:arise2/services/api_client.dart';
import 'package:arise2/models/habit_model.dart';
import 'package:arise2/models/reward.dart';
import 'package:arise2/models/profile_model.dart';

class GameViewModel extends ChangeNotifier {
  final ApiClient apiClient;

  GameViewModel({required this.apiClient});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Dashboard Data
  int _level = 1;
  String _levelName = 'Beginner';
  int _currentXp = 0;
  int _maxXp = 100; // Assuming 100 XP per level for now
  
  int get level => _level;
  String get levelName => _levelName;
  int get currentXp => _currentXp;
  int get maxXp => _maxXp;

  // Rewards
  List<Reward> _rewards = [];
  List<Reward> get rewards => _rewards;

  // Habits
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  // Profile
  Profile? _profile;
  Profile? get profile => _profile;
  String? _lastMessage;
  String? get lastMessage => _lastMessage;

  // Analytics & Projections
  int get potentialDailyXp => _habits.fold(0, (sum, habit) => sum + habit.xpValue);

  Map<String, int> get habitsByNature {
    final map = <String, int>{};
    for (final habit in _habits) {
      map[habit.nature] = (map[habit.nature] ?? 0) + 1;
    }
    return map;
  }

  double get dailyCompletionRate {
    if (_habits.isEmpty) return 0.0;
    return _habits.where((h) => h.doneToday).length / _habits.length;
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // 1. Fetch Profile (using /auth/me with token)
      // We fetch this first to ensure we have the user ID and latest stats from the server.
      try {
        final profileData = await apiClient.get('/auth/me', requireAuth: true);
        if (profileData is Map<String, dynamic>) {
          _profile = Profile.fromJson(profileData);
          _level = _profile?.level ?? 1;
          _currentXp = _profile?.xp ?? 0;
          _levelName = profileData['level_name']?.toString() ?? 'Beginner';
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }

      // Determine User ID: prefer the one from the fetched profile, fallback to storage
      int? userId = _profile?.id;
      if (userId == null) {
        final userIdStr = await apiClient.getUserId();
        if (userIdStr != null) userId = int.tryParse(userIdStr);
      }

      if (userId == null) return;
      
      // 2. Fetch Rewards
      final rewardsData = await apiClient.get('/rewards/', requireAuth: true);
      if (rewardsData is List) {
        _rewards = rewardsData.map((data) => Reward.fromJson(data as Map<String, dynamic>)).toList();
      }

      // 3. Fetch Habits
      try {
        final habitsData = await apiClient.get('/habits/', requireAuth: true);
        if (habitsData is List) {
          _habits = habitsData
              .map((data) => Habit.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('Error fetching habits: $e');
      }

    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHabit(String name, String type, String nature, int? xpValue) async {
    try {
      int? userId = _profile?.id;
      if (userId == null) {
        final userIdStr = await apiClient.getUserId();
        if (userIdStr != null) userId = int.tryParse(userIdStr);
      }
      if (userId == null) return;

      final payload = <String, dynamic>{
        "user_id": userId,
        "name": name,
        "habit_type": type, // "good" or "bad"
        "habit_nature": nature, // "mental", "physical", etc
      };

      if (xpValue != null) payload['xp_value'] = xpValue;

      final response = await apiClient.post('/habits/', payload, requireAuth: true);

      // If API returned the created habit, add it locally to avoid full reload
      if (response is Map<String, dynamic>) {
        try {
          final created = Habit.fromJson(response);
          // avoid duplicate
          if (!_habits.any((h) => h.id == created.id)) {
            _habits.insert(0, created);
            notifyListeners();
            return;
          }
        } catch (_) {
          // ignore parse error - fallback to reload
        }
      }

      // Fallback: refresh data after creation
      await loadDashboardData(silent: true);
    } catch (e) {
      print('Error creating habit: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> markHabitDone(int habitId) async {
    try {
      final response = await apiClient.post('/habits/$habitId/done', {
        "habit_id": habitId,
      }, requireAuth: true);

      // Update local state from response
      if (response is Map<String, dynamic>) {
        final respMap = response.cast<String, dynamic>();

        // Refresh data from server to ensure sync
        await loadDashboardData(silent: true);

        // expose server message for UI feedback
        if (respMap.containsKey('message')) {
          _lastMessage = respMap['message']?.toString();
        }

        
        notifyListeners();
        return respMap;
      }
    } catch (e) {
      print('Error marking habit done: $e');
    }
    return null;
  }

  Future<bool> deleteHabit(int habitId) async {
    try {
      final response = await apiClient.delete('/habits/$habitId', requireAuth: true);
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        _habits.removeWhere((h) => h.id == habitId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting habit: $e');
    }
    return false;
  }

  void clearLastMessage() {
    _lastMessage = null;
    notifyListeners();
  }

  Future<void> buyReward(int rewardId) async {
    int? userId = _profile?.id;
    if (userId == null) {
      final userIdStr = await apiClient.getUserId();
      if (userIdStr != null) userId = int.tryParse(userIdStr);
    }
    if (userId == null) return;

    final response = await apiClient.post('/rewards/buy', {
      "user_id": userId,
      "reward_id": rewardId
    });

    if (response != null && response is Map<String, dynamic>) {
      // Refresh profile (Gold/XP) and Rewards list
      await loadDashboardData();
    }
  }
}
