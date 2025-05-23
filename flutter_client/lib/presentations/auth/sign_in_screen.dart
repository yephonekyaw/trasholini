import 'package:flutter/material.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/widgets/auth/google_sign_in_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAuthState = ref.watch(googleAuthProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),

                // App Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.recycling,
                    size: 80,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 48),

                // App Name
                const Text(
                  'Trasholini',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Tagline
                const Text(
                  'Scan. Sort. Save the planet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Sign In Button
                googleAuthState.when(
                  data:
                      (_) => GoogleSignInButton(
                        onPressed: () {
                          ref.read(googleAuthProvider.notifier).signIn();
                        },
                      ),
                  loading:
                      () => Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF43A047),
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                  error:
                      (error, _) => Column(
                        children: [
                          GoogleSignInButton(
                            onPressed: () {
                              ref.read(googleAuthProvider.notifier).signIn();
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong. Please try again.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 32),

                // Terms
                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
