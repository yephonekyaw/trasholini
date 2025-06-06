import 'package:flutter_client/presentations/auth/account_deletion_screen.dart';
import 'package:flutter_client/presentations/auth/sign_in_screen.dart';
import 'package:flutter_client/presentations/category/waste_items_page.dart';
import 'package:flutter_client/presentations/error/main_error_screen.dart';
import 'package:flutter_client/presentations/scan/image_preview_page.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/presentations/main/main_page.dart';
import 'package:flutter_client/presentations/profile/profile_page.dart';
import 'package:flutter_client/presentations/category/category_page.dart';
import 'package:flutter_client/presentations/trash_bin/trash_bin.dart';
import 'package:flutter_client/presentations/scan/disposal_instruction_page.dart';
import 'package:flutter_client/presentations/scan/scan_page.dart';
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
      GoRoute(
        path: "/categories",
        name: "categories",
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: "/trash",
        name: "trash",
        builder: (context, state) => const TrashBinPage(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => ScanPage()),
      GoRoute(
        path: '/image-preview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ImagePreviewPage(
            imagePath: extra?['imagePath'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/disposal-instructions',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DisposalInstructionsPage(
            imagePath: extra?['imagePath'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/waste-items/:wasteClass',
        name: 'waste-items',
        builder: (context, state) {
          final wasteClass = state.pathParameters['wasteClass'] ?? '';

          return WasteItemsPage(wasteClass: wasteClass);
        },
      ),
      GoRoute(
        path: "/account-deletion",
        name: "account-deletion",
        builder: (context, state) => const AccountDeletionPage(),
      ),
    ],
    errorBuilder: (context, state) => MainErrorScreen(),
  );

  return router;
});
