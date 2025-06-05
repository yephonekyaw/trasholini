import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trash_bin/trash_bin.dart'; // Import the TrashBin model

// State Notifier for managing trash bin selection
class TrashBinNotifier extends StateNotifier<List<TrashBin>> {
  TrashBinNotifier() : super(_initialBins);

  // Initial trash bins data with image assets
  static final List<TrashBin> _initialBins = [
    TrashBin(
      id: 'green',
      name: 'Green Bin',
      description: 'Green Waste',
      color: const Color(0xFF4CAF50),
      imagePath: 'assets/trash_images/green.png',
    ),
    TrashBin(
      id: 'red',
      name: 'Red Bin',
      description: 'B3 waste',
      color: const Color(0xFFf44336),
      imagePath: 'assets/trash_images/red.png',
    ),
    TrashBin(
      id: 'yellow',
      name: 'Yellow Bin',
      description: 'Anorganic Waste',
      color: const Color(0xFFFFEB3B),
      imagePath: 'assets/trash_images/yellow.png',
    ),
    TrashBin(
      id: 'blue',
      name: 'Blue Bin',
      description: 'Recyclables',
      color: const Color(0xFF2196F3),
      imagePath: 'assets/trash_images/blue.png',
    ),
    TrashBin(
      id: 'grey',
      name: 'Grey Bin',
      description: 'Residual Waste',
      color: const Color(0xFF9E9E9E),
      imagePath: 'assets/trash_images/grey.png',
    ),
  ];

  /// Toggle selection state of a specific trash bin
  void toggleBinSelection(String binId) {
    state = state.map((bin) {
      if (bin.id == binId) {
        return bin.copyWith(isSelected: !bin.isSelected);
      }
      return bin;
    }).toList();
  }

  /// Select a specific trash bin
  void selectBin(String binId) {
    state = state.map((bin) {
      if (bin.id == binId) {
        return bin.copyWith(isSelected: true);
      }
      return bin;
    }).toList();
  }

  /// Deselect a specific trash bin
  void deselectBin(String binId) {
    state = state.map((bin) {
      if (bin.id == binId) {
        return bin.copyWith(isSelected: false);
      }
      return bin;
    }).toList();
  }

  /// Select all trash bins
  void selectAllBins() {
    state = state.map((bin) => bin.copyWith(isSelected: true)).toList();
  }

  /// Deselect all trash bins
  void deselectAllBins() {
    state = state.map((bin) => bin.copyWith(isSelected: false)).toList();
  }

  /// Reset all bins to initial state (unselected)
  void resetBins() {
    state = _initialBins;
  }

  /// Set selection state for multiple bins
  void setMultipleBinSelection(List<String> binIds, bool isSelected) {
    state = state.map((bin) {
      if (binIds.contains(bin.id)) {
        return bin.copyWith(isSelected: isSelected);
      }
      return bin;
    }).toList();
  }

  /// Get a specific bin by ID
  TrashBin? getBinById(String binId) {
    try {
      return state.firstWhere((bin) => bin.id == binId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a specific bin is selected
  bool isBinSelected(String binId) {
    final bin = getBinById(binId);
    return bin?.isSelected ?? false;
  }

  /// Get list of selected bins
  List<TrashBin> get selectedBins {
    return state.where((bin) => bin.isSelected).toList();
  }

  /// Get list of unselected bins
  List<TrashBin> get unselectedBins {
    return state.where((bin) => !bin.isSelected).toList();
  }

  /// Check if all bins are selected
  bool get allSelected {
    return state.isNotEmpty && state.every((bin) => bin.isSelected);
  }

  /// Check if no bins are selected
  bool get noneSelected {
    return state.every((bin) => !bin.isSelected);
  }

  /// Get count of selected bins
  int get selectedCount {
    return state.where((bin) => bin.isSelected).length;
  }

  /// Get count of unselected bins
  int get unselectedCount {
    return state.where((bin) => !bin.isSelected).length;
  }

  /// Get total count of bins
  int get totalCount {
    return state.length;
  }

  /// Get list of selected bin IDs
  List<String> get selectedBinIds {
    return selectedBins.map((bin) => bin.id).toList();
  }

  /// Get list of selected bin names
  List<String> get selectedBinNames {
    return selectedBins.map((bin) => bin.name).toList();
  }
}

// Main provider
final trashBinProvider = StateNotifierProvider<TrashBinNotifier, List<TrashBin>>(
  (ref) => TrashBinNotifier(),
);

// Computed providers for convenient access
final selectedBinsProvider = Provider<List<TrashBin>>((ref) {
  final bins = ref.watch(trashBinProvider);
  return bins.where((bin) => bin.isSelected).toList();
});

final selectedBinCountProvider = Provider<int>((ref) {
  final selectedBins = ref.watch(selectedBinsProvider);
  return selectedBins.length;
});

final allBinsSelectedProvider = Provider<bool>((ref) {
  final bins = ref.watch(trashBinProvider);
  return bins.isNotEmpty && bins.every((bin) => bin.isSelected);
});

final noneBinsSelectedProvider = Provider<bool>((ref) {
  final bins = ref.watch(trashBinProvider);
  return bins.every((bin) => !bin.isSelected);
});

// Provider for getting a specific bin by ID
final binByIdProvider = Provider.family<TrashBin?, String>((ref, binId) {
  final bins = ref.watch(trashBinProvider);
  try {
    return bins.firstWhere((bin) => bin.id == binId);
  } catch (e) {
    return null;
  }
});

// Provider to check if a specific bin is selected
final isBinSelectedProvider = Provider.family<bool, String>((ref, binId) {
  final bin = ref.watch(binByIdProvider(binId));
  return bin?.isSelected ?? false;
});