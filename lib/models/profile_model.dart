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
      id: int.tryParse(json['id']?.toString() ?? json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? json['name']?.toString() ?? 'Hero',
      email: json['email']?.toString() ?? '',
      level: int.tryParse(json['level']?.toString() ?? json['lvl']?.toString() ?? '1') ?? 1,
      xp: int.tryParse(json['xp']?.toString() ?? json['experience']?.toString() ?? '0') ?? 0,
      gold: int.tryParse(json['gold']?.toString() ?? json['coins']?.toString() ?? '0') ?? 0,
      health: int.tryParse(json['health']?.toString() ?? '0') ?? 0,
      mana: int.tryParse(json['mana']?.toString() ?? '0') ?? 0,
      streak: int.tryParse(json['streak']?.toString() ?? '0') ?? 0,
      longestStreak: int.tryParse(json['longest_streak']?.toString() ?? json['longestStreak']?.toString() ?? '0') ?? 0,
      rank: json['rank']?.toString() ?? 'Unranked',
    );
  }

  get levelName => null;

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