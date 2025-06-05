import 'package:flutter/material.dart';
import 'package:flutter_client/widgets/main/catagories_section.dart';
import 'package:flutter_client/widgets/main/eco_tip_section.dart';
import 'package:flutter_client/widgets/main/loading_error_widgets.dart';
import 'package:flutter_client/widgets/main/recent_scan_section.dart';
import 'package:flutter_client/widgets/main/user_profile_card.dart';
import 'package:flutter_client/widgets/main/waste_bin_profile.dart';
import 'package:flutter_client/widgets/main/weekly_impact_section.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/main/catagories_provider.dart';
import '../../providers/main/waste_bins_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final wasteBinsAsync = ref.watch(userSelectedBinsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              UserProfileCard(),
              const SizedBox(height: 20),

              // Waste Bin Profile Section
              wasteBinsAsync.when(
                data: (bins) => WasteBinProfile(bins: bins),
                loading: () => const WasteBinProfileLoading(),
                error: (error, stack) => WasteBinProfileError(error: error),
              ),
              const SizedBox(height: 20),

              // Enhanced Categories Section
              // 🔥 FIREBASE INTEGRATION POINT 10: HANDLE ASYNC CATEGORIES
              categoriesAsync.when(
                data: (categories) => CategoriesSection(categories: categories),
                loading: () => const CategoriesSectionLoading(),
                error: (error, stack) => CategoriesSectionError(error: error),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
              _buildQuickActionsSection(),
              const SizedBox(height: 20),

              // Eco Tips Section (Separated Widget)
              const EcoTipSection(),
              const SizedBox(height: 20),

              // Recent Scans Section (Separated Widget)
              const RecentScansSection(),
              const SizedBox(height: 20),

              // Weekly Impact Summary Section (Separated Widget)
              const WeeklyImpactSection(),
              const SizedBox(height: 20),

              // Nearby Bin Stations Map Section (REPLACED Environmental Impact)
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
      floatingActionButton: FloatingScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Quick Actions Section (keeping this in main page as it's navigation-specific)
  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.camera_alt,
                  label: 'Scan Waste',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to scanner
                    // context.pushNamed('scanner');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'History',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to history
                    // context.pushNamed('scan_history');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.emoji_events,
                  label: 'Rewards',
                  color: Colors.amber,
                  onTap: () {
                    // Navigate to rewards
                    // context.pushNamed('rewards');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
