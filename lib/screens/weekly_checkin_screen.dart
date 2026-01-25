import 'package:flutter/material.dart';
import 'package:folicle/screens/home_screen.dart';
import 'package:folicle/models/storage.dart' as storage;
import 'package:folicle/services/trigger_calculator.dart';
import 'package:folicle/services/weekly_history.dart';

class WeeklyCheckInScreen extends StatefulWidget {
  const WeeklyCheckInScreen({super.key});

  @override
  State<WeeklyCheckInScreen> createState() => WeeklyState();
}

class WeeklyState extends State<WeeklyCheckInScreen> {
  int currentStep = 0;

  // DEBUG MODE: Set to false in production to enforce 7-day cooldown
  static const bool _debugMode = true;

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

  /// Check if at least 7 days have passed since last check-in
  bool _canSubmitCheckIn() {
    if (_debugMode) return true; // Skip check in debug mode

    final lastDate = storage.appDataBox.get(
      storage.StorageKeys.lastCheckInDate,
    );
    if (lastDate == null) return true; // First time

    final lastDateTime = DateTime.parse(lastDate as String);
    final daysSince = DateTime.now().difference(lastDateTime).inDays;
    return daysSince >= 7;
  }

  /// Save week and calculate correlations
  void _saveWeekAndCalculateTriggers() {
    // Save this week's data
    WeeklyHistory.saveWeek(
      sugar: currentWeekRatings[storage.MetricIndex.sugar],
      stress: currentWeekRatings[storage.MetricIndex.stress],
      sleep: currentWeekRatings[storage.MetricIndex.sleep],
      exercise: currentWeekRatings[storage.MetricIndex.exercise],
      hairGrowth: currentWeekRatings[storage.MetricIndex.hairGrowth],
    );

    // Update last check-in date
    storage.appDataBox.put(
      storage.StorageKeys.lastCheckInDate,
      DateTime.now().toIso8601String(),
    );

    // Reset current week ratings
    final resetRatings = List<double>.filled(storage.MetricIndex.count, 0.0);
    storage.appDataBox.put(
      storage.StorageKeys.currentWeekRatings,
      resetRatings,
    );

    // Calculate correlations if we have enough data
    // Need at least 4 weeks for lagged correlation (2 lag pairs)
    final weekCount = WeeklyHistory.getWeekCount();
    if (weekCount >= 4) {
      final history = WeeklyHistory.getAllHistory();
      final correlations = TriggerCalculator.correlationsAgainstHairGrowth(
        sugar: history.sugar,
        stress: history.stress,
        sleep: history.sleep,
        exercise: history.exercise,
        hairGrowth: history.hairGrowth,
      );

      final ranked = TriggerCalculator.rankByAbsoluteStrength(correlations);

      // Show results
      _showCorrelationResults(ranked, weekCount);
    } else {
      // Not enough data yet
      _showNotEnoughDataMessage();
    }
  }

  void _showCorrelationResults(
    List<MapEntry<String, double>> ranked,
    int weekCount,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your Hirsutism Triggers ($weekCount weeks)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What affects your hirsutism:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...ranked.where((entry) => !entry.value.isNaN).map((entry) {
                final strength = entry.value.abs();
                final isGoodFactor =
                    entry.key == 'Sleep' || entry.key == 'Exercise';

                // Determine message based on factor type and correlation direction
                String message;
                String emoji;

                if (isGoodFactor) {
                  // For sleep/exercise:
                  // - Negative correlation = more sleep/exercise → less hirsutism (GOOD) ✅
                  // - Positive correlation = more sleep/exercise → more hirsutism (BAD) ⚠️
                  if (entry.value < 0) {
                    message =
                        'Good ${entry.key.toLowerCase()} helps reduce hirsutism';
                    emoji = '✅';
                  } else {
                    message =
                        'Lack of ${entry.key.toLowerCase()} may increase hirsutism';
                    emoji = '⚠️';
                  }
                } else {
                  // For sugar/stress:
                  // - Positive correlation = more sugar/stress → more hirsutism (BAD) ⚠️
                  // - Negative correlation = more sugar/stress → less hirsutism (unusual but possible) ✅
                  if (entry.value > 0) {
                    message =
                        'High ${entry.key.toLowerCase()} linked to hirsutism';
                    emoji = '⚠️';
                  } else {
                    message = '${entry.key} may help reduce hirsutism';
                    emoji = '✅';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$emoji $message (${(strength * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontWeight: strength > 0.5
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
              // Show which metrics have insufficient data
              if (ranked.any((e) => e.value.isNaN))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'ℹ️ ${ranked.where((e) => e.value.isNaN).map((e) => e.key).join(', ')}: '
                    'Not enough variation in data',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showNotEnoughDataMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Week Saved!'),
        content: const Text(
          'Keep tracking! You need at least 4 weeks of data to see correlations.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<String> questions = [
      'How much sugar did you consume last week?',
      'How stressful was last week for you?',
      'How well did you sleep last week?',
      'How much exercise did you do last week?',
      'How much hair growth have you noticed last week?',
    ];
    const List<String> labels = [
      'Sugar',
      'Stress',
      'Sleep',
      'Exercise',
      'Hair Growth',
    ];

    const List<String> stepImages = [
      'assets/illustrations/sugar.jpg',
      'assets/illustrations/stress.jpg',
      'assets/illustrations/sleep.jpg',
      'assets/illustrations/exercise.jpg',
      'assets/illustrations/hair_growth.jpg',
    ];

    Widget body;
    if (currentStep == currentWeekRatings.length) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(currentWeekRatings.length, (int i) {
              final rating = currentWeekRatings[i].toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      labels[i],
                      style: const TextStyle(fontSize: 17, letterSpacing: -0.4),
                    ),
                    Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey.shade600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    } else {
      body = Column(
        children: <Widget>[
          Image.asset(
            stepImages[currentStep],
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(questions[currentStep]),
          const SizedBox(height: 16),
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
                  if (currentStep == currentWeekRatings.length) {
                    // Check if 7 days have passed
                    if (!_canSubmitCheckIn()) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Too Soon!'),
                          content: const Text(
                            'You can only submit a check-in once per week. '
                            'Please wait at least 7 days since your last entry.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // Save and calculate
                    _saveWeekAndCalculateTriggers();
                  } else {
                    setState(() {
                      currentStep += 1;
                    });
                  }
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
