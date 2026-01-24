import 'package:flutter/material.dart';
import 'package:folicle/screens/home_screen.dart';

class WeeklyCheckInScreen extends StatefulWidget {
  const WeeklyCheckInScreen({super.key});

  @override
  State<WeeklyCheckInScreen> createState() => WeeklyState();
}

class WeeklyState extends State<WeeklyCheckInScreen> {
  int currentStep = 0;
  List<int> numDays = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    const List<String> questions = [
      'How many days this week have you eaten a large amount of sugar?',
      'How many days this week have been stressful for you?',
      'How many days this week have you slept well?',
    ];
    const List<String> labels = ['Sugar days', 'Stress days', 'Sleep days'];
    Widget body;
    if (currentStep == numDays.length) {
      body = Column(
        children: [
          const Text("Does this all look correct?"),
          ...List.generate(numDays.length, (int i) {
            return Text("${labels[i]}: ${numDays[i]}");
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
            value: numDays[currentStep].toDouble(),
            label: numDays[currentStep].toString(),
            max: 7,
            divisions: 7,
            onChanged: (double value) {
              setState(() {
                numDays[currentStep] = value.round();
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
