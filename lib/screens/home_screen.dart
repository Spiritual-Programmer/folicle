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
    if (!_isAssessmentComplete) {
      return Scaffold(
        body: Center(child: Text("Welcome! Let's get you started.")),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text('Take Initial Assessment'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InitialAssessmentScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete all data'),
                      content: const Text('Are you sure you want to delete?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            storage.appDataBox.clear().then((_) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (_) => false,
                              );
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Delete all data"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
