import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arise2/view_models/game_viewmodel.dart';
import 'package:arise2/viewmodels/auth_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, gameVM, child) {
        if (gameVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final double xpProgress = (gameVM.maxXp > 0) 
            ? (gameVM.currentXp / gameVM.maxXp).clamp(0.0, 1.0) 
            : 0.0;

        final int currentHealth = gameVM.profile?.health ?? 0;
        final double healthProgress = (currentHealth / 100.0).clamp(0.0, 1.0);

        final int activeHabitsCount = gameVM.habits.where((h) => !h.completed).length;
        final int completedHabitsCount = gameVM.habits.where((h) => h.completed).length;

        // Show server message (once) when a habit is completed
        if (gameVM.lastMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg = gameVM.lastMessage!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            gameVM.clearLastMessage();
          });
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // User Profile Card
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gameVM.profile?.username ?? 'Hero',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${gameVM.level}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          onPressed: () {
                            Provider.of<AuthViewModel>(context, listen: false).logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${gameVM.currentXp} / ${gameVM.maxXp} XP',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                // XP Bar
                LinearProgressIndicator(
                  value: xpProgress,
                  backgroundColor: Colors.white24,
                  color: Colors.amber,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Health: $currentHealth / 100',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                // Health Bar
                LinearProgressIndicator(
                  value: healthProgress,
                  backgroundColor: Colors.white24,
                  color: Colors.redAccent,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 30),
                // Stats Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard('Active Habits', '$activeHabitsCount', Icons.check_circle_outline, Colors.blue),
                      _buildStatCard('Rewards', '${gameVM.rewards.length}', Icons.card_giftcard, Colors.purple),
                      _buildStatCard('Completed', '$completedHabitsCount', Icons.done_all, Colors.green),
                      _buildStatCard('Health', '${gameVM.profile?.health ?? 0}', Icons.favorite, Colors.red),
                      _buildStatCard('Mana', '${gameVM.profile?.mana ?? 0}', Icons.flash_on, Colors.cyan),
                      _buildStatCard('Streak', '${gameVM.profile?.streak ?? 0}', Icons.whatshot, Colors.orange),
                      _buildStatCard('Rank', '${gameVM.profile?.rank ?? '-'}', Icons.emoji_events, Colors.amber),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}