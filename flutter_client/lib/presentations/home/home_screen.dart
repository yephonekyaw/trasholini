import 'package:flutter/material.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Waste Tracker'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Logout button in app bar
          IconButton(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          if (userProfile == null) {
            // User is not authenticated
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Please sign in to continue',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // User is authenticated, show home content
          return _buildHomeContent(context, ref, userProfile);
        },
        loading:
            () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(fontSize: 18, color: Colors.red[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading the profile
                      ref.invalidate(userProfileProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        userProfile.photoUrl != null
                            ? NetworkImage(userProfile.photoUrl!)
                            : null,
                    child:
                        userProfile.photoUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          userProfile.displayName ?? "Anonymous",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Points section
          Card(
            elevation: 4,
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eco Points',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${userProfile.ecoPoints}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Main features section
          const Text(
            'What would you like to do?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Feature buttons
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildFeatureCard(
                icon: Icons.camera_alt,
                title: 'Scan Trash',
                subtitle: 'Identify waste items',
                color: Colors.blue,
                onTap: () {
                  // Navigate to scanner
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening AI Scanner...')),
                  );
                },
              ),
              _buildFeatureCard(
                icon: Icons.history,
                title: 'Scan History',
                subtitle: 'View your progress',
                color: Colors.purple,
                onTap: () {
                  // Navigate to history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening scan history...')),
                  );
                },
              ),
              _buildFeatureCard(
                icon: Icons.recycling,
                title: 'Disposal Guide',
                subtitle: 'Learn how to dispose',
                color: Colors.orange,
                onTap: () {
                  // Navigate to guide
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening disposal guide...')),
                  );
                },
              ),
              _buildFeatureCard(
                icon: Icons.leaderboard,
                title: 'Leaderboard',
                subtitle: 'Compare with others',
                color: Colors.red,
                onTap: () {
                  // Navigate to leaderboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening leaderboard...')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(googleAuthProvider.notifier).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
