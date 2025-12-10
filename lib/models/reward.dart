class Reward {
  final int id;
  final String name;
  final int cost;

  Reward({required this.id, required this.name, required this.cost});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Reward',
      cost: json['cost'] ?? 0,
    );
  }
}