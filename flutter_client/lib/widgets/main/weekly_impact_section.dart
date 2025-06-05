import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/scan_history.dart'; // Uncomment when you have the model
// import '../providers/scan_history_provider.dart'; // Uncomment when you have the provider
// import '../services/growth_calculator.dart'; // Uncomment when you add the service

class WeeklyImpactSection extends ConsumerWidget {
  const WeeklyImpactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual weekly scan data from provider
    // final allScans = ref.watch(scanHistoryProvider);
    // final growthData = GrowthCalculator.calculateGrowthFromScanHistory(allScans);

    final weeklyData = _getWeeklyImpactData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // Same as profile card
            Color(0x524CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'This Week\'s Impact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${weeklyData['scanCount']} scans',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStatCard(
                  icon: Icons.co2,
                  value: weeklyData['co2Reduced']!,
                  label: 'CO₂ Reduced',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildWeeklyStatCard(
                  icon: Icons.water_drop,
                  value: weeklyData['waterSaved']!,
                  label: 'Water Saved',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildWeeklyStatCard(
                  icon: Icons.stars,
                  value: weeklyData['points']!,
                  label: 'Points',
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          // Optional: Weekly progress bar
          if (weeklyData['scanCount'] > 0) ...[
            const SizedBox(height: 15),
            _buildWeeklyProgress(weeklyData['scanCount'] as int),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(int scanCount) {
    int weeklyGoal = 15; // Target scans per week
    double progress = (scanCount / weeklyGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Goal Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            Text(
              '$scanCount/$weeklyGoal scans',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          progress >= 1.0
              ? '🎉 Goal achieved!'
              : '${((1 - progress) * weeklyGoal).ceil()} more scans to reach your goal',
          style: TextStyle(
            fontSize: 10,
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Simplified weekly data without complex growth calculations
  Map<String, dynamic> _getWeeklyImpactData() {
    // TODO: Calculate from actual scan history for current week
    /*
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));
    
    final weeklyScans = scanHistory.where((scan) => 
      scan.scanDate.isAfter(weekStart) && scan.scanDate.isBefore(weekEnd)
    ).toList();
    
    double totalCO2 = weeklyScans.fold(0, (sum, scan) => sum + scan.co2Saved);
    double totalWater = weeklyScans.fold(0, (sum, scan) => sum + scan.waterSaved);
    int totalPoints = weeklyScans.fold(0, (sum, scan) => sum + scan.pointsEarned);
    */

    // Simple weekly totals - easy to understand
    return {
      'scanCount': 12,
      'co2Reduced': '28.4kg',
      'waterSaved': '180L',
      'points': '960',
    };
  }
}
