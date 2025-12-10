class Profile {
  final int id;
  final String username;
  final String email;
  final int level;
  final int xp;
  final int gold;
  final int health;
  final int mana;
  final int streak;
  final int longestStreak;
  final String rank;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    this.level = 1,
    this.xp = 0,
    this.gold = 0,
    this.health = 0,
    this.mana = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.rank = '',
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? json['user_id'] ?? 0,
      username: json['username'] ?? json['name'] ?? 'Hero',
      email: json['email'] ?? '',
      level: json['level'] ?? json['lvl'] ?? 1,
      xp: json['xp'] ?? json['experience'] ?? 0,
      gold: json['gold'] ?? json['coins'] ?? 0,
      health: json['health'] ?? 0,
      mana: json['mana'] ?? 0,
      streak: json['streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? json['longestStreak'] ?? 0,
      rank: json['rank'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'xp': xp,
      'gold': gold,
      'health': health,
      'mana': mana,
      'streak': streak,
      'longest_streak': longestStreak,
      'rank': rank,
    };
  }
}