import 'package:flutter_client/services/apis/danger_deletion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class DeletionPreviewState {
  final DeletionPreview? preview;
  final bool isLoading;
  final String? error;

  const DeletionPreviewState({
    this.preview,
    this.isLoading = false,
    this.error,
  });

  DeletionPreviewState copyWith({
    DeletionPreview? preview,
    bool? isLoading,
    String? error,
  }) {
    return DeletionPreviewState(
      preview: preview ?? this.preview,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserDeletionState {
  final UserDeletionResponse? deletionResponse;
  final bool isDeleting;
  final String? error;
  final bool deletionCompleted;

  const UserDeletionState({
    this.deletionResponse,
    this.isDeleting = false,
    this.error,
    this.deletionCompleted = false,
  });

  UserDeletionState copyWith({
    UserDeletionResponse? deletionResponse,
    bool? isDeleting,
    String? error,
    bool? deletionCompleted,
  }) {
    return UserDeletionState(
      deletionResponse: deletionResponse ?? this.deletionResponse,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error,
      deletionCompleted: deletionCompleted ?? this.deletionCompleted,
    );
  }
}

// Service provider
final dangerServiceProvider = Provider<DangerService>((ref) {
  return DangerService();
});

// Deletion Preview Provider
class DeletionPreviewNotifier extends StateNotifier<DeletionPreviewState> {
  final DangerService _service;

  DeletionPreviewNotifier(this._service) : super(const DeletionPreviewState());

  /// Load deletion preview (safe operation)
  Future<void> loadPreview() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('DeletionPreviewNotifier: Loading deletion preview');

      final preview = await _service.previewDeletion();

      state = state.copyWith(preview: preview, isLoading: false, error: null);

      debugPrint(
        'DeletionPreviewNotifier: Preview loaded successfully - '
        '${preview.estimatedTotalItems} items to delete',
      );
    } catch (e) {
      debugPrint('DeletionPreviewNotifier: Error loading preview: $e');

      String errorMessage = 'Failed to load deletion preview';

      if (e is DeletionException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Refresh preview
  Future<void> refresh() async {
    await loadPreview();
  }

  /// Clear current state
  void clear() {
    state = const DeletionPreviewState();
  }
}

final deletionPreviewProvider =
    StateNotifierProvider<DeletionPreviewNotifier, DeletionPreviewState>((ref) {
      final service = ref.watch(dangerServiceProvider);
      return DeletionPreviewNotifier(service);
    });

// User Deletion Provider
class UserDeletionNotifier extends StateNotifier<UserDeletionState> {
  final DangerService _service;

  UserDeletionNotifier(this._service) : super(const UserDeletionState());

  /// ⚠️ DANGER: Delete all user data permanently
  /// This operation cannot be undone!
  Future<void> deleteAllUserData({
    required String userEmail,
    bool forceDelete = false,
  }) async {
    if (state.isDeleting) return;

    state = state.copyWith(
      isDeleting: true,
      error: null,
      deletionCompleted: false,
    );

    try {
      debugPrint('🚨 UserDeletionNotifier: INITIATING USER DATA DELETION');
      debugPrint('  - Email: $userEmail');
      debugPrint('  - Force delete: $forceDelete');

      final response = await _service.deleteAllUserData(
        userEmail: userEmail,
        forceDelete: forceDelete,
      );

      state = state.copyWith(
        deletionResponse: response,
        isDeleting: false,
        error: null,
        deletionCompleted: true,
      );

      debugPrint(
        '🚨 UserDeletionNotifier: Deletion completed - Success: ${response.success}',
      );
    } catch (e) {
      debugPrint('🚨 UserDeletionNotifier: Error during deletion: $e');

      String errorMessage = 'Failed to delete user data';

      if (e is DeletionConfirmationException) {
        errorMessage = 'Invalid confirmation. Please try again.';
      } else if (e is DeletionVerificationException) {
        errorMessage =
            'Email verification failed. Please check your email address.';
      } else if (e is DeletionException) {
        errorMessage = e.message;
      }

      state = state.copyWith(
        isDeleting: false,
        error: errorMessage,
        deletionCompleted: false,
      );
    }
  }

  /// Reset deletion state (useful after showing results)
  void resetDeletionState() {
    state = const UserDeletionState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final userDeletionProvider =
    StateNotifierProvider<UserDeletionNotifier, UserDeletionState>((ref) {
      final service = ref.watch(dangerServiceProvider);
      return UserDeletionNotifier(service);
    });

// Convenience providers for easier access to specific data

/// Get deletion preview data
final deletionPreviewDataProvider = Provider<DeletionPreview?>((ref) {
  return ref.watch(deletionPreviewProvider).preview;
});

/// Get deletion response data
final deletionResponseDataProvider = Provider<UserDeletionResponse?>((ref) {
  return ref.watch(userDeletionProvider).deletionResponse;
});

/// Check if preview is loading
final isPreviewLoadingProvider = Provider<bool>((ref) {
  return ref.watch(deletionPreviewProvider).isLoading;
});

/// Check if deletion is in progress
final isDeletingProvider = Provider<bool>((ref) {
  return ref.watch(userDeletionProvider).isDeleting;
});

/// Check if deletion is completed
final isDeletionCompletedProvider = Provider<bool>((ref) {
  return ref.watch(userDeletionProvider).deletionCompleted;
});

/// Check if any danger operation is loading
final isAnyDangerOperationLoadingProvider = Provider<bool>((ref) {
  final previewLoading = ref.watch(isPreviewLoadingProvider);
  final deletionInProgress = ref.watch(isDeletingProvider);

  return previewLoading || deletionInProgress;
});

/// Get preview error
final previewErrorProvider = Provider<String?>((ref) {
  return ref.watch(deletionPreviewProvider).error;
});

/// Get deletion error
final deletionErrorProvider = Provider<String?>((ref) {
  return ref.watch(userDeletionProvider).error;
});

/// Get any danger operation error
final anyDangerErrorProvider = Provider<String?>((ref) {
  final previewError = ref.watch(previewErrorProvider);
  final deletionError = ref.watch(deletionErrorProvider);

  return deletionError ?? previewError;
});

/// Check if user has any data to delete
final hasDataToDeleteProvider = Provider<bool>((ref) {
  final preview = ref.watch(deletionPreviewDataProvider);
  return preview?.estimatedTotalItems != null &&
      preview!.estimatedTotalItems > 0;
});

/// Get total items that would be deleted
final totalItemsToDeleteProvider = Provider<int>((ref) {
  final preview = ref.watch(deletionPreviewDataProvider);
  return preview?.estimatedTotalItems ?? 0;
});

/// Get deletion summary if available
final deletionSummaryProvider = Provider<DeletionSummary?>((ref) {
  final response = ref.watch(deletionResponseDataProvider);
  return response?.summary;
});

/// Check if deletion was successful
final wasDeletionSuccessfulProvider = Provider<bool?>((ref) {
  final response = ref.watch(deletionResponseDataProvider);
  return response?.success;
});

// Utility providers for validation

/// Validate email format
final emailValidatorProvider = Provider.family<bool, String>((ref, email) {
  return DangerService.isValidEmail(email);
});

/// Get required confirmation text
final requiredConfirmationTextProvider = Provider<String>((ref) {
  return DangerService.requiredConfirmationText;
});

/// Validate confirmation text
final confirmationValidatorProvider = Provider.family<bool, String>((
  ref,
  text,
) {
  final required = ref.watch(requiredConfirmationTextProvider);
  return text == required;
});

// Combined state providers for UI convenience

/// Combined danger operation state for UI
class DangerOperationState {
  final bool isLoading;
  final String? error;
  final DeletionPreview? preview;
  final UserDeletionResponse? deletionResponse;
  final bool isDeletionCompleted;

  const DangerOperationState({
    required this.isLoading,
    this.error,
    this.preview,
    this.deletionResponse,
    required this.isDeletionCompleted,
  });
}

final dangerOperationStateProvider = Provider<DangerOperationState>((ref) {
  final isLoading = ref.watch(isAnyDangerOperationLoadingProvider);
  final error = ref.watch(anyDangerErrorProvider);
  final preview = ref.watch(deletionPreviewDataProvider);
  final deletionResponse = ref.watch(deletionResponseDataProvider);
  final isDeletionCompleted = ref.watch(isDeletionCompletedProvider);

  return DangerOperationState(
    isLoading: isLoading,
    error: error,
    preview: preview,
    deletionResponse: deletionResponse,
    isDeletionCompleted: isDeletionCompleted,
  );
});

// Action providers for common operations

/// Provider for triggering preview load
final loadPreviewActionProvider = Provider<VoidCallback>((ref) {
  return () {
    ref.read(deletionPreviewProvider.notifier).loadPreview();
  };
});

/// Provider for triggering user deletion
final deleteUserDataActionProvider =
    Provider.family<Future<void> Function({bool forceDelete}), String>((
      ref,
      userEmail,
    ) {
      return ({bool forceDelete = false}) {
        return ref
            .read(userDeletionProvider.notifier)
            .deleteAllUserData(userEmail: userEmail, forceDelete: forceDelete);
      };
    });

/// Provider for resetting all danger states
final resetAllDangerStatesActionProvider = Provider<VoidCallback>((ref) {
  return () {
    ref.read(deletionPreviewProvider.notifier).clear();
    ref.read(userDeletionProvider.notifier).resetDeletionState();
  };
});
