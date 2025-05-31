import 'package:flutter_client/presentations/home/home_screen.dart';
import 'package:flutter_client/presentations/main/main_page.dart';

import 'package:flutter_client/presentations/profile/profile_page.dart';
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

       GoRoute(
        path: "/main",
        name: "mainpage",
        builder: (context, state) => const MainPage(),
      ),

      GoRoute(
        path: "/profile",
        name: "profilepage",
        builder: (context, state) => const ProfilePage(),
      ),

       
    ],
   
  );

  return router;
});
