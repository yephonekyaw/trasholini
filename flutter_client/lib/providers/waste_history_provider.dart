import 'package:flutter_client/models/waste_history_model.dart';
import 'package:flutter_client/services/apis/waste_history_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Date range filter class
class DateRangeFilter {
  final DateTime startDate;
  final DateTime endDate;
  final String?
  label; // Optional label for display (e.g., "This Week", "Last 30 Days")

  const DateRangeFilter({
    required this.startDate,
    required this.endDate,
    this.label,
  });

  @override
  String toString() {
    return 'DateRangeFilter(${startDate.toLocal().toString().split(' ')[0]} to ${endDate.toLocal().toString().split(' ')[0]})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeFilter &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

// State classes for managing loading and error states
class WasteHistoryState {
  final List<DisposalHistoryItem> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int totalCount;
  final String? currentFilter;
  final DateRangeFilter? dateRangeFilter;
  final bool isDeleting;

  const WasteHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.totalCount = 0,
    this.currentFilter,
    this.dateRangeFilter,
    this.isDeleting = false,
  });

  WasteHistoryState copyWith({
    List<DisposalHistoryItem>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? totalCount,
    String? currentFilter,
    DateRangeFilter? dateRangeFilter,
    bool clearDateRange = false,
    bool? isDeleting,
  }) {
    return WasteHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      currentFilter: currentFilter ?? this.currentFilter,
      dateRangeFilter:
          clearDateRange ? null : (dateRangeFilter ?? this.dateRangeFilter),
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class RecentScansState {
  final List<DisposalHistoryItem> items;
  final bool isLoading;
  final String? error;
  final bool isDeleting;

  const RecentScansState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isDeleting = false,
  });

  RecentScansState copyWith({
    List<DisposalHistoryItem>? items,
    bool? isLoading,
    String? error,
    bool? isDeleting,
  }) {
    return RecentScansState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class WasteClassesState {
  final List<String> wasteClasses;
  final bool isLoading;
  final String? error;
  final int totalRecords;

  const WasteClassesState({
    this.wasteClasses = const [],
    this.isLoading = false,
    this.error,
    this.totalRecords = 0,
  });

  WasteClassesState copyWith({
    List<String>? wasteClasses,
    bool? isLoading,
    String? error,
    int? totalRecords,
  }) {
    return WasteClassesState(
      wasteClasses: wasteClasses ?? this.wasteClasses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }
}

// Service provider
final wasteHistoryServiceProvider = Provider<WasteHistoryService>((ref) {
  return WasteHistoryService();
});

// Recent Scans Provider (first 5 items)
class RecentScansNotifier extends StateNotifier<RecentScansState> {
  final WasteHistoryService _service;

  RecentScansNotifier(this._service) : super(const RecentScansState());

  /// Load recent scans (default 5 items)
  Future<void> loadRecentScans({int limit = 5}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('RecentScansNotifier: Loading recent scans (limit: $limit)');

      final response = await _service.getRecentScans(limit: limit);

      state = state.copyWith(
        items: response.history,
        isLoading: false,
        error: null,
      );

      debugPrint(
        'RecentScansNotifier: Loaded ${response.history.length} recent scans',
      );
    } catch (e) {
      debugPrint('RecentScansNotifier: Error loading recent scans: $e');

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete an item from recent scans
  Future<bool> deleteItem(String itemId) async {
    if (state.isDeleting) return false;

    state = state.copyWith(isDeleting: true, error: null);

    try {
      debugPrint('RecentScansNotifier: Deleting item: $itemId');

      final deleteResponse = await _service.deleteDisposalItem(itemId: itemId);

      if (deleteResponse.success) {
        // Remove the item from current list
        final updatedItems =
            state.items.where((item) => item.id != itemId).toList();

        state = state.copyWith(
          items: updatedItems,
          isDeleting: false,
          error: null,
        );

        debugPrint('RecentScansNotifier: Successfully deleted item: $itemId');
        return true;
      } else {
        throw Exception('Delete failed: ${deleteResponse.message}');
      }
    } catch (e) {
      debugPrint('RecentScansNotifier: Error deleting item: $e');

      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }

  /// Refresh recent scans
  Future<void> refresh({int limit = 5}) async {
    await loadRecentScans(limit: limit);
  }

  /// Clear current state
  void clear() {
    state = const RecentScansState();
  }
}

final recentScansProvider =
    StateNotifierProvider<RecentScansNotifier, RecentScansState>((ref) {
      final service = ref.watch(wasteHistoryServiceProvider);
      return RecentScansNotifier(service);
    });

// Full Waste History Provider with filtering and date range support
class WasteHistoryNotifier extends StateNotifier<WasteHistoryState> {
  final WasteHistoryService _service;

  WasteHistoryNotifier(this._service) : super(const WasteHistoryState());

  /// Load all history with optional filtering
  Future<void> loadHistory({
    String? wasteClass,
    int? limit,
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;

    // If it's a new filter, reset the state
    if (wasteClass != state.currentFilter || refresh) {
      state = state.copyWith(
        items: [],
        isLoading: true,
        error: null,
        currentFilter: wasteClass,
        hasMore: true,
        clearDateRange: true, // Clear date range when loading regular history
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      debugPrint('WasteHistoryNotifier: Loading history');
      debugPrint('  - Waste class: ${wasteClass ?? 'All'}');
      debugPrint('  - Limit: ${limit ?? 'Default'}');
      debugPrint('  - Refresh: $refresh');

      final response = await _service.getDisposalHistory(
        wasteClass: wasteClass,
        limit: limit,
      );

      state = state.copyWith(
        items: response.history,
        isLoading: false,
        error: null,
        totalCount: response.count,
        hasMore: response.history.length == (limit ?? 50),
        currentFilter: wasteClass,
      );

      debugPrint(
        'WasteHistoryNotifier: Loaded ${response.history.length} items',
      );
    } catch (e) {
      debugPrint('WasteHistoryNotifier: Error loading history: $e');

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete an item from waste history
  Future<bool> deleteItem(String itemId) async {
    if (state.isDeleting) return false;

    state = state.copyWith(isDeleting: true, error: null);

    try {
      debugPrint('WasteHistoryNotifier: Deleting item: $itemId');

      final deleteResponse = await _service.deleteDisposalItem(itemId: itemId);

      if (deleteResponse.success) {
        // Remove the item from current list
        final updatedItems =
            state.items.where((item) => item.id != itemId).toList();
        final newTotalCount = state.totalCount > 0 ? state.totalCount - 1 : 0;

        state = state.copyWith(
          items: updatedItems,
          isDeleting: false,
          error: null,
          totalCount: newTotalCount,
        );

        debugPrint('WasteHistoryNotifier: Successfully deleted item: $itemId');
        return true;
      } else {
        throw Exception('Delete failed: ${deleteResponse.message}');
      }
    } catch (e) {
      debugPrint('WasteHistoryNotifier: Error deleting item: $e');

      state = state.copyWith(isDeleting: false, error: e.toString());
      return false;
    }
  }

  /// Load history within a specific date range
  Future<void> loadHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? wasteClass,
    int? limit,
    String? label,
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;

    final dateRange = DateRangeFilter(
      startDate: startDate,
      endDate: endDate,
      label: label,
    );

    // Reset state for new date range query
    state = state.copyWith(
      items: [],
      isLoading: true,
      error: null,
      currentFilter: wasteClass,
      dateRangeFilter: dateRange,
      hasMore: true,
    );

    try {
      debugPrint('WasteHistoryNotifier: Loading history by date range');
      debugPrint('  - Date range: ${dateRange.toString()}');
      debugPrint('  - Waste class: ${wasteClass ?? 'All'}');
      debugPrint('  - Limit: ${limit ?? 'Default'}');

      final response = await _service.getDisposalHistoryByDateRange(
        startDate: startDate,
        endDate: endDate,
        wasteClass: wasteClass,
        limit: limit,
      );

      state = state.copyWith(
        items: response.history,
        isLoading: false,
        error: null,
        totalCount: response.count,
        hasMore: response.history.length == (limit ?? 100),
        currentFilter: wasteClass,
        dateRangeFilter: dateRange,
      );

      debugPrint(
        'WasteHistoryNotifier: Loaded ${response.history.length} items for date range',
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryNotifier: Error loading history by date range: $e',
      );

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load history for the last N days
  Future<void> loadHistoryLastDays({
    required int days,
    String? wasteClass,
    int? limit,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    await loadHistoryByDateRange(
      startDate: startDate,
      endDate: endDate,
      wasteClass: wasteClass,
      limit: limit,
      label: days == 1 ? 'Today' : 'Last $days days',
      refresh: true,
    );
  }

  /// Load history for this week (Monday to Sunday)
  Future<void> loadHistoryThisWeek({String? wasteClass, int? limit}) async {
    try {
      debugPrint('WasteHistoryNotifier: Loading history for this week');

      final response = await _service.getDisposalHistoryThisWeek(
        wasteClass: wasteClass,
        limit: limit,
      );

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final endOfWeek = startDate.add(const Duration(days: 6));
      final endDate = DateTime(
        endOfWeek.year,
        endOfWeek.month,
        endOfWeek.day,
        23,
        59,
        59,
      );

      final dateRange = DateRangeFilter(
        startDate: startDate,
        endDate: endDate,
        label: 'This Week',
      );

      state = state.copyWith(
        items: response.history,
        isLoading: false,
        error: null,
        totalCount: response.count,
        hasMore: false, // Week data is typically complete
        currentFilter: wasteClass,
        dateRangeFilter: dateRange,
      );

      debugPrint(
        'WasteHistoryNotifier: Loaded ${response.history.length} items for this week',
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryNotifier: Error loading history for this week: $e',
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load history for this month
  Future<void> loadHistoryThisMonth({String? wasteClass, int? limit}) async {
    try {
      debugPrint('WasteHistoryNotifier: Loading history for this month');

      final response = await _service.getDisposalHistoryThisMonth(
        wasteClass: wasteClass,
        limit: limit,
      );

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final dateRange = DateRangeFilter(
        startDate: startDate,
        endDate: endDate,
        label: 'This Month',
      );

      state = state.copyWith(
        items: response.history,
        isLoading: false,
        error: null,
        totalCount: response.count,
        hasMore: false, // Month data is typically complete
        currentFilter: wasteClass,
        dateRangeFilter: dateRange,
      );

      debugPrint(
        'WasteHistoryNotifier: Loaded ${response.history.length} items for this month',
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryNotifier: Error loading history for this month: $e',
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load history filtered by waste class
  Future<void> loadByWasteClass({
    required String wasteClass,
    int? limit,
  }) async {
    await loadHistory(wasteClass: wasteClass, limit: limit, refresh: true);
  }

  /// Load all history (no filter)
  Future<void> loadAllHistory({int? limit}) async {
    await loadHistory(wasteClass: null, limit: limit, refresh: true);
  }

  /// Refresh current view (maintains current filters)
  Future<void> refresh() async {
    if (state.dateRangeFilter != null) {
      // Refresh with current date range
      await loadHistoryByDateRange(
        startDate: state.dateRangeFilter!.startDate,
        endDate: state.dateRangeFilter!.endDate,
        wasteClass: state.currentFilter,
        label: state.dateRangeFilter!.label,
        refresh: true,
      );
    } else {
      // Refresh regular history
      await loadHistory(wasteClass: state.currentFilter, refresh: true);
    }
  }

  /// Clear all filters and load default history
  Future<void> clearFilters() async {
    await loadHistory(wasteClass: null, refresh: true);
  }

  /// Load more items for pagination
  Future<void> loadMore({int limit = 20}) async {
    if (state.isLoading || !state.hasMore) return;

    try {
      debugPrint('WasteHistoryNotifier: Loading more items');

      // Note: This is a simplified pagination
      // For proper pagination, you'd need to implement offset/cursor-based pagination
      final response = await _service.getDisposalHistory(
        wasteClass: state.currentFilter,
        limit: limit,
      );

      // For now, we'll just append new items (this assumes the backend handles pagination)
      final updatedItems = [...state.items, ...response.history];

      state = state.copyWith(
        items: updatedItems,
        hasMore: response.history.length == limit,
        totalCount: state.totalCount + response.count,
      );

      debugPrint(
        'WasteHistoryNotifier: Loaded ${response.history.length} more items',
      );
    } catch (e) {
      debugPrint('WasteHistoryNotifier: Error loading more items: $e');
      // Don't update error state for load more failures
    }
  }

  /// Clear current state
  void clear() {
    state = const WasteHistoryState();
  }
}

final wasteHistoryProvider =
    StateNotifierProvider<WasteHistoryNotifier, WasteHistoryState>((ref) {
      final service = ref.watch(wasteHistoryServiceProvider);
      return WasteHistoryNotifier(service);
    });

// Waste Classes Provider
class WasteClassesNotifier extends StateNotifier<WasteClassesState> {
  final WasteHistoryService _service;

  WasteClassesNotifier(this._service) : super(const WasteClassesState());

  /// Load available waste classes
  Future<void> loadWasteClasses() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('WasteClassesNotifier: Loading waste classes');

      final response = await _service.getWasteClasses();

      state = state.copyWith(
        wasteClasses: response.wasteClasses,
        isLoading: false,
        error: null,
        totalRecords: response.totalRecords,
      );

      debugPrint(
        'WasteClassesNotifier: Loaded ${response.wasteClasses.length} waste classes',
      );
    } catch (e) {
      debugPrint('WasteClassesNotifier: Error loading waste classes: $e');

      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh waste classes
  Future<void> refresh() async {
    await loadWasteClasses();
  }

  /// Clear current state
  void clear() {
    state = const WasteClassesState();
  }
}

final wasteClassesProvider =
    StateNotifierProvider<WasteClassesNotifier, WasteClassesState>((ref) {
      final service = ref.watch(wasteHistoryServiceProvider);
      return WasteClassesNotifier(service);
    });

// Convenience providers for easier access to specific data

/// Get recent scans items
final recentScansItemsProvider = Provider<List<DisposalHistoryItem>>((ref) {
  return ref.watch(recentScansProvider).items;
});

/// Get waste history items
final wasteHistoryItemsProvider = Provider<List<DisposalHistoryItem>>((ref) {
  return ref.watch(wasteHistoryProvider).items;
});

/// Get available waste classes
final availableWasteClassesProvider = Provider<List<String>>((ref) {
  return ref.watch(wasteClassesProvider).wasteClasses;
});

/// Get current date range filter
final currentDateRangeProvider = Provider<DateRangeFilter?>((ref) {
  return ref.watch(wasteHistoryProvider).dateRangeFilter;
});

/// Get current waste class filter
final currentWasteClassFilterProvider = Provider<String?>((ref) {
  return ref.watch(wasteHistoryProvider).currentFilter;
});

/// Check if any filters are active
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final wasteClassFilter = ref.watch(currentWasteClassFilterProvider);
  final dateRangeFilter = ref.watch(currentDateRangeProvider);

  return wasteClassFilter != null || dateRangeFilter != null;
});

/// Check if recent scans are loading
final isRecentScansLoadingProvider = Provider<bool>((ref) {
  return ref.watch(recentScansProvider).isLoading;
});

/// Check if waste history is loading
final isWasteHistoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(wasteHistoryProvider).isLoading;
});

/// Check if waste classes are loading
final isWasteClassesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(wasteClassesProvider).isLoading;
});

/// Check if any history operation is loading
final isAnyHistoryLoadingProvider = Provider<bool>((ref) {
  final recentScansLoading = ref.watch(isRecentScansLoadingProvider);
  final wasteHistoryLoading = ref.watch(isWasteHistoryLoadingProvider);
  final wasteClassesLoading = ref.watch(isWasteClassesLoadingProvider);

  return recentScansLoading || wasteHistoryLoading || wasteClassesLoading;
});

/// Check if any delete operation is in progress
final isAnyDeletingProvider = Provider<bool>((ref) {
  final recentScansDeleting = ref.watch(recentScansProvider).isDeleting;
  final wasteHistoryDeleting = ref.watch(wasteHistoryProvider).isDeleting;

  return recentScansDeleting || wasteHistoryDeleting;
});

/// Get recent scans error
final recentScansErrorProvider = Provider<String?>((ref) {
  return ref.watch(recentScansProvider).error;
});

/// Get waste history error
final wasteHistoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(wasteHistoryProvider).error;
});

/// Get waste classes error
final wasteClassesErrorProvider = Provider<String?>((ref) {
  return ref.watch(wasteClassesProvider).error;
});

// Date range convenience providers

/// Provider for common date range options
final dateRangeOptionsProvider = Provider<List<DateRangeOption>>((ref) {
  final now = DateTime.now();

  return [
    DateRangeOption(
      label: 'Today',
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    ),
    DateRangeOption(
      label: 'Last 7 Days',
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    ),
    DateRangeOption(
      label: 'Last 30 Days',
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
    ),
    DateRangeOption(
      label: 'This Week',
      startDate: now.subtract(Duration(days: now.weekday - 1)),
      endDate: now.add(Duration(days: 7 - now.weekday)),
    ),
    DateRangeOption(
      label: 'This Month',
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    ),
  ];
});

/// Date range option model for UI
class DateRangeOption {
  final String label;
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeOption({
    required this.label,
    required this.startDate,
    required this.endDate,
  });
}

// Delete operation helpers
/// Provider to check if a specific item is being deleted
final isItemBeingDeletedProvider = Provider.family<bool, String>((ref, itemId) {
  final wasteHistoryState = ref.watch(wasteHistoryProvider);
  final recentScansState = ref.watch(recentScansProvider);

  return (wasteHistoryState.isDeleting || recentScansState.isDeleting);
});

/// Provider to perform delete operation
final deleteItemProvider = Provider((ref) {
  return (String itemId) async {
    final wasteHistoryNotifier = ref.read(wasteHistoryProvider.notifier);
    final recentScansNotifier = ref.read(recentScansProvider.notifier);

    // Try to delete from both providers (the one that doesn't have the item will ignore it)
    final wasteHistoryResult = await wasteHistoryNotifier.deleteItem(itemId);
    final recentScansResult = await recentScansNotifier.deleteItem(itemId);

    return wasteHistoryResult || recentScansResult;
  };
});
