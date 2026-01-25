import 'package:flutter/material.dart';
import 'package:folicle/screens/initial_assessment_screen.dart';
import 'package:folicle/screens/weekly_checkin_screen.dart';
import 'package:folicle/models/storage.dart' as storage;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool get _isAssessmentComplete {
    return storage.appDataBox.get(
          storage.StorageKeys.isAssessmentComplete,
          defaultValue: false,
        )
        as bool;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folicle'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text(
                _isAssessmentComplete ? 'Weekly Check-In' : 'Get Started',
              ),
              onPressed: () {
                if (_isAssessmentComplete) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeeklyCheckInScreen(),
                    ),
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
            // Show retake option after assessment is complete
            if (_isAssessmentComplete) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InitialAssessmentScreen(),
                    ),
                  );
                },
                child: const Text('Retake Assessment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
