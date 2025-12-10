import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arise2/view_models/game_viewmodel.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameVM = Provider.of<GameViewModel>(context);
    
    // Dynamic achievements based on real data
    final List<Map<String, dynamic>> achievements = [
      {
        'icon': Icons.flag,
        'title': 'First Steps',
        'description': 'Create your first habit.',
        'isLocked': gameVM.habits.isEmpty,
      },
      {
        'icon': Icons.star,
        'title': 'Level Up',
        'description': 'Reach Level 2.',
        'isLocked': gameVM.level < 2,
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Master',
        'description': 'Reach Level 5.',
        'isLocked': gameVM.level < 5,
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Legend',
        'description': 'Reach Level 10.',
        'isLocked': gameVM.level < 10,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool isLocked = achievement['isLocked'];
        final Color color = isLocked ? Colors.white38 : Colors.white;

        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              achievement['icon'],
              color: isLocked ? Colors.white38 : Colors.amber,
              size: 40,
            ),
            title: Text(
              achievement['title'],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              achievement['description'],
              style: TextStyle(color: color.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }
}