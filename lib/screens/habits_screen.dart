import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arise2/view_models/game_viewmodel.dart';
import 'package:arise2/models/habit_model.dart';
import 'package:confetti/confetti.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => HabitsScreenState();
}
class HabitsScreenState extends State<HabitsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  // This method is called by the parent MainScreen via GlobalKey
  Future<void> addHabit(String title, int? xp, bool isGood, String nature) async {
    final type = isGood ? 'good' : 'bad';
    await Provider.of<GameViewModel>(context, listen: false)
        .createHabit(title, type, nature, xp);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<GameViewModel>(
      builder: (context, gameVM, child) {
        if (gameVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Only show habits that are not already completed
        final activeHabits = gameVM.habits.where((habit) => !habit.doneToday).toList();

        if (activeHabits.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => gameVM.loadDashboardData(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(child: Text("No active habits. Add one!")),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => gameVM.loadDashboardData(silent: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
            itemCount: activeHabits.length,
            itemBuilder: (context, index) {
            final habit = activeHabits[index];
            return Dismissible(
              key: ValueKey(habit.id),
              direction: DismissDirection.horizontal,
              movementDuration: const Duration(milliseconds: 500),
              resizeDuration: const Duration(milliseconds: 500),
              // Swipe Left-to-Right (Start-to-End) -> Done
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text('Complete!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                  ],
                ),
              ),
              // Swipe Right-to-Left (End-to-Start) -> Delete
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                    SizedBox(width: 12),
                    Icon(Icons.delete_outline, color: Colors.white, size: 32),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1E1E2C),
                        title: const Text("Delete Habit?", style: TextStyle(color: Colors.white)),
                        content: const Text("Are you sure you want to delete this habit?", style: TextStyle(color: Colors.white70)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      );
                    },
                  );
                }
                return true;
              },
              onDismissed: (direction) {
                final gameVM = Provider.of<GameViewModel>(context, listen: false);
                
                if (direction == DismissDirection.startToEnd) {
                  // Done Logic
                  gameVM.markHabitDone(habit.id).then((resp) {
                    if (!mounted) return;
                    if (resp != null) {
                      _confettiController.play();
                      final msg = resp['message'] as String? ?? 'Habit completed';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect to server'), backgroundColor: Colors.red));
                    }
                  });
                } else if (direction == DismissDirection.endToStart) {
                  // Delete Logic
                  gameVM.deleteHabit(habit.id).then((success) {
                    if (!mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit deleted successfully'), backgroundColor: Colors.red));
                    } else {
                      gameVM.loadDashboardData(silent: true); // Restore item if failed
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete habit'), backgroundColor: Colors.red));
                    }
                  });
                }
              },
              child: HabitListItem(
                habit: habit,
              ),
            );
          },
          ),
        );
      },
    ),
    Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
      ),
    ),
      ],
    );
  }
}


class HabitListItem extends StatefulWidget {
  const HabitListItem({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<HabitListItem> createState() => _HabitListItemState();
}

class _HabitListItemState extends State<HabitListItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.habit.doneToday;
    final Color baseColor = widget.habit.type == 'good' 
        ? const Color(0xFF00E5FF) 
        : const Color(0xFFFF5252);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A35),
            Color(0xFF1E1E2C),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Accent Line
            Positioned(
              left: 0, top: 0, bottom: 0, width: 4,
              child: Container(color: baseColor),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.habit.type == 'good' ? Icons.check_circle_outline : Icons.remove_circle_outline,
                          color: baseColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.habit.name,
                          style: TextStyle(
                            color: isCompleted ? Colors.white54 : Colors.white,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (widget.habit.type == 'bad' ? Colors.redAccent : Colors.amber).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (widget.habit.type == 'bad' ? Colors.redAccent : Colors.amber).withOpacity(0.3)),
                        ),
                        child: Text(
                          widget.habit.type == 'bad' ? '-${widget.habit.xpValue} XP' : '+${widget.habit.xpValue} XP',
                          style: TextStyle(
                            color: widget.habit.type == 'bad' ? Colors.redAccent : Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.habit.nature.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SlideTransition(
                        position: _animation,
                        child: Row(
                          children: [
                            Text(
                              'Swipe to complete',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 16),
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}