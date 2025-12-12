class StreakInfo {
  final int appStreak;
  final int appLongestStreak;
  final List<HabitStreak> habitStreaks;

  StreakInfo({
    required this.appStreak,
    required this.appLongestStreak,
    required this.habitStreaks,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    final user = json['user'] as Map<String, dynamic>?;
    final userStreak = json['user_streak'] as Map<String, dynamic>?;
    return StreakInfo(
      appStreak: parseInt(user?['current_streak'] ?? userStreak?['current_streak'] ?? json['app_streak']),
      appLongestStreak: parseInt(user?['longest_streak'] ?? userStreak?['longest_streak'] ?? json['app_longest_streak']),
      habitStreaks: ((json['habits'] ?? json['habit_streaks']) as List<dynamic>?)
              ?.map((e) => HabitStreak.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class HabitStreak {
  final int habitId;
  final String habitName;
  final int currentStreak;
  final int longestStreak;

  HabitStreak({
    required this.habitId,
    required this.habitName,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory HabitStreak.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return HabitStreak(
      habitId: parseInt(json['habit_id']),
      habitName: json['name'] ?? json['habit_name'] ?? 'Unknown',
      currentStreak: parseInt(json['streak'] ?? json['current_streak'] ?? json['habit_streak']),
      longestStreak: parseInt(json['longest_streak'] ?? json['habit_longest_streak']),
    );
  }
}