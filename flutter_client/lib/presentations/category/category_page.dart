import 'package:flutter/material.dart';
import 'package:flutter_client/providers/main/catagories_provider.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/waste_category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, ref),
            Expanded(child: _buildBody(context, ref, categoriesAsync)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
      floatingActionButton: FloatingScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => ref.read(routerProvider).go('/'),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waste Categories',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose a category to explore',
                  style: TextStyle(
                    color: const Color(0xFF388E3C).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<WasteCategory>> categoriesAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            const Color(0xFFE8F5E8).withValues(alpha: 0.3),
            const Color(0xFFF8FCF8),
          ],
        ),
      ),
      child: categoriesAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(context, ref),
        data: (categories) => _buildSuccessState(context, ref, categories),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50)),
          SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Failed to load categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(categoriesProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    WidgetRef ref,
    List<WasteCategory> categories,
  ) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    // Adjust grid settings based on screen size to prevent overflow
    final isSmallScreen = screenHeight < 700;
    final childAspectRatio =
        isSmallScreen ? 0.95 : 0.85; // Taller cards on small screens
    final bottomPadding =
        isSmallScreen ? 60.0 : 80.0; // Less bottom padding on small screens

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriesProvider);
        await ref.read(categoriesProvider.future);
      },
      color: const Color(0xFF4CAF50),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, ref, category, index);
              }, childCount: categories.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    WasteCategory category,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _onCategoryTap(context, ref, category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section - Reduced flex to prevent overflow
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE8F5E8),
                        child: const Icon(
                          Icons.recycling,
                          size: 40,
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Content section - Increased flex and better spacing
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 15, // Slightly reduced font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Reduced spacing
                    Expanded(
                      child: Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 11, // Reduced font size
                          color: Colors.grey[600],
                          height: 1.2, // Reduced line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // Reduced padding
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Smaller radius
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 9, // Reduced font size
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No categories available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Categories will appear here once loaded',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(
    BuildContext context,
    WidgetRef ref,
    WasteCategory category,
  ) {
    ref.read(routerProvider).go('/waste-items/${category.name}');
  }
}
