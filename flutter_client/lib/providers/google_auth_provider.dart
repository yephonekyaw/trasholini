import 'package:flutter_client/models/google_user_data_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthNotifier extends StateNotifier<AsyncValue<GoogleUserData?>> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleAuthNotifier() : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Try to sign in silently on app start
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final googleUser = GoogleUserData(
          id: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        );
        state = AsyncValue.data(googleUser);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final googleUser = GoogleUserData(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );

      state = AsyncValue.data(googleUser);
    } catch (e, st) {
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
      await _googleSignIn.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final googleAuthProvider =
    StateNotifierProvider<GoogleAuthNotifier, AsyncValue<GoogleUserData?>>(
      (ref) => GoogleAuthNotifier(),
    );
