import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' as material;
import 'package:arise2/screens/achievements_screen.dart';
import 'package:arise2/screens/dashboard_screen.dart';
import 'package:arise2/screens/habits_screen.dart';
import 'package:arise2/screens/streak_viewmodel.dart';
import 'package:arise2/view_models/auth_viewmodel.dart';
import 'package:arise2/viewmodels/auth_viewmodel.dart';
import 'package:arise2/view_models/game_viewmodel.dart';
import 'package:arise2/widgets/add_habit_form.dart';
import 'package:flutter/material.dart';
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
      const HabitsScreen(),
      DashboardScreen(
        onHabitsTap: () => _onItemTapped(0),
      ), // This is our Dashboard
      const AchievementsScreen(),
    ];
  }

  static const List<String> _widgetTitles = <String>[
    'Habits',
    'Arise', // Dashboard Title
    'Achievements',
  ];

  static const List<IconData> _widgetIcons = <IconData>[
    Icons.checklist_rounded,
    Icons.dashboard_rounded,
    Icons.emoji_events_rounded,
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Provider.of<GameViewModel>(context, listen: false).loadDashboardData();
      Provider.of<StreakViewModel>(context, listen: false).fetchStreakData();
    }
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
          child: material.AlertDialog(
            backgroundColor: material.Colors.white.withOpacity(0.1),
            shape: material.RoundedRectangleBorder(
              borderRadius: material.BorderRadius.circular(20),
              side: material.BorderSide(color: material.Colors.white.withOpacity(0.2)),
            ),
            title: const material.Text('Create New Habit',
                style: material.TextStyle(color: material.Colors.white)),
            content: AddHabitForm(
              onAddHabit: (title, xp, isGood, nature) async {
                final type = isGood ? 'good' : 'bad';
                await Provider.of<GameViewModel>(context, listen: false)
                    .createHabit(title, type, nature, xp);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  material.Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to extend behind the bottom navigation bar
      backgroundColor: material.Theme.of(context).scaffoldBackgroundColor,
      appBar: material.AppBar(
        title: material.Text(
          _widgetTitles.elementAt(_selectedIndex).toUpperCase(),
          style: const material.TextStyle(
            fontWeight: material.FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: material.Colors.transparent,
        flexibleSpace: material.Container(
          decoration: material.BoxDecoration(
            gradient: material.LinearGradient(
              begin: material.Alignment.topCenter,
              end: material.Alignment.bottomCenter,
              colors: [
                material.Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                material.Colors.transparent,
              ],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          if (_selectedIndex == 1) // Only show logout button on Dashboard
            material.IconButton(
              icon: const material.Icon(material.Icons.logout, color: material.Colors.redAccent),
              onPressed: () {
                Provider.of<AuthViewModel>(context, listen: false).logout();
              },
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? material.FloatingActionButton.extended(
              onPressed: _openAddHabitDialog,
              backgroundColor: material.Colors.teal,
              icon: const material.Icon(material.Icons.add, color: material.Colors.white),
              label: const material.Text('Add Habit', style: material.TextStyle(color: material.Colors.white)),
            )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        items: _widgetIcons,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return material.IconButton(
      icon: material.Icon(
        _widgetIcons[index],
        color: material.Colors.white54,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

class CurvedNavigationBar extends StatefulWidget {
  final List<IconData> items;
  final int currentIndex;
  final Function(int) onTap;

  const CurvedNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CurvedNavigationBar> createState() => _CurvedNavigationBarState();
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _particleController;
  double _startPosition = 0.5;
  double _endPosition = 0.5;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Initialize position based on current index
    _startPosition = _calculatePosition(widget.currentIndex);
    _endPosition = _startPosition;
    _animation = ConstantTween<double>(_startPosition).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.15), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particleController.addListener(_updateParticles);

    for (int i = 0; i < 20; i++) {
      _particles.add(_resetParticle(true));
    }
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _startPosition = _calculatePosition(oldWidget.currentIndex);
      _endPosition = _calculatePosition(widget.currentIndex);
      
      _animation = Tween<double>(
        begin: _startPosition,
        end: _endPosition,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
      ));
      
      _controller.forward(from: 0.0);
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y -= particle.speed;
      particle.x += sin(particle.angle) * 0.5;
      particle.angle += 0.1;
      particle.opacity -= 0.01;

      if (particle.opacity <= 0) {
        final newP = _resetParticle(false);
        particle.x = newP.x;
        particle.y = newP.y;
        particle.size = newP.size;
        particle.opacity = newP.opacity;
        particle.speed = newP.speed;
        particle.angle = newP.angle;
      }
    }
  }

  _Particle _resetParticle(bool randomY) {
    return _Particle(
      x: (_random.nextDouble() * 50) - 25,
      y: randomY ? (_random.nextDouble() * 50) - 25 : 25,
      size: _random.nextDouble() * 3 + 1,
      opacity: _random.nextDouble() * 0.5 + 0.2,
      speed: _random.nextDouble() * 0.5 + 0.2,
      angle: _random.nextDouble() * 2 * pi,
    );
  }

  double _calculatePosition(int index) {
    // Calculate normalized position (0.0 to 1.0) for the center of each item
    // For 3 items: 1/6, 3/6, 5/6
    return (index * 2 + 1) / (widget.items.length * 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double barHeight = 80.0;

    return SizedBox(
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: material.Size(size.width, barHeight),
                painter: NavBarPainter(
                  position: _animation.value,
                  color: const material.Color(0xFF1E1E2C),
                ),
              );
            },
          ),
          // Particles
          AnimatedBuilder(
            animation: material.Listenable.merge([_controller, _particleController]),
            builder: (context, child) {
              return Positioned(
                left: (size.width * _animation.value) - 28,
                top: -35,
                child: CustomPaint(
                  size: const material.Size(56, 56),
                  painter: _ParticlePainter(_particles),
                ),
              );
            },
          ),
          // Floating Action Button (The Circle) - This is the selected item indicator
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: (size.width * _animation.value) - 28, // Center the 56px button
                top: -25, // Float above the navigation bar
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.items[widget.currentIndex],
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Icons Row
          SizedBox(
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final isSelected = index == widget.currentIndex;
                return material.IconButton(
                  onPressed: () => widget.onTap(index),
                  icon: material.Icon(
                    widget.items[index],
                    color: isSelected ? material.Colors.transparent : material.Colors.white54,
                    size: 28,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double position;
  final Color color;

  NavBarPainter({
    required this.position,
    required this.color,
  });

  @override
  void paint(material.Canvas canvas, material.Size size) {
    material.Paint paint = material.Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0); // Start top-left (relative to height offset handled below? No, usually 0 is top of bar)
    
    // We want the bar to start a bit lower to allow the FAB to float, 
    // but standard bottom bar usually fills bottom. 
    // Let's assume top of this widget is where the FAB floats.
    // The bar background actually starts at say y=20, except for the curve.
    
    // Let's draw a full rect with a cutout.
    // Actually, to support "floating", the bar usually has a height, and the curve dips INTO it.
    // But the user asked for "curve and circular position".
    // Let's do a classic "dip" notch.
    
    final double notchRadius = 35.0;
    final double center = size.width * position;
    
    // Draw line to start of notch
    path.lineTo(center - notchRadius * 1.5, 0);
    
    // Draw the notch curve
    path.cubicTo(
      center - notchRadius, 0,      // Control point 1
      center - notchRadius * 0.6, notchRadius * 0.8, // Control point 2
      center, notchRadius * 0.8,    // End point (bottom of notch)
    );
    
    path.cubicTo(
      center + notchRadius * 0.6, notchRadius * 0.8, // Control point 1
      center + notchRadius, 0,      // Control point 2
      center + notchRadius * 1.5, 0 // End point (back to top)
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Add a subtle shadow
    canvas.drawShadow(path, material.Colors.black.withOpacity(0.5), 10.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavBarPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color;
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  double angle;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);
  
  @override
  void paint(material.Canvas canvas, material.Size size) {
    final paint = material.Paint();
    canvas.translate(size.width / 2, size.height / 2); // Center the particle system
    for (var particle in particles) {
      paint.color = const material.Color(0xFF00E5FF).withOpacity(particle.opacity);
      canvas.drawCircle(material.Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}