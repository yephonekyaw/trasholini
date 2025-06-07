import 'package:flutter_client/services/apis/waste_analysis_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_client/services/apis/waste_analysis_service.dart'
    show WasteAnalysisResult, RecommendedBin;

// State classes
class WasteAnalysisState {
  final bool isLoading;
  final bool isSaving;
  final WasteAnalysisResult? result;
  final String? error;

  WasteAnalysisState({
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
  });

  WasteAnalysisState copyWith({
    bool? isLoading,
    bool? isSaving,
    WasteAnalysisResult? result,
    String? error,
  }) {
    return WasteAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

// Provider
class WasteAnalysisNotifier extends StateNotifier<WasteAnalysisState> {
  WasteAnalysisNotifier() : super(WasteAnalysisState()) {
    _initializeService();
  }

  final WasteAnalysisService _service = WasteAnalysisService();

  Future<void> _initializeService() async {
    try {
      await _service.initialize();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize service: $e');
    }
  }

  Future<WasteAnalysisResult> analyzeWaste(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if service is ready
      final isReady = await _service.isServiceReady();
      if (!isReady) {
        throw Exception('Service not ready. Please ensure you are logged in.');
      }

      // Analyze the waste
      final result = await _service.analyzeWaste(imagePath);

      state = state.copyWith(isLoading: false, result: result);

      return result;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      state = state.copyWith(isLoading: false, error: errorMessage);

      throw Exception(errorMessage);
    }
  }

  /// Save disposal tips to user's history
  Future<Map<String, dynamic>> saveTips({
    required String imagePath,
    required WasteAnalysisResult result,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      // Check if service is ready
      final isReady = await _service.isServiceReady();
      if (!isReady) {
        throw Exception('Service not ready. Please ensure you are logged in.');
      }

      // Save the tips
      final saveResult = await _service.saveTips(
        imagePath: imagePath,
        result: result,
      );

      state = state.copyWith(isSaving: false);

      return saveResult;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      state = state.copyWith(isSaving: false, error: errorMessage);

      throw Exception(errorMessage);
    }
  }

  /// Get user's disposal history
  Future<List<Map<String, dynamic>>> getDisposalHistory({
    int limit = 20,
  }) async {
    try {
      // Check if service is ready
      final isReady = await _service.isServiceReady();
      if (!isReady) {
        throw Exception('Service not ready. Please ensure you are logged in.');
      }

      return await _service.getDisposalHistory(limit: limit);
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      state = state.copyWith(error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<void> refreshAuth() async {
    try {
      await _service.refreshAuth();
    } catch (e) {
      state = state.copyWith(error: 'Failed to refresh authentication: $e');
    }
  }

  String _extractErrorMessage(dynamic error) {
    // Handle different types of exceptions from DioClient
    if (error.toString().contains('UnauthorizedException')) {
      return 'Please login to use this feature';
    } else if (error.toString().contains('NetworkException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('ConnectionTimeoutException')) {
      return 'Connection timeout. Please try again.';
    } else if (error.toString().contains('ServerException')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('BadRequestException')) {
      return 'Invalid image. Please try a different photo.';
    } else if (error.toString().contains('ValidationException')) {
      return 'Invalid request. Please check your image and try again.';
    } else {
      // Extract the actual error message, removing "Exception: " prefix
      String message = error.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return message;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = WasteAnalysisState();
  }
}

// Provider instances
final wasteAnalysisProvider =
    StateNotifierProvider<WasteAnalysisNotifier, WasteAnalysisState>(
      (ref) => WasteAnalysisNotifier(),
    );

// Helper provider to get just the result
final wasteAnalysisResultProvider = Provider<WasteAnalysisResult?>((ref) {
  return ref.watch(wasteAnalysisProvider).result;
});

// Helper provider to check if loading
final wasteAnalysisLoadingProvider = Provider<bool>((ref) {
  return ref.watch(wasteAnalysisProvider).isLoading;
});

// Helper provider to get error
final wasteAnalysisErrorProvider = Provider<String?>((ref) {
  return ref.watch(wasteAnalysisProvider).error;
});
// Helper provider to check if saving
final wasteAnalysisSavingProvider = Provider<bool>((ref) {
  return ref.watch(wasteAnalysisProvider).isSaving;
});
