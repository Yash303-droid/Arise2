import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // This is our Dashboard
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Character Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Level 1',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.4, // Example value
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  icon: Icons.show_chart,
                  label: "Today's Progress",
                  value: '75%',
                ),
                _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Longest Streak',
                  value: '12 days',
                ),
                _buildStatCard(
                  icon: Icons.star,
                  label: 'Achievements',
                  value: '5',
                ),
                _buildStatCard(
                  icon: Icons.calendar_today,
                  label: 'Days Active',
                  value: '30',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Weekly Progress",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: _buildWeeklyChart(),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
Widget _buildStatCard(
    {required IconData icon, required String label, required String value}) {
  return Card(
    color: Colors.white.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildWeeklyChart() {
  // Placeholder data for weekly progress
  final List<double> weeklyProgress = [0.4, 0.8, 0.6, 0.9, 0.5, 0.7, 0.3];
  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: List.generate(7, (index) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100 * weeklyProgress[index],
            width: 12,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            days[index],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      );
    }),
  );
}
