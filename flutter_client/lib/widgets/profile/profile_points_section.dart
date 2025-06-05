import 'package:flutter/material.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePointsSection extends ConsumerWidget {
  const ProfilePointsSection({super.key});

  // Get user level based on points (every 100 points = 1 level)
  int _getUserLevel(int points) {
    return (points / 100).floor() + 1;
  }

  // Get level icon based on user level ranges
  IconData _getLevelIcon(int level) {
    if (level >= 25) {
      return Icons.forest;
    } else if (level >= 10) {
      return Icons.eco;
    } else {
      return Icons.energy_savings_leaf;
    }
  }

  // Get level color with eco-friendly palette
  Color _getLevelColor(int level) {
    if (level >= 25) {
      return const Color(0xFF2D5016);
    } else if (level >= 10) {
      return const Color(0xFF388E3C);
    } else {
      return const Color(0xFF66BB6A);
    }
  }

  // Get level title
  String _getLevelTitle(int level) {
    if (level >= 25) {
      return 'Master Eco-Warrior';
    } else if (level >= 10) {
      return 'Eco-Champion';
    } else {
      return 'Eco-Beginner';
    }
  }

  // Helper method to build eco-friendly level progress
  Widget _buildEcoLevelProgress(int points, int currentLevel) {
    int pointsInCurrentLevel = points % 100;
    int pointsToNext = 100 - pointsInCurrentLevel;
    double progress = pointsInCurrentLevel / 100.0;

    // Special case for level 50 (max level)
    if (currentLevel >= 50) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D5016).withValues(alpha: 0.1),
              Color(0xFF2D5016).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF2D5016).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF2D5016),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.forest, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maximum Level Achieved!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5016),
                    ),
                  ),
                  Text(
                    'You\'ve become a true eco-warrior',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D5016).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF81C784).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFF388E3C), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Next Level: ${currentLevel + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pointsToNext pts needed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar with natural colors
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF388E3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '100',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF388E3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF81C784).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CAF50).withValues(alpha: 0.4),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F7BA), Color(0x524CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFF81C784).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: 40,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Loading Points Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading Current Points
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Container(
                      height: 18,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Loading Level title
              Container(
                height: 14,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(7),
                ),
              ),

              const SizedBox(height: 16),

              // Loading Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF81C784).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F7BA), Color(0x524CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Failed to load eco points',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsContent(UserProfile user) {
    final userLevel = _getUserLevel(user.ecoPoints);
    final levelIcon = _getLevelIcon(userLevel);
    final levelColor = _getLevelColor(userLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // Same as profile card
            Color(0x524CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFF81C784).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withValues(alpha: 0.3),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eco Points',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your sustainability journey',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF388E3C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(levelIcon, color: levelColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.$userLevel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Points Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Points
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.ecoPoints}',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'points',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Level title
              Text(
                _getLevelTitle(userLevel),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: levelColor,
                ),
              ),

              const SizedBox(height: 16),

              // Progress to next level
              _buildEcoLevelProgress(user.ecoPoints, userLevel),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) => _buildPointsContent(userProfile!),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }
}
