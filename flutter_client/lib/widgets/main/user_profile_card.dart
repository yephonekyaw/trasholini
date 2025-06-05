import 'package:flutter/material.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'stat_card.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // #E3F7BA
            Color(
              0x524CAF50,
            ), // #529C4F4D (52 is the alpha, 9C4F4D is the color)
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
    return Column(
      children: [
        // User Info Row
        Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : const AssetImage('assets/profiles/default_profile.png')
                          as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 15),

            // User Name and Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.green[700], size: 30),
                      const SizedBox(width: 25),
                      Flexible(
                        child: Text(
                          user.displayName ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit Button - Navigate to Profile Page
            Container(
              decoration: BoxDecoration(
                color: Colors.green[600],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  // Navigate to profile page using GoRouter
                  context.pushNamed('profilepage', extra: user);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Stats Row
        Row(
          children: [
            StatCard(
              icon: Icons.recycling,
              value: "${0} kg",
              label: "waste",
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            StatCard(
              icon: Icons.cloud,
              value: "${0} kg",
              label: "carbon",
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            StatCard(
              icon: Icons.arrow_downward,
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

            // Loading User Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.grey[400], size: 30),
                      const SizedBox(width: 25),
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Loading Edit Button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Loading Stats Row
        Row(
          children: [
            _buildLoadingStatCard(),
            const SizedBox(width: 10),
            _buildLoadingStatCard(),
            const SizedBox(width: 10),
            _buildLoadingStatCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStatCard() {
    return Expanded(
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
