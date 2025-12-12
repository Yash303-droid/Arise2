import 'dart:ui';

import 'package:arise2/screens/streak_viewmodel.dart';
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
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Consumer<StreakViewModel>(
            builder: (context, viewModel, child) {
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

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    // App Streak Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department, size: 60, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text(
                            "${info.appStreak} Day Streak",
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Longest: ${info.appLongestStreak} days",
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Habit Streaks", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
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
                                Text("${habit.currentStreak}", style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
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
}