import 'dart:ui';

import 'package:arise2/screens/achievements_screen.dart';
import 'package:arise2/screens/dashboard_screen.dart';
import 'package:arise2/screens/habits_screen.dart';
import 'package:arise2/view_models/auth_viewmodel.dart';
import 'package:arise2/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:arise2/widgets/add_habit_form.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<HabitsScreenState> _habitsScreenKey =
      GlobalKey<HabitsScreenState>();
  int _selectedIndex = 1; // Dashboard is the default tab

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HabitsScreen(key: _habitsScreenKey),
      const DashboardScreen(), // This is our Dashboard
      AchievementsScreen(),
    ];
  }

  static const List<String> _widgetTitles = <String>[
    'Habits',
    'Arise', // Dashboard Title
    'Achievements',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAddHabitDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Text('Create New Habit',
                style: TextStyle(color: Colors.white)),
            content: AddHabitForm(
              onAddHabit: _habitsScreenKey.currentState!.addHabit,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        centerTitle: true,
        backgroundColor: (_selectedIndex == 0 || _selectedIndex == 1)
            ? Colors.black.withOpacity(0.5)
            : null,
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                Provider.of<AuthViewModel>(context, listen: false).logout();
              },
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddHabitDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black.withOpacity(0.5),
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}