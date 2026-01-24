import 'package:flutter/material.dart';
import 'package:folicle/screens/initial_assessment_screen.dart';
import 'package:folicle/screens/weekly_checkin_screen.dart';
import 'package:folicle/models/storage.dart' as storage;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TEMP: hardcoded for now
  final bool isProfileComplete = true;

  @override
  Widget build(BuildContext context) {
    //storage.weeklyHistoryBox.put('numDays', [0.9, 0.1, 0.5]);
    return Scaffold(
      appBar: AppBar(title: const Text('Folicle'), centerTitle: true),
      body: Center(
        child: ElevatedButton(
          child: const Text('Get Started'),
          onPressed: () {
            if (isProfileComplete) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyCheckInScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InitialAssessmentScreen(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
