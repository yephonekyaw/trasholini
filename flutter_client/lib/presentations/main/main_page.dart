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
}
