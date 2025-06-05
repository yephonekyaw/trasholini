import 'package:flutter/material.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_client/widgets/profile/profile_history_section.dart';
import 'package:flutter_client/widgets/profile/profile_points_section.dart';
import 'package:flutter_client/widgets/profile/profile_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    // if (user == null) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Light green background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Section (Profile pic, name, level)
              ProfileHeaderSection(user: user),

              const SizedBox(height: 20),

              // Points Section (Eco points card with progress)
              ProfilePointsSection(user: user),

              const SizedBox(height: 20),

              // History Section (Scan history with details)
              const ProfileHistorySection(),
            ],
          ),
        ),
      ),
    );
  }
}
