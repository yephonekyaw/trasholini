import 'package:flutter/material.dart';
import 'package:flutter_client/widgets/profile/profile_action.dart';
import 'package:flutter_client/widgets/profile/profile_history_section.dart';
import 'package:flutter_client/widgets/profile/profile_points_section.dart';
import 'package:flutter_client/widgets/profile/profile_header_section.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Ensure GoRouter is imported

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E8), // Match background color
        elevation: 0, // No shadow under app bar
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
          onPressed: () => context.goNamed('mainpage'),
        ),
        title: const Text(
          'TRASHOLINI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView( // Removed SafeArea from here, AppBar handles top padding
        child: Column(
          children: [
            // Profile Header Section (now without its own internal header)
            const ProfileHeaderSection(),

            const SizedBox(height: 20),

            // Points Section
            const ProfilePointsSection(),

            const SizedBox(height: 20),

            // History Section
            const ProfileHistorySection(),

            const SizedBox(height: 40),

            // Account Actions Section
            const ProfileAccountActionsSection(),
          ],
        ),
      ),
    );
  }
}