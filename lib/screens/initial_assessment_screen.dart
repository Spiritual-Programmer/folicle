import 'package:flutter/material.dart';
import 'package:folicle/models/storage.dart' as storage;
import 'package:folicle/screens/weekly_checkin_screen.dart';
import 'package:folicle/screens/home_screen.dart';

class InitialAssessmentScreen extends StatefulWidget {
  const InitialAssessmentScreen({super.key});

  @override
  State<InitialAssessmentScreen> createState() =>
      _InitialAssessmentScreenState();
}

class _InitialAssessmentScreenState extends State<InitialAssessmentScreen> {
  int currentStep = 0;

  List<String> stepImages = [
    'assets/illustrations/hair_growth.jpg',
    'assets/illustrations/treatments.jpg',
    'assets/illustrations/conditions.jpg',
    'assets/illustrations/removal_methods.jpg',
  ];

  // Hair Growth Areas
  List<String> hairGrowthAreas = [];
  final List<String> optionshairGrowthAreas = [
    'Chin',
    'Upper Lip',
    'Jawline',
    'Neck',
  ];

  // Treatments
  List<String> treatments = [];
  final List<String> optionstreatments = [
    'Laser Hair Removal',
    'Electrolysis',
    'Prescription Medication',
    'Topical Creams',
    'Natural Remedies',
  ];

  // Known conditions
  List<String> conditions = [];
  final List<String> optionsConditions = [
    'PCOS (Polycystic Ovary Syndrome)',
    'Hormonal Imbalance (Doctor mentioned)',
    'Thyroid Issues',
    'Insulin Resistance/Prediabetes',
    'None',
    'Unsure',
  ];

  // Hair removal methods
  List<String> hairRemovalMethods = [];
  final List<String> optionsHairRemoval = [
    'Shaving',
    'Waxing',
    'Plucking',
    'Epilator',
    'Depilatory Creams',
    'None',
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = const SizedBox.shrink();

    if (currentStep == 0) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(stepImages[0], height: 200, fit: BoxFit.contain),
          const SizedBox(height: 24),
          const Text(
            'Hair growth areas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...optionshairGrowthAreas.map(
            (area) => CheckboxListTile(
              title: Text(area),
              value: hairGrowthAreas.contains(area),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    hairGrowthAreas.add(area);
                  } else {
                    hairGrowthAreas.remove(area);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      );
    } else if (currentStep == 1) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(stepImages[1], height: 200, fit: BoxFit.contain),
          const SizedBox(height: 24),
          const Text(
            'Previous treatments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...optionstreatments.map(
            (treatment) => CheckboxListTile(
              title: Text(treatment),
              value: treatments.contains(treatment),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    treatments.add(treatment);
                  } else {
                    treatments.remove(treatment);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      );
    } else if (currentStep == 2) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(stepImages[2], height: 150, fit: BoxFit.contain),
          const SizedBox(height: 24),
          const Text(
            'Known conditions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...optionsConditions.map(
            (condition) => CheckboxListTile(
              title: Text(condition),
              value: conditions.contains(condition),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    conditions.add(condition);
                  } else {
                    conditions.remove(condition);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      );
    } else if (currentStep == 3) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(stepImages[3], height: 200, fit: BoxFit.contain),
          const SizedBox(height: 24),
          const Text(
            'Hair removal methods',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...optionsHairRemoval.map(
            (method) => CheckboxListTile(
              title: Text(method),
              value: hairRemovalMethods.contains(method),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    hairRemovalMethods.add(method);
                  } else {
                    hairRemovalMethods.remove(method);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Let's personalize Folicle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: SingleChildScrollView(child: content)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (currentStep > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentStep--;
                    });
                  },
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (currentStep == 3) {
                    if (storage.appDataBox.get(
                          storage.StorageKeys.isAssessmentComplete,
                        ) !=
                        true) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Welcome!'),
                          content: const Text(
                            "You're ready to start tracking your hirsutism factors!",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                storage.appDataBox.put(
                                  storage.StorageKeys.isAssessmentComplete,
                                  true,
                                );
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Last step - mark assessment complete and navigate to weekly check-in
                      storage.appDataBox.put(
                        storage.StorageKeys.isAssessmentComplete,
                        true,
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false,
                      );
                    }
                  } else {
                    setState(() {
                      currentStep++;
                    });
                  }
                },
                child: Text(currentStep == 3 ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
