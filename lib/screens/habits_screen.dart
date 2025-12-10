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
        final activeHabits = gameVM.habits.where((h) => !h.completed).toList();

        if (activeHabits.isEmpty) {
          return const Center(child: Text("No active habits. Add one!"));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
          itemCount: activeHabits.length,
          itemBuilder: (context, index) {
            final habit = activeHabits[index];
            return Dismissible(
              key: ValueKey(habit.id),
              direction: DismissDirection.startToEnd,
              movementDuration: const Duration(milliseconds: 500),
              resizeDuration: const Duration(milliseconds: 500),
              // Swipe Left-to-Right (Start-to-End) -> Done
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text('Swipe to Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              onDismissed: (direction) {
                // Done Logic
                final gameVM = Provider.of<GameViewModel>(context, listen: false);
                gameVM.markHabitDone(habit.id).then((resp) {
                  if (!mounted) return;
                  if (resp != null) {
                    _confettiController.play();
                    final msg = resp['message'] as String? ?? 'Habit completed';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to connect to server'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: HabitListItem(
              habit: habit,
            ),
            );
          },
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


class HabitListItem extends StatelessWidget {
  const HabitListItem({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = habit.completed;
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(habit.type == 'good' ? Icons.check_circle_outline : Icons.remove_circle_outline, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: TextStyle(
                      color: isCompleted ? Colors.white54 : Colors.white,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              habit.nature.toUpperCase(), // Display nature as description/tag
              style: TextStyle(
                color: isCompleted ? Colors.white38 : Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '+${habit.xpValue} XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}