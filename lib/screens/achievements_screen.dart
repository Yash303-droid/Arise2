import 'dart:ui';
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ACHIEVEMENTS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF121212), Color(0xFF1E1E2C)],
              ),
            ),
          ),
          // Content
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final bool isLocked = achievement['isLocked'];
              final Color baseColor = isLocked ? Colors.grey : Colors.amber;

              return Container(
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.white.withOpacity(0.03)
                      : baseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isLocked
                        ? Colors.white.withOpacity(0.1)
                        : baseColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked
                            ? Colors.black26
                            : baseColor.withOpacity(0.2),
                        boxShadow: isLocked
                            ? []
                            : [
                                BoxShadow(
                                  color: baseColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : achievement['icon'],
                        color: isLocked ? Colors.white24 : baseColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      achievement['title'],
                      style: TextStyle(
                        color: isLocked ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        achievement['description'],
                        style: TextStyle(
                          color: isLocked ? Colors.white24 : Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
