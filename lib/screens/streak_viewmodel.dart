
import 'package:arise2/screens/streak_model.dart';
import 'package:arise2/services/api_client.dart';
import 'package:flutter/material.dart';

class StreakViewModel extends ChangeNotifier {
  final ApiClient apiClient;

  StreakViewModel({required this.apiClient});

  StreakInfo? _streakInfo;
  StreakInfo? get streakInfo => _streakInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchStreakData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiClient.get('/auth/streaks', requireAuth: true);

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Streak Data: $response');
        _streakInfo = StreakInfo.fromJson(response);
      }
    } catch (e) {
      _error = "Failed to load streaks: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}