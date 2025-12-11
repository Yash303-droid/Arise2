class Reward {
  final int id;
  final String name;
  final int cost;

  Reward({required this.id, required this.name, required this.cost});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unknown Reward',
      cost: int.tryParse(json['cost']?.toString() ?? '0') ?? 0,
    );
  }
}