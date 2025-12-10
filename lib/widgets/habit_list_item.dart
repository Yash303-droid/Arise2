import 'package:flutter/material.dart';

class HabitListItem extends StatefulWidget {
  final Map<String, dynamic> habit;
  final ValueChanged<bool?> onChanged;

  const HabitListItem({
    super.key,
    required this.habit,
    required this.onChanged,
  });

  @override
  State<HabitListItem> createState() => _HabitListItemState();
}

class _HabitListItemState extends State<HabitListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      final isCurrentlyCompleted = widget.habit['completed'] ?? false;
      widget.onChanged(!isCurrentlyCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.habit['completed'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(widget.habit['title']),
        trailing: ScaleTransition(
          scale: _scaleAnimation,
          child: ElevatedButton(
            onPressed: _handleTap,
            child: Text(isCompleted ? 'Completed' : 'Done'),
          ),
        ),
      ),
    );
  }
}