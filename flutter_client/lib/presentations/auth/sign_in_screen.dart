import 'package:flutter/material.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:flutter_client/widgets/auth/static_waste_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleAuthState = ref.watch(googleAuthProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey background
      body: Stack(
        children: [
          // Static background icons in fixed grid positions
          ...List.generate(
            15,
            (index) => StaticWasteIcon(
              key: Key('waste_icon_$index'),
              screenSize: screenSize,
              gridIndex: index,
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // App Icon with subtle shadow
                  _buildAppIcon(),

                  const SizedBox(height: 48),

                  // App Name
                  _buildAppName(),

                  const SizedBox(height: 16),

                  // Tagline in bordered container
                  _buildTagline(),

                  const SizedBox(height: 40),

                  // Feature highlights - properly aligned
                  _buildFeatureList(),

                  const Spacer(flex: 2),

                  // Sign In Button
                  _buildSignInSection(googleAuthState, ref),

                  const SizedBox(height: 32),

                  // Terms
                  _buildTermsText(),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: .1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.recycling, size: 80, color: Colors.green),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [Colors.blue[500]!, Colors.teal[400]!, Colors.cyan[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: const Text(
        'Trasholini',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Colors.white, // This will be masked by the gradient
          letterSpacing: -1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[300]!, width: 1.5),
        borderRadius: BorderRadius.circular(25),
        color: Colors.green[50]?.withValues(alpha: .7),
      ),
      child: Text(
        'Scan. Sort. Save the planet.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.green[700],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureRow(
          icon: Icons.camera_alt_outlined,
          text: 'AI-powered waste scanning',
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildFeatureRow(
          icon: Icons.eco_outlined,
          text: 'Earn points for eco-actions',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildFeatureRow(
          icon: Icons.insights_outlined,
          text: 'Track your impact',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        // Fixed width container for icon alignment
        SizedBox(
          width: 40,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInSection(AsyncValue googleAuthState, WidgetRef ref) {
    return googleAuthState.when(
      data:
          (_) => _buildSignInButton(
            onPressed: () {
              ref.read(googleAuthProvider.notifier).signIn();
            },
          ),
      loading: () => _buildLoadingButton(),
      error:
          (error, _) => Column(
            children: [
              _buildSignInButton(
                onPressed: () {
                  ref.read(googleAuthProvider.notifier).signIn();
                },
              ),
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
          ),
    );
  }

  Widget _buildSignInButton({required VoidCallback onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: Colors.red[600], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By continuing, you agree to our Terms & Privacy Policy',
      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
      textAlign: TextAlign.center,
    );
  }
}
