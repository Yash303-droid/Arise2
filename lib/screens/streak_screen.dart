import 'dart:ui';

import 'package:arise2/screens/streak_model.dart';
import 'package:arise2/screens/streak_viewmodel.dart';
import 'package:arise2/view_models/game_viewmodel.dart';
import 'package:arise2/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StreakViewModel>(context, listen: false).fetchStreakData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Streak Flame', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Consumer2<StreakViewModel, GameViewModel>(
            builder: (context, viewModel, gameVM, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.red)));
              }

              final info = viewModel.streakInfo;
              if (info == null) {
                return const Center(child: Text("No streak data available", style: TextStyle(color: Colors.white)));
              }

              int maxStreak = 0;
              if (info.habitStreaks.isNotEmpty) {
                maxStreak = info.habitStreaks
                    .map((h) => h.currentStreak)
                    .reduce((a, b) => a > b ? a : b);
              }

              HabitStreak? bestHabit;
              if (info.habitStreaks.isNotEmpty) {
                bestHabit = info.habitStreaks.reduce((curr, next) =>
                    curr.longestStreak > next.longestStreak ? curr : next);
              }
              
              bool isBadHabit = false;
              if (bestHabit != null) {
                try {
                  final habitDef = gameVM.habits.firstWhere((h) => h.id == bestHabit!.habitId);
                  isBadHabit = habitDef.type == 'bad';
                } catch (_) {}
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    // App Streak Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department, size: 48, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            "$maxStreak Day Streak",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (bestHabit != null && bestHabit.longestStreak > 0) ...[
                      const SizedBox(height: 24),
                      _buildBestHabitCard(bestHabit, isBadHabit),
                    ],
                    if (info.habitStreaks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildStreakGraph(info.habitStreaks),
                    ],
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Habit Streaks", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    if (info.habitStreaks.isEmpty)
                      const Text("No active habit streaks found.", style: TextStyle(color: Colors.white54))
                    else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: info.habitStreaks.length,
                      itemBuilder: (context, index) {
                        final habit = info.habitStreaks[index];
                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.repeat, color: Colors.lightBlueAccent),
                            title: Text(habit.habitName, style: const TextStyle(color: Colors.white)),
                            subtitle: Text("Longest: ${habit.longestStreak}", style: const TextStyle(color: Colors.white54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${habit.currentStreak}", style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)), // Fix: Removed const from TextStyle
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildBestHabitCard(HabitStreak habit, bool isBadHabit) {
    final colorTheme = isBadHabit ? Colors.redAccent : Colors.amber;
    final gradientColors = isBadHabit
        ? [Colors.redAccent.withOpacity(0.2), Colors.deepPurple.withOpacity(0.2)]
        : [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.2)];
    final icon = isBadHabit ? Icons.gpp_bad : Icons.emoji_events;
    final title = isBadHabit ? "we need to stop" : "Longest Streak Champion";
    final subtitle = isBadHabit ? "${habit.longestStreak} days of resistance" : "${habit.longestStreak} days personal best";
    final suggestion = isBadHabit ? "You can do better" : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorTheme.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorTheme.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorTheme, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: colorTheme, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.habitName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (suggestion != null)
                  Text(
                    suggestion,
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakGraph(List<HabitStreak> habits) {
    final sorted = List<HabitStreak>.from(habits)..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    final top5 = sorted.take(5).toList();

    if (top5.isEmpty || top5.every((h) => h.currentStreak == 0)) return const SizedBox.shrink();

    final maxVal = top5.first.currentStreak;
    final double maxH = 100.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Active Streaks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: top5.map((h) {
                final hFactor = maxVal == 0 ? 0.0 : h.currentStreak / maxVal;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${h.currentStreak}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Container(
                          width: 12,
                          height: (maxH * hFactor + 4) * value,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        h.habitName,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}