import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/scan_history.dart'; // Uncomment when you have the model
// import '../providers/scan_history_provider.dart'; // Uncomment when you have the provider

class WeeklyImpactSection extends ConsumerWidget {
  const WeeklyImpactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyData = _getWeeklyImpactData();
    final scanCount = weeklyData['scanCount'] as int;
    final points = weeklyData['points'] as String;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20), // Reduced padding for small screens
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA),
            Color(0x524CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with trending icon and scan count badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8), // Smaller padding for small screens
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.green[700],
                  size: isSmallScreen ? 20 : 24, // Smaller icon for small screens
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week\'s Impact',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18, // Smaller font for small screens
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                    ),
                    Text(
                      'Keep up the great work!',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12, // Smaller font for small screens
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12, // Reduced padding
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: isSmallScreen ? 14 : 16, // Smaller icon
                      color: Colors.green[700],
                    ),
                    SizedBox(width: isSmallScreen ? 2 : 4), // Reduced spacing
                    Text(
                      '$scanCount',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 24), // Reduced spacing
          
          // Main points display with modern card design
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 16 : 24, // Reduced padding
              horizontal: isSmallScreen ? 12 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side - Icon with background
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // Smaller padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[400]!,
                        Colors.blue[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 32, // Smaller icon
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 20), // Reduced spacing
                // Right side - Points info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: isSmallScreen ? 14 : 16, // Smaller icon
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6), // Reduced spacing
                          Flexible( // Make text flexible
                            child: Text(
                              'Points Earned',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14, // Smaller font
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis, // Handle overflow
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6), // Reduced spacing
                      Text(
                        points,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28, // Smaller font
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: isSmallScreen ? 10 : 12, // Smaller icon
                            color: Colors.blue[600],
                          ),
                          SizedBox(width: isSmallScreen ? 2 : 4), // Reduced spacing
                          Flexible( // Make text flexible
                            child: Text(
                              'This week',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12, // Smaller font
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis, // Handle overflow
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right decorative element - hide on very small screens
                if (!isSmallScreen || screenWidth > 350)
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8), // Smaller padding
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.blue[600],
                      size: isSmallScreen ? 20 : 24, // Smaller icon
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 20), // Reduced spacing
          
          // Progress summary
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildWeeklyProgress(scanCount, isSmallScreen),
          ),
        ],
      ),
    );
  }

  double _calculateProgress(int scanCount) {
    int weeklyGoal = 15;
    return (scanCount / weeklyGoal).clamp(0.0, 1.0);
  }

  Widget _buildWeeklyProgress(int scanCount, bool isSmallScreen) {
    int weeklyGoal = 15;
    double progress = _calculateProgress(scanCount);
    int remaining = ((1 - progress) * weeklyGoal).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible( // Make left side flexible
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: isSmallScreen ? 14 : 16, // Smaller icon
                    color: Colors.green[700],
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6), // Reduced spacing
                  Flexible( // Make text flexible
                    child: Text(
                      'Weekly Goal',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13, // Smaller font
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$scanCount / $weeklyGoal',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13, // Smaller font
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8), // Reduced spacing
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.green[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            minHeight: isSmallScreen ? 4 : 6, // Thinner progress bar
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8), // Reduced spacing
        Text(
          progress >= 1.0
              ? '🎉 Amazing! Goal achieved this week!'
              : remaining == 1
                  ? '🔥 Just 1 more scan to reach your goal!'
                  : '💪 $remaining more scans to reach your weekly goal',
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : 11, // Smaller font
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, // Handle text overflow
          maxLines: 2, // Allow text to wrap to 2 lines
        ),
      ],
    );
  }

  Map<String, dynamic> _getWeeklyImpactData() {
    return {
      'scanCount': 12,
      'points': '960',
    };
  }
}