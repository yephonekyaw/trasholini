import 'package:flutter_client/models/google_user_data_model.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/services/apis/auth_api_service.dart';
import 'package:flutter_client/services/apis/profile_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return UserProfileNotifier(ref);
    });

// Provider for tracking profile update loading state
final profileUpdateLoadingProvider = StateProvider<bool>((ref) => false);

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;
  final AuthApiService _authApiService = AuthApiService();
  final ProfileApiService _profileApiService = ProfileApiService();

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Listen to changes in Google Auth
    _ref.listen<AsyncValue<GoogleUserData?>>(googleAuthProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (googleUser) {
          if (googleUser != null) {
            _fetchUserProfile(googleUser);
          } else {
            state = const AsyncValue.data(null);
          }
        },
        loading: () => state = const AsyncValue.loading(),
        error: (e, st) => state = AsyncValue.error(e, st),
      );
    }, fireImmediately: true);
  }

  Future<void> _fetchUserProfile(GoogleUserData googleUser) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = await _authApiService.authenticateUser(
        googleId: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
      state = AsyncValue.data(userProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update user profile with new display name and/or profile image
  Future<void> updateProfile({String? displayName, String? imagePath}) async {
    try {
      // Set loading state
      _ref.read(profileUpdateLoadingProvider.notifier).state = true;

      // Call the profile API service
      final response = await _profileApiService.updateProfile(
        displayName: displayName,
        imagePath: imagePath,
      );

      if (response.success) {
        // Update the current state with the new profile data
        state = AsyncValue.data(response.userProfile);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Don't change the main state, just throw the error to be handled by the UI
      rethrow;
    } finally {
      // Clear loading state
      _ref.read(profileUpdateLoadingProvider.notifier).state = false;
    }
  }

  /// Refresh user profile from the server
  Future<void> refreshProfile() async {
    try {
      state = const AsyncValue.loading();
      final userProfile = await _profileApiService.getCurrentProfile();
      state = AsyncValue.data(userProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update only the display name
  Future<void> updateDisplayName(String displayName) async {
    await updateProfile(displayName: displayName);
  }

  /// Update only the profile image
  Future<void> updateProfileImage(String imagePath) async {
    await updateProfile(imagePath: imagePath);
  }

  /// Get current user profile (synchronous access to current state)
  UserProfile? get currentProfile {
    return state.value;
  }

  /// Check if user profile is currently loading
  bool get isLoading {
    return state.isLoading;
  }

  /// Get current error if any
  Object? get error {
    return state.error;
  }
}
