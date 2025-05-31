import 'package:flutter_client/presentations/home/home_screen.dart';
import 'package:flutter_client/presentations/scan/catergory_detail_page.dart';
import 'package:flutter_client/presentations/scan/disposal_instruction_page.dart';
import 'package:flutter_client/presentations/scan/scan_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        name: "home",
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => ScanPage()),
      GoRoute(
        path: '/category-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryDetailsPage(
            imagePath: extra?['imagePath'] as String? ?? '',
            analysisResult:
                extra?['analysisResult'] as Map<String, dynamic>? ?? {},
          );
        },
      ),
      GoRoute(
        path: '/disposal-instructions',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DisposalInstructionsPage(
            imagePath: extra?['imagePath'] as String? ?? '',
            analysisResult:
                extra?['analysisResult'] as Map<String, dynamic>? ?? {},
          );
        },
      ),
    ],
  );

  return router;
});
