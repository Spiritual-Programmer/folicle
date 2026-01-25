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
  List<double> numDays = () {
    var stored = storage.weeklyHistoryBox.get('numDays');
    if (stored is! List<double> || stored.length != 5) {
      storage.weeklyHistoryBox.put('numDays', [0.0, 0.0, 0.0, 0.0, 0.0]);
      return [0.0, 0.0, 0.0, 0.0, 0.0];
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
    if (currentStep == numDays.length) {
      body = Column(
        children: [
          const Text("Does these ratings look correct?"),
          ...List.generate(numDays.length, (int i) {
            return Text("${labels[i]}: ${numDays[i].toInt()}");
          }),
        ],
      );
    } else {
      body = Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(questions[currentStep]),
          Slider(
            year2023: false,
            value: numDays[currentStep],
            min: 0,
            max: 5,
            divisions: 5,
            label: numDays[currentStep].toInt().toString(),
            onChanged: (double value) {
              setState(() {
                numDays[currentStep] = value;
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
                    if (currentStep == numDays.length) {
                      debugPrint('Got the values: $numDays');
                      storage.weeklyHistoryBox.put("numDays", numDays);
                      Navigator.of(context).pop();
                    } else {
                      currentStep += 1;
                    }
                  });
                },
                child: Text(currentStep == numDays.length ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
