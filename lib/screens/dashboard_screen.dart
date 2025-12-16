import 'package:arise2/screens/streak_model.dart';
import 'package:arise2/screens/streak_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arise2/view_models/game_viewmodel.dart';
import 'package:arise2/viewmodels/auth_viewmodel.dart';
import 'package:arise2/screens/rewards_screen.dart';
import 'package:arise2/screens/streak_screen.dart';
import 'package:confetti/confetti.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onHabitsTap;
  const DashboardScreen({super.key, this.onHabitsTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;
  int? _previousLevel;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showLevelUpDialog(int newLevel) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 2),
            ),
            title: const Center(
              child: Text(
                "LEVEL UP!",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.keyboard_double_arrow_up, color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                Text(
                  "You are now Level $newLevel",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("AWESOME", style: TextStyle(color: Colors.amber, fontSize: 16)),
              ),
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.amber],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameViewModel, StreakViewModel>(
      builder: (context, gameVM, streakVM, child) {
        final bool isReloading = gameVM.isLoading || streakVM.isLoading;
        final bool hasData = gameVM.profile != null;

        if (!hasData) {
          return _buildSkeleton(context);
        }

        // Check for level up
        if (_previousLevel != null && gameVM.level > _previousLevel!) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLevelUpDialog(gameVM.level);
          });
        }
        _previousLevel = gameVM.level;

        final double xpProgress = (gameVM.maxXp > 0) 
            ? (gameVM.currentXp / gameVM.maxXp).clamp(0.0, 1.0) 
            : 0.0;

        final int activeHabitsCount = gameVM.habits.where((h) => !h.completed).length;
        final int completedHabitsCount = gameVM.habits.where((h) => h.completed).length;

        int maxStreak = 0;
        if (streakVM.streakInfo != null && streakVM.streakInfo!.habitStreaks.isNotEmpty) {
          maxStreak = streakVM.streakInfo!.habitStreaks
              .map((h) => h.currentStreak)
              .reduce((a, b) => a > b ? a : b);
        }

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isReloading)
                    const LinearProgressIndicator(minHeight: 2, color: Colors.amber, backgroundColor: Colors.transparent),
                  const SizedBox(height: 20),
                  // User Profile Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.2),
                          Colors.purpleAccent.withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Level ${gameVM.level}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                                  Text(
                                    '${gameVM.currentXp} XP',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),                  const SizedBox(height: 10),
                  // XP Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Colors.transparent,
                        color: Colors.amber,
                        minHeight: 12,
                      ),
                    ),
                  ),
                                    const SizedBox(height: 30),
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildStatCard(
                        'Active Habits',
                        '$activeHabitsCount',
                        Icons.check_circle_outline,
                        Colors.blue,
                        onTap: widget.onHabitsTap,
                      ),
                      _buildStatCard('Rank', gameVM.levelName, Icons.emoji_events, Colors.amber),
                      _buildStatCard('Health', '${gameVM.profile?.health ?? 0}', Icons.favorite, Colors.red),
                      _buildStatCard('Mana', '${gameVM.profile?.mana ?? 0}', Icons.flash_on, Colors.cyan),
                      _buildStatCard(
                        'Streak',
                        '$maxStreak',
                        Icons.whatshot,
                        Colors.orange,
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StreakScreen()));
                          if (context.mounted) {
                            Provider.of<GameViewModel>(context, listen: false).loadDashboardData();
                            Provider.of<StreakViewModel>(context, listen: false).fetchStreakData();
                          }
                        },
                      ),
                      _buildStatCard('Completed', '${streakVM.streakInfo?.appStreak ?? 0}', Icons.done_all, Colors.green),
                      _buildStatCard(
                        'Rewards',
                        '${gameVM.rewards.length}',
                        Icons.card_giftcard,
                        Colors.purple,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RewardsScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Card Skeleton
              Container(
                height: 112,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.1)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 24, width: 150, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 8),
                          Container(height: 18, width: 100, color: Colors.white.withOpacity(0.1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 16, width: 60, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 10),
              Container(height: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 30),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(6, (index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}