import 'package:flutter/material.dart';
import 'package:folicle/screens/home_screen.dart';
import 'package:folicle/screens/initial_assessment_screen.dart';
import 'package:folicle/screens/weekly_checkin_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String initialAssessment = '/initial-assessment';
  static const String weeklyCheckIn = '/weekly-checkin';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      // initialAssessment: (context) => const InitialAssessmentScreen(),
      // weeklyCheckIn: (context) => const WeeklyCheckInScreen(),
    };
  }
}
