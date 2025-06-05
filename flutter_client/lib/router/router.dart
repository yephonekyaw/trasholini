
import 'package:flutter_client/presentations/category/category_page.dart';
import 'package:flutter_client/presentations/home/home_screen.dart';
import 'package:flutter_client/presentations/trash_bin/trash_bin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        name: "home",
        builder:(context, state) => const HomeScreen(),
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
    ],
  );

  return router;
});
