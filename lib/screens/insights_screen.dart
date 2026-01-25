import 'package:flutter/material.dart';
import 'package:folicle/services/trigger_calculator.dart';
import 'package:folicle/services/weekly_history.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = WeeklyHistory.getAllHistory();
    final weekCount = WeeklyHistory.getWeekCount();

    // Need at least 3 weeks for lagged correlation (2 lag pairs)
    if (weekCount < 3) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  'Not enough data yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete at least 3 weekly check-ins to see your insights. Lagged correlation requires tracking how last week\'s behavior affects this week\'s hair growth.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You have $weekCount week${weekCount == 1 ? '' : 's'} recorded.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final correlations = TriggerCalculator.correlationsAgainstHairGrowth(
      sugar: history.sugar,
      stress: history.stress,
      sleep: history.sleep,
      exercise: history.exercise,
      hairGrowth: history.hairGrowth,
    );

    final ranked = TriggerCalculator.rankByAbsoluteStrength(correlations);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Insights'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on $weekCount weeks of data',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                Text(
                  'What affects your hirsutism most:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...ranked.map((entry) {
                  final metric = entry.key;
                  final r = entry.value;

                  if (r.isNaN) {
                    return _buildInsightCard(
                      context,
                      metric,
                      'Insufficient variation',
                      'Try varying your $metric levels to see its impact.',
                      Colors.grey,
                      Icons.info_outline,
                    );
                  }

                  // Determine impact based on metric type and correlation
                  String impact;
                  String description;
                  Color color;
                  IconData icon;

                  if (metric == 'Sugar' || metric == 'Stress') {
                    // For triggers: positive correlation = bad (more trigger = more hair)
                    if (r > 0.3) {
                      impact = 'Strong trigger';
                      description =
                          'High ${metric.toLowerCase()} linked to hirsutism';
                      color = Colors.red;
                      icon = Icons.trending_up;
                    } else if (r > 0.1) {
                      impact = 'Mild trigger';
                      description =
                          'High ${metric.toLowerCase()} linked to hirsutism';
                      color = Colors.orange;
                      icon = Icons.arrow_upward;
                    } else if (r < -0.1) {
                      impact = 'Beneficial';
                      description = '${metric} may help reduce hirsutism';
                      color = Colors.green;
                      icon = Icons.trending_down;
                    } else {
                      impact = 'Minimal effect';
                      description = '${metric} shows little impact';
                      color = Colors.grey;
                      icon = Icons.horizontal_rule;
                    }
                  } else {
                    // For beneficial factors (sleep, exercise): negative correlation = good
                    if (r < -0.3) {
                      impact = 'Highly beneficial';
                      description =
                          'Good ${metric.toLowerCase()} helps reduce hirsutism';
                      color = Colors.green;
                      icon = Icons.trending_up;
                    } else if (r < -0.1) {
                      impact = 'Mildly beneficial';
                      description =
                          'Good ${metric.toLowerCase()} helps reduce hirsutism';
                      color = Colors.lightGreen;
                      icon = Icons.trending_up;
                    } else if (r > 0.1) {
                      impact = 'Concerning';
                      description =
                          'Lack of ${metric.toLowerCase()} may increase hirsutism';
                      color = Colors.red;
                      icon = Icons.trending_down;
                    } else {
                      impact = 'Minimal effect';
                      description = '${metric} shows little impact';
                      color = Colors.grey;
                      icon = Icons.horizontal_rule;
                    }
                  }

                  return _buildInsightCard(
                    context,
                    metric,
                    impact,
                    description,
                    color,
                    icon,
                    correlation: r,
                  );
                }).toList(),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Understanding your insights',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Insights show correlations, not predictions or medical advice. Accuracy improves with continued tracking.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String metric,
    String impact,
    String description,
    Color color,
    IconData icon, {
    double? correlation,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.capitalize(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      impact,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (correlation != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'r = ${correlation.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
