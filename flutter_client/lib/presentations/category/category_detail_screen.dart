// Example: Updated Category Detail Screen using the improved providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category/category_item_model.dart';
import '../../providers/category/category_providers.dart';
import '../../widgets/category/category_item_card.dart';

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
    // ✅ Main provider - handles all state management
    final categoryItemsAsync = ref.watch(categoryItemsNotifierProvider(categoryId));
    
    // ✅ Optional: Watch search functionality
    final searchQuery = ref.watch(categorySearchProvider(categoryId));
    final filteredItems = ref.watch(filteredCategoryItemsProvider(categoryId));
    
    // ✅ Optional: Watch statistics
    final stats = ref.watch(categoryStatsProvider(categoryId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      appBar: _buildAppBar(context, ref, stats),
      body: Column(
        children: [
          // ✅ Optional: Search bar
          if (categoryItemsAsync.hasValue && categoryItemsAsync.value!.isNotEmpty)
            _buildSearchBar(ref),
          
          // ✅ Main content using filtered items if search is active
          Expanded(
            child: _buildBody(context, ref, searchQuery.isEmpty ? categoryItemsAsync : filteredItems),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, CategoryStats stats) {
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
            '${stats.totalItems} items • ${stats.recyclablePercentage.toStringAsFixed(0)}% recyclable',
            style: TextStyle(
              color: const Color(0xFF388E3C).withOpacity(0.8),
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

  // ✅ Optional: Search bar widget
  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          ref.read(categorySearchProvider(categoryId).notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              ref.read(categorySearchProvider(categoryId).notifier).state = '';
            },
            icon: const Icon(Icons.clear),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryItemModel>> categoryItemsAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            const Color(0xFFE8F5E8).withOpacity(0.3),
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
          const Text('Failed to load items'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // ✅ Use retry method from notifier
              ref.read(categoryItemsNotifierProvider(categoryId).notifier).retry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    WidgetRef ref,
    List<CategoryItemModel> items,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // ✅ Use the improved refresh method
        ref.read(categoryItemsNotifierProvider(categoryId).notifier).invalidateAndRefresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => CategoryItemCard(
                  item: items[index],
                  index: index,
                ),
                childCount: items.length,
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
          Text('No items found in $categoryName'),
        ],
      ),
    );
  }
}