import 'package:flutter_client/presentations/auth/sign_in_screen.dart';
import 'package:flutter_client/presentations/error/main_error_screen.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/presentations/main/main_page.dart';
import 'package:flutter_client/presentations/profile/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final googleAuthState = ref.watch(googleAuthProvider);

  final router = GoRouter(
    initialLocation: "/",
    redirect: (context, state) {
      final isLoggedIn = googleAuthState.value != null;
      final isLoggingIn = state.matchedLocation == '/signin';

      if (!isLoggedIn && !isLoggingIn) {
        return '/signin';
      } else if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: "/signin",
        name: "signin",
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: "/",
        name: "mainpage",
        builder: (context, state) => const MainPage(),
      ),

      GoRoute(
        path: "/profile",
        name: "profilepage",
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder: (context, state) => MainErrorScreen(),
  );

  return router;
});
