import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/main/users.dart'; // Updated to match your import
import '../../providers/main/user_provider.dart';
import 'stat_card.dart'; // Import the StatCard widget

class UserProfileCard extends ConsumerWidget {
  final User user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // #E3F7BA
            Color(0x524CAF50), // #529C4F4D (52 is the alpha, 9C4F4D is the color)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // User Info Row
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(user.profileImageUrl),
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
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                value: "${user.wasteKg}kg",
                label: "waste",
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              StatCard(
                icon: Icons.cloud,
                value: "${user.carbonKg}kg",
                label: "carbon",
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              StatCard(
                icon: Icons.arrow_downward,
                value: "${user.points}",
                label: "points",
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Optional: Keep the old dialog method as backup (commented out)
  /*
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User user) {
    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(userProvider.notifier)
                  .updateProfile(name: nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  */
}