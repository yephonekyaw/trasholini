import 'package:flutter/material.dart';
import 'package:flutter_client/widgets/profile/profile_history_section.dart';
import 'package:flutter_client/widgets/profile/profile_points_section.dart';
import 'package:flutter_client/widgets/profile/profile_header_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Light green background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Section (Profile pic, name, level)
              ProfileHeaderSection(),

              const SizedBox(height: 20),

              // Points Section (Eco points card with progress)
              ProfilePointsSection(),

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
