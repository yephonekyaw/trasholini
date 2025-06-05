import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

class ScanState {
  final bool isProcessing;
  final String? lastScannedImagePath;
  final Map<String, dynamic>? lastAnalysisResult;
  final String? error;

  const ScanState({
    this.isProcessing = false,
    this.lastScannedImagePath,
    this.lastAnalysisResult,
    this.error,
  });

  ScanState copyWith({
    bool? isProcessing,
    String? lastScannedImagePath,
    Map<String, dynamic>? lastAnalysisResult,
    String? error,
  }) {
    return ScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastScannedImagePath: lastScannedImagePath ?? this.lastScannedImagePath,
      lastAnalysisResult: lastAnalysisResult ?? this.lastAnalysisResult,
      error: error ?? this.error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState());

  final AIService _aiService = AIService();

  Future<Map<String, dynamic>> processImage(String imagePath) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final result = await _aiService.analyzeImage(imagePath);
      state = state.copyWith(
        isProcessing: false,
        lastScannedImagePath: imagePath,
        lastAnalysisResult: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});