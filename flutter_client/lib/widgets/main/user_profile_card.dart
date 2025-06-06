import 'package:flutter/material.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'stat_card.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  // Get user level based on points (every 100 points = 1 level)
  int _getUserLevel(int points) {
    return (points / 100).floor() + 1;
  }

  // Get level icon based on user level ranges
  IconData _getLevelIcon(int level) {
    if (level >= 25) {
      return Icons.forest; // Tree/Forest icon for levels 25-50 (Master Eco-Warrior)
    } else if (level >= 10) {
      return Icons.eco; // Eco leaf icon for levels 10-24 (Eco-Champion)
    } else {
      return Icons.energy_savings_leaf; // Small leaf for levels 1-9 (Eco-Beginner)
    }
  }

  // Get level color with eco-friendly palette
  Color _getLevelColor(int level) {
    if (level >= 25) {
      return const Color(0xFF2D5016); // Deep forest green for Master
    } else if (level >= 10) {
      return const Color(0xFF388E3C); // Medium green for Champion
    } else {
      return const Color(0xFF66BB6A); // Light green for Beginner
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // #E3F7BA
            Color(0x524CAF50), // #529C4F4D
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: userProfileAsync.when(
        data: (userProfile) => _buildUserContent(context, userProfile!),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildUserContent(BuildContext context, UserProfile user) {
    final userLevel = _getUserLevel(user.ecoPoints);
    final levelIcon = _getLevelIcon(userLevel);
    final levelColor = _getLevelColor(userLevel);
    final levelTitle = _getLevelTitle(userLevel);

    return Column(
      children: [
        // User Info Row
        Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : const AssetImage('assets/profiles/default_profile.png')
                      as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 15),

            // User Name and Level - Centered, Wrapped, and Clickable
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to profile page using GoRouter
                  context.pushNamed('profilepage', extra: user);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User Name
                      Text(
                        user.displayName ?? 'Anonymous',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Level Icon and Title/Level Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            levelIcon, // Dynamic icon based on level
                            color: levelColor, // Dynamic color based on level
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level $userLevel ($levelTitle)', // Dynamic Level number and title
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: levelColor, // Dynamic color for text
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Stats Row (now only for points)
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the single stat card
          children: [
            StatCard(
              icon: Icons.emoji_events, // Changed to a more generic trophy/event icon for points
              value: "${user.ecoPoints}",
              label: "points",
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Loading User Info Row
        Row(
          children: [
            // Loading Profile Picture
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Loading User Name Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.grey[400], size: 20),
                        const SizedBox(width: 4),
                        Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Loading Stats Row (now only for points)
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the single stat card
          children: [
            _buildLoadingStatCard(), // Single loading card
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStatCard() {
    return Expanded( // Still use Expanded so it fills available width in its row
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.circle, color: Colors.grey[300], size: 24),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 12,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
        const SizedBox(height: 12),
        Text(
          'Failed to load profile',
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
    );
  }
}