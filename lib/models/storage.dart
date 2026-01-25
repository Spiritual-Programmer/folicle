library folicle.storage;

import "package:hive/hive.dart";

/// Main storage box for all app data
Box appDataBox = Hive.box("delete_me");

/// Storage keys - centralized to avoid typos
class StorageKeys {
  // Track if user has completed initial assessment
  static const String isAssessmentComplete = 'isAssessmentComplete';
  
  // Current week's in-progress ratings (0-5 for each metric)
  static const String currentWeekRatings = 'currentWeekRatings';

  // Track last check-in date to prevent duplicate entries
  static const String lastCheckInDate = 'lastCheckInDate';

  // Historical data - one array per metric
  static const String sugarHistory = 'sugarHistory';
  static const String stressHistory = 'stressHistory';
  static const String sleepHistory = 'sleepHistory';
  static const String exerciseHistory = 'exerciseHistory';
  static const String hairGrowthHistory = 'hairGrowthHistory';
}

/// Metric indices for currentWeekRatings list
class MetricIndex {
  static const int sugar = 0;
  static const int stress = 1;
  static const int sleep = 2;
  static const int exercise = 3;
  static const int hairGrowth = 4;

  static const int count = 5; // total number of metrics
}
