import 'package:flutter/material.dart';
import 'package:folicle/screens/home_screen.dart';
import 'package:folicle/models/storage.dart' as storage;

class WeeklyCheckInScreen extends StatefulWidget {
  const WeeklyCheckInScreen({super.key});

  @override
  State<WeeklyCheckInScreen> createState() => WeeklyState();
}

class WeeklyState extends State<WeeklyCheckInScreen> {
  int currentStep = 0;

  // Current week's ratings for each metric (0-5)
  List<double> currentWeekRatings = () {
    var stored = storage.appDataBox.get(storage.StorageKeys.currentWeekRatings);
    if (stored is! List<double> || stored.length != storage.MetricIndex.count) {
      final defaultRatings = List<double>.filled(
        storage.MetricIndex.count,
        0.0,
      );
      storage.appDataBox.put(
        storage.StorageKeys.currentWeekRatings,
        defaultRatings,
      );
      return defaultRatings;
    }
    return stored;
  }();

  @override
  Widget build(BuildContext context) {
    const List<String> questions = [
      'How much sugar did you consume this week?',
      'How stressfull was this week for you?',
      'How well did you sleep this week?',
      'How much exercise did you do this week?',
      'How much hair growth have you noticed this week?',
    ];
    const List<String> labels = [
      'Sugar',
      'Stress',
      'Sleep',
      'Exercise',
      'Hair Growth',
    ];
    Widget body;
    if (currentStep == currentWeekRatings.length) {
      body = Column(
        children: [
          const Text("Do these ratings look correct?"),
          ...List.generate(currentWeekRatings.length, (int i) {
            return Text("${labels[i]}: ${currentWeekRatings[i].toInt()}");
          }),
        ],
      );
    } else {
      body = Column(
        children: <Widget>[
          Text(questions[currentStep]),
          Slider(
            year2023: false,
            value: currentWeekRatings[currentStep],
            min: 0,
            max: 5,
            divisions: 5,
            label: currentWeekRatings[currentStep].toInt().toString(),
            onChanged: (double value) {
              setState(() {
                currentWeekRatings[currentStep] = value;
                storage.appDataBox.put(
                  storage.StorageKeys.currentWeekRatings,
                  currentWeekRatings,
                );
              });
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Check-in')),
      body: Center(child: body),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Visibility(
                visible: currentStep > 0,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentStep > 0) {
                        currentStep -= 1;
                      }
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentStep == currentWeekRatings.length) {
                      // TODO: Save to history here
                      debugPrint('Got the values: $currentWeekRatings');
                      Navigator.of(context).pop();
                    } else {
                      currentStep += 1;
                    }
                  });
                },
                child: Text(
                  currentStep == currentWeekRatings.length ? 'Finish' : 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
