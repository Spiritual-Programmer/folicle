import 'package:folicle/models/storage.dart' as storage;

class WeeklyHistory {
  /// Ensure all history arrays exist in storage
  static void _ensureHistoryArrays() {
    final keys = [
      storage.StorageKeys.sugarHistory,
      storage.StorageKeys.stressHistory,
      storage.StorageKeys.sleepHistory,
      storage.StorageKeys.exerciseHistory,
      storage.StorageKeys.hairGrowthHistory,
    ];
    
    for (final key in keys) {
      if (storage.appDataBox.get(key) is! List) {
        storage.appDataBox.put(key, <double>[]);
      }
    }
  }

  /// Save one week's ratings to history
  static void saveWeek({
    required double sugar,
    required double stress,
    required double sleep,
    required double exercise,
    required double hairGrowth,
  }) {
    _ensureHistoryArrays();

    // Helper to get, append, and save
    void _appendToHistory(String key, double value) {
      final history = List<double>.from(
        (storage.appDataBox.get(key) as List?) ?? const []
      );
      history.add(value);
      storage.appDataBox.put(key, history);
    }

    _appendToHistory(storage.StorageKeys.sugarHistory, sugar);
    _appendToHistory(storage.StorageKeys.stressHistory, stress);
    _appendToHistory(storage.StorageKeys.sleepHistory, sleep);
    _appendToHistory(storage.StorageKeys.exerciseHistory, exercise);
    _appendToHistory(storage.StorageKeys.hairGrowthHistory, hairGrowth);
  }

  /// Get all historical data for correlation analysis
  static ({
    List<double> sugar,
    List<double> stress,
    List<double> sleep,
    List<double> exercise,
    List<double> hairGrowth,
  }) getAllHistory() {
    _ensureHistoryArrays();
    
    List<double> _getHistory(String key) =>
        List<double>.from((storage.appDataBox.get(key) as List?) ?? const []);

    return (
      sugar: _getHistory(storage.StorageKeys.sugarHistory),
      stress: _getHistory(storage.StorageKeys.stressHistory),
      sleep: _getHistory(storage.StorageKeys.sleepHistory),
      exercise: _getHistory(storage.StorageKeys.exerciseHistory),
      hairGrowth: _getHistory(storage.StorageKeys.hairGrowthHistory),
    );
  }
  
  /// Get number of weeks recorded
  static int getWeekCount() {
    _ensureHistoryArrays();
    return (storage.appDataBox.get(storage.StorageKeys.sugarHistory) as List).length;
  }
}
