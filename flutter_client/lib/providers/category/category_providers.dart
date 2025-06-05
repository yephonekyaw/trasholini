import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category/category_item_model.dart';
import '../../services/category/category_service.dart';

// ✅ Keep this - Simple FutureProvider for basic usage
final categoryItemsProvider = FutureProvider.family<List<CategoryItemModel>, String>((ref, categoryId) async {
  return await CategoryService.getCategoryItems(categoryId);
});

// ❌ Remove these - AsyncNotifierProvider already handles loading/error states
// final categoryLoadingProvider = StateProvider.family<bool, String>((ref, categoryId) => false);
// final categoryErrorProvider = StateProvider.family<String?, String>((ref, categoryId) => null);

// ✅ Main provider - Use this in your UI
final categoryItemsNotifierProvider = AsyncNotifierProvider.family<CategoryItemsNotifier, List<CategoryItemModel>, String>(
  CategoryItemsNotifier.new,
);

// ✅ Optional: Search/Filter functionality
final categorySearchProvider = StateProvider.family<String, String>((ref, categoryId) => '');

final filteredCategoryItemsProvider = Provider.family<AsyncValue<List<CategoryItemModel>>, String>((ref, categoryId) {
  final items = ref.watch(categoryItemsNotifierProvider(categoryId));
  final searchQuery = ref.watch(categorySearchProvider(categoryId));
  
  return items.when(
    data: (itemList) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(itemList);
      }
      final filtered = itemList.where((item) =>
        item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        item.description.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// ✅ Improved CategoryItemsNotifier
class CategoryItemsNotifier extends FamilyAsyncNotifier<List<CategoryItemModel>, String> {
  @override
  Future<List<CategoryItemModel>> build(String categoryId) async {
    // Set loading state and fetch initial data
    return await _fetchItems();
  }

  // ✅ Private method to fetch items
  Future<List<CategoryItemModel>> _fetchItems() async {
    try {
      return await CategoryService.getCategoryItems(arg);
    } catch (error) {
      // You can add logging here if needed
      rethrow;
    }
  }

  // ✅ Simplified refresh method
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  // ✅ Alternative refresh using invalidation (recommended)
  void invalidateAndRefresh() {
    ref.invalidateSelf();
  }

  // ✅ Retry method for error states
  Future<void> retry() async {
    if (state.hasError) {
      await refresh();
    }
  }

  // ✅ Add item method (improved)
  Future<void> addItem(CategoryItemModel item) async {
    // Optimistically update the UI
    final currentItems = state.value ?? [];
    state = AsyncValue.data([...currentItems, item]);
    
    try {
      // Here you would call your API to add the item
      // await CategoryService.addCategoryItem(arg, item);
      
      // Refresh to get the latest data from server
      await refresh();
    } catch (error, stackTrace) {
      // Revert the optimistic update on error
      state = AsyncValue.data(currentItems);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ✅ Remove item method
  Future<void> removeItem(String itemId) async {
    final currentItems = state.value ?? [];
    final updatedItems = currentItems.where((item) => item.id != itemId).toList();
    
    // Optimistically update
    state = AsyncValue.data(updatedItems);
    
    try {
      // Call API to remove item
      // await CategoryService.removeCategoryItem(arg, itemId);
      
      // Refresh to sync with server
      await refresh();
    } catch (error, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentItems);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ✅ Update item method
  Future<void> updateItem(CategoryItemModel updatedItem) async {
    final currentItems = state.value ?? [];
    final updatedItems = currentItems.map((item) =>
      item.id == updatedItem.id ? updatedItem : item
    ).toList();
    
    // Optimistically update
    state = AsyncValue.data(updatedItems);
    
    try {
      // Call API to update item
      // await CategoryService.updateCategoryItem(arg, updatedItem);
      
      // Refresh to sync with server
      await refresh();
    } catch (error, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentItems);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ✅ Get items by multiple categories
  List<CategoryItemModel> getMultiCategoryItems() {
    final items = state.value ?? [];
    return items.where((item) => item.isMultiCategory).toList();
  }

  // ✅ Get items by specific category
  List<CategoryItemModel> getItemsByCategory(String categoryId) {
    final items = state.value ?? [];
    return items.where((item) => item.belongsToCategory(categoryId)).toList();
  }

  // ✅ Get item count
  int get itemCount => state.value?.length ?? 0;

  // ✅ Check if category is empty
  bool get isEmpty => itemCount == 0;

  // ✅ Get loading state
  bool get isLoading => state.isLoading;

  // ✅ Get error message
  String? get errorMessage => state.hasError ? state.error.toString() : null;
}

// ✅ Optional: Provider for category statistics
final categoryStatsProvider = Provider.family<CategoryStats, String>((ref, categoryId) {
  final itemsAsync = ref.watch(categoryItemsNotifierProvider(categoryId));
  
  return itemsAsync.when(
    data: (items) => CategoryStats.fromItems(items),
    loading: () => CategoryStats.empty(),
    error: (_, __) => CategoryStats.empty(),
  );
});

// ✅ Updated Stats model without recyclable functionality
class CategoryStats {
  final int totalItems;
  final int multiCategoryItems;
  final int singleCategoryItems;
  
  const CategoryStats({
    required this.totalItems,
    required this.multiCategoryItems,
    required this.singleCategoryItems,
  });
  
  factory CategoryStats.fromItems(List<CategoryItemModel> items) {
    return CategoryStats(
      totalItems: items.length,
      multiCategoryItems: items.where((item) => item.isMultiCategory).length,
      singleCategoryItems: items.where((item) => !item.isMultiCategory).length,
    );
  }
  
  factory CategoryStats.empty() {
    return const CategoryStats(
      totalItems: 0,
      multiCategoryItems: 0,
      singleCategoryItems: 0,
    );
  }
  
  // ✅ Updated percentage calculation for multi-category items
  double get multiCategoryPercentage => 
    totalItems > 0 ? (multiCategoryItems / totalItems) * 100 : 0;
}