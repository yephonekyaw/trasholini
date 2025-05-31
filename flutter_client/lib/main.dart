// import 'package:flutter/material.dart';
// import 'package:flutter_client/router/router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(ProviderScope(child: TrasholiniApp()));
// }

// class TrasholiniApp extends ConsumerWidget {
//   const TrasholiniApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);
//     return MaterialApp.router(
//       routerConfig: router,
//       title: 'Trasholini',
//       theme: ThemeData(
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         useMaterial3: true,
//         splashFactory: NoSplash.splashFactory,
//         dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: TrasholiniApp()));
}

class TrasholiniApp extends ConsumerWidget {
  const TrasholiniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Trasholini',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}