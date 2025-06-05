import 'package:flutter/material.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileHeaderSection extends ConsumerStatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  ConsumerState<ProfileHeaderSection> createState() =>
      _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends ConsumerState<ProfileHeaderSection> {
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Get user level based on points (every 100 points = 1 level)
  int _getUserLevel(int points) {
    return (points / 100).floor() + 1;
  }

  // Get level icon based on user level ranges
  IconData _getLevelIcon(int level) {
    if (level >= 25) {
      return Icons
          .forest; // Tree/Forest icon for levels 25-50 (Master Eco-Warrior)
    } else if (level >= 10) {
      return Icons.eco; // Eco leaf icon for levels 10-24 (Eco-Champion)
    } else {
      return Icons
          .energy_savings_leaf; // Small leaf for levels 1-9 (Eco-Beginner)
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

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.goNamed('mainpage'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'TRASHOLINI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Loading Profile Content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Loading Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey[400]!, width: 3),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Loading User Name
                Container(
                  height: 24,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(height: 8),

                // Loading User Level
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.goNamed('mainpage'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'TRASHOLINI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Error Content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontSize: 18,
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
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent(UserProfile user) {
    final userLevel = _getUserLevel(user.ecoPoints);
    final levelIcon = _getLevelIcon(userLevel);
    final levelColor = _getLevelColor(userLevel);

    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.goNamed('mainpage'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'TRASHOLINI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Profile Picture and User Info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Picture and Edit
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement image picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Change profile picture - Coming Soon!',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              user.photoUrl != null
                                  ? Image.network(
                                    user.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Name with Edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isEditingName)
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              // TODO: Update user name in provider
                              // ref.read(userProfileProvider.notifier).updateProfile(name: value.trim());
                            }
                            setState(() {
                              _isEditingName = false;
                            });
                          },
                        ),
                      )
                    else
                      Text(
                        user.displayName ?? 'Anonymous',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_isEditingName) {
                          if (_nameController.text.trim().isNotEmpty) {
                            // TODO: Update user name in provider
                            // ref.read(userProfileProvider.notifier).updateProfile(name: _nameController.text.trim());
                          }
                          setState(() {
                            _isEditingName = false;
                          });
                        } else {
                          _nameController.text = user.displayName ?? '';
                          setState(() {
                            _isEditingName = true;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isEditingName ? Icons.check : Icons.edit,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                // User Level with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(levelIcon, color: levelColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Level $userLevel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) => _buildHeaderContent(userProfile!),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }
}
