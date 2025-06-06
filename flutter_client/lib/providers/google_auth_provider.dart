import 'package:flutter_client/models/google_user_data_model.dart';
import 'package:flutter_client/services/token_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthNotifier extends StateNotifier<AsyncValue<GoogleUserData?>> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TokenStorageService _tokenStorage = TokenStorageService();

  GoogleAuthNotifier() : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // First, check if we have stored user data
      final hasStoredData = await _tokenStorage.hasValidUserData();

      if (hasStoredData) {
        // Load user data from storage
        final userData = await _tokenStorage.getAllUserData();
        final googleUser = GoogleUserData(
          id: userData['userId']!,
          email: userData['email']!,
          displayName: userData['displayName'],
          photoUrl: userData['photoUrl'],
        );
        state = AsyncValue.data(googleUser);
        debugPrint('GoogleAuth: Loaded user from storage: ${googleUser.email}');
        return;
      }

      // If no stored data, try silent sign-in
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final googleUser = GoogleUserData(
          id: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        );

        // Store user data
        await _tokenStorage.storeUserData(
          userId: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        );

        state = AsyncValue.data(googleUser);
        debugPrint(
          'GoogleAuth: Silent sign-in successful: ${googleUser.email}',
        );
      } else {
        state = const AsyncValue.data(null);
        debugPrint('GoogleAuth: No existing authentication found');
      }
    } catch (e, st) {
      debugPrint('GoogleAuth: Initialization error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        state = const AsyncValue.data(null);
        debugPrint('GoogleAuth: Sign-in cancelled by user');
        return;
      }

      final googleUser = GoogleUserData(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );

      // Store user data in token storage
      await _tokenStorage.storeUserData(
        userId: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );

      state = AsyncValue.data(googleUser);
      debugPrint('GoogleAuth: Sign-in successful: ${googleUser.email}');
    } catch (e, st) {
      debugPrint('GoogleAuth: Sign-in error: $e');
      if (e.toString() == "popup_closed") {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear stored user data
      await _tokenStorage.clearUserData();

      state = const AsyncValue.data(null);
      debugPrint('GoogleAuth: Sign-out successful');
    } catch (e, st) {
      debugPrint('GoogleAuth: Sign-out error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Get current user ID from storage (useful for other services)
  Future<String?> getCurrentUserId() async {
    return await _tokenStorage.getUserId();
  }

  /// Check if user is currently authenticated
  Future<bool> isCurrentlyAuthenticated() async {
    return await _tokenStorage.isAuthenticated();
  }

  /// Force refresh user data from Google
  Future<void> refreshUserData() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final googleUser = GoogleUserData(
          id: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        );

        // Update stored data
        await _tokenStorage.storeUserData(
          userId: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        );

        state = AsyncValue.data(googleUser);
        debugPrint('GoogleAuth: User data refreshed: ${googleUser.email}');
      }
    } catch (e, st) {
      debugPrint('GoogleAuth: Refresh error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final googleAuthProvider =
    StateNotifierProvider<GoogleAuthNotifier, AsyncValue<GoogleUserData?>>(
      (ref) => GoogleAuthNotifier(),
    );
