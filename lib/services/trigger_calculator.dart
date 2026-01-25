import 'dart:math';
// ...existing code...

/// Computes Pearson correlation coefficients to identify which inputs
/// (sugar, stress, sleep, exercise) are most linearly related to hair growth.
///
/// Pearson correlation r is defined as:
///   r = covariance(x, y) / (stddev(x) * stddev(y))
/// where:
///   covariance(x, y) = sum((x_i - mean(x)) * (y_i - mean(y)))
///   stddev(x) = sqrt(sum((x_i - mean(x))^2))
///
/// r ranges from -1 to +1:
///   +1 = perfect positive linear relationship
///   -1 = perfect negative linear relationship
///    0 = no linear relationship
class TriggerCalculator {
  /// Returns the Pearson correlation between two equal-length series.
  /// If series have < 2 points or either series has zero variance, returns NaN.
  static double computePearsonCorrelation(
    List<double> seriesX,
    List<double> seriesY,
  ) {
    if (seriesX.length != seriesY.length) {
      throw ArgumentError('Both series must have the same number of samples.');
    }
    final int sampleCount = seriesX.length;
    if (sampleCount < 2) return double.nan; // not enough data to correlate

    // 1) Compute means (average values)
    final double meanX = _mean(seriesX);
    final double meanY = _mean(seriesY);

    // 2) Accumulate:
    //    - covariance numerator: sum((x - meanX) * (y - meanY))
    //    - variance sums: sum((x - meanX)^2) and sum((y - meanY)^2)
    double covarianceNumerator = 0.0;
    double sumSquaredDeviationX = 0.0;
    double sumSquaredDeviationY = 0.0;

    for (int i = 0; i < sampleCount; i++) {
      final double centeredX = seriesX[i] - meanX; // deviation from mean
      final double centeredY = seriesY[i] - meanY;
      covarianceNumerator += centeredX * centeredY;
      sumSquaredDeviationX += centeredX * centeredX;
      sumSquaredDeviationY += centeredY * centeredY;
    }

    // 3) Denominator = product of standard deviations
    final double stdProduct = sqrt(sumSquaredDeviationX * sumSquaredDeviationY);
    if (stdProduct == 0.0) return double.nan; // zero variance in one series

    // 4) Pearson r = covariance / (stdX * stdY)
    return covarianceNumerator / stdProduct;
  }

  /// Computes correlations of each input vs hair growth.
  /// All lists must be the same length (same number of weeks/samples).
  static Map<String, double> correlationsAgainstHairGrowth({
    required List<double> sugar,
    required List<double> stress,
    required List<double> sleep,
    required List<double> exercise,
    required List<double> hairGrowth,
  }) {
    return {
      'Sugar': computePearsonCorrelation(sugar, hairGrowth),
      'Stress': computePearsonCorrelation(stress, hairGrowth),
      'Sleep': computePearsonCorrelation(sleep, hairGrowth),
      'Exercise': computePearsonCorrelation(exercise, hairGrowth),
    };
  }

  /// Ranks correlations by absolute strength (highest |r| first).
  static List<MapEntry<String, double>> rankByAbsoluteStrength(
    Map<String, double> correlations,
  ) {
    final list = correlations.entries.toList();
    list.sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    return list;
  }

  static double _mean(List<double> values) {
    double sum = 0.0;
    for (final v in values) {
      sum += v;
    }
    return sum / values.length;
  }
}
