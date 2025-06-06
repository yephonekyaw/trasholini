import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple model for category items if you don't have one
class CategoryItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String categoryId;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
  });
}

// Temporary provider for category items - you can replace this with your actual provider
final categoryItemsProvider = FutureProvider.family<List<CategoryItem>, String>(
  (ref, categoryId) async {
    // Mock data - replace with your actual data fetching logic
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay

    // Return mock items based on category
    switch (categoryId) {
      case 'biodegradable':
        return [
          CategoryItem(
            id: 'bio_1',
            name: 'Food Scraps',
            description: 'Vegetable peels, fruit cores, etc.',
            imageUrl: 'assets/items/food_scraps.jpg',
            categoryId: categoryId,
          ),
          CategoryItem(
            id: 'bio_2',
            name: 'Garden Waste',
            description: 'Leaves, grass clippings',
            imageUrl: 'assets/items/garden_waste.jpg',
            categoryId: categoryId,
          ),
        ];
      case 'plastic':
        return [
          CategoryItem(
            id: 'plastic_1',
            name: 'Plastic Bottles',
            description: 'Water bottles, soda bottles',
            imageUrl: 'assets/items/plastic_bottles.jpg',
            categoryId: categoryId,
          ),
          CategoryItem(
            id: 'plastic_2',
            name: 'Plastic Bags',
            description: 'Shopping bags, food packaging',
            imageUrl: 'assets/items/plastic_bags.jpg',
            categoryId: categoryId,
          ),
        ];
      case 'paper':
        return [
          CategoryItem(
            id: 'paper_1',
            name: 'Newspapers',
            description: 'Daily newspapers, magazines',
            imageUrl: 'assets/items/newspapers.jpg',
            categoryId: categoryId,
          ),
        ];
      case 'glass':
        return [
          CategoryItem(
            id: 'glass_1',
            name: 'Glass Bottles',
            description: 'Wine bottles, beer bottles',
            imageUrl: 'assets/items/glass_bottles.jpg',
            categoryId: categoryId,
          ),
        ];
      case 'metal':
        return [
          CategoryItem(
            id: 'metal_1',
            name: 'Aluminum Cans',
            description: 'Soda cans, food cans',
            imageUrl: 'assets/items/aluminum_cans.jpg',
            categoryId: categoryId,
          ),
        ];
      case 'cardboard':
        return [
          CategoryItem(
            id: 'cardboard_1',
            name: 'Cardboard Boxes',
            description: 'Shipping boxes, cereal boxes',
            imageUrl: 'assets/items/cardboard_boxes.jpg',
            categoryId: categoryId,
          ),
        ];
      default:
        return [];
    }
  },
);

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryItemsAsync = ref.watch(categoryItemsProvider(categoryId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      appBar: _buildAppBar(context, ref, categoryItemsAsync),
      body: _buildBody(context, ref, categoryItemsAsync),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryItem>> categoryItemsAsync,
  ) {
    final itemCount = categoryItemsAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
          ),
        ),
      ),
      title: Column(
        children: [
          Text(
            categoryName,
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '$itemCount items',
            style: TextStyle(
              color: const Color(0xFF388E3C).withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: true,
      toolbarHeight: 75,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryItem>> categoryItemsAsync,
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
      child: categoryItemsAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(context, ref),
        data: (items) => _buildSuccessState(context, ref, items),
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
          Text('Loading items...', style: TextStyle(color: Color(0xFF2E7D32))),
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
            'Failed to load items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(categoryItemsProvider(categoryId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    WidgetRef ref,
    List<CategoryItem> items,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Determine grid settings based on screen size
    final isSmallScreen = screenHeight < 700;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = isSmallScreen ? 0.85 : 0.75;
    final crossAxisSpacing = isSmallScreen ? 12.0 : 16.0;
    final mainAxisSpacing = isSmallScreen ? 12.0 : 20.0;
    final padding = isSmallScreen ? 16.0 : 20.0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoryItemsProvider(categoryId));
        await ref.read(categoryItemsProvider(categoryId).future);
      },
      color: const Color(0xFF4CAF50),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(padding, 10, padding, padding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildItemCard(items[index], index),
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(CategoryItem item, int index) {
    return Container(
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
          // Image section
          Expanded(
            flex: 3,
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
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8F5E8),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 40,
                        color: Color(0xFF4CAF50),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Content section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          Text(
            'No items found in $categoryName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items will appear here once added',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
