import 'package:flutter_client/models/google_user_data_model.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/services/auth_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return UserProfileNotifier(ref);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;
  final AuthApiService _authApiService = AuthApiService();

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
}
