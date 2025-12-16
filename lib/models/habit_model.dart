class Habit {
  final int id;
  final int userId;
  final String name;
  final String type; // 'good' or 'bad'
  final String nature; // 'mental', 'physical', etc.
  final int xpValue;
  final String coverPhoto;
  final bool completed;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.nature,
    required this.xpValue,
    required this.coverPhoto,
    this.completed = false,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? 'Unknown Habit',
      type: json['habit_type'] ?? 'good',
      nature: json['habit_nature'] ?? 'mental',
      xpValue: json['xp_value'] ?? 0,
      coverPhoto: json['cover_photo'] ?? '',
      completed: json['done_today'] ?? false,
    );
  }

  bool get doneToday => completed;

  Habit copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? nature,
    int? xpValue,
    String? coverPhoto,
    bool? completed,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      nature: nature ?? this.nature,
      xpValue: xpValue ?? this.xpValue,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      completed: completed ?? this.completed,
    );
  }
}