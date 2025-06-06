import 'package:flutter/material.dart';
import 'package:flutter_client/widgets/error/action_button.dart';
import 'package:go_router/go_router.dart';

class MainErrorScreen extends StatelessWidget {
  final GoRouterState? state;
  final Exception? error;

  const MainErrorScreen({super.key, this.state, this.error});

  @override
  Widget build(BuildContext context) {
    // Determine error type and customize message
    final isNotFound = state?.error?.toString().contains('404') ?? true;
    final errorCode = isNotFound ? '404' : 'Error';
    final errorTitle = isNotFound ? 'Page Not Found' : 'Something Went Wrong';
    final errorMessage =
        isNotFound
            ? 'The page you\'re looking for doesn\'t exist or has been moved.'
            : 'We encountered an unexpected error. Please try again.';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error Code
                  Text(
                    errorCode,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error Title
                  Text(
                    errorTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Error Message
                  Text(
                    errorMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  Column(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Go Back Button
                      if (context.canPop())
                        ActionButton(
                          onPressed: () => context.pop(),
                          icon: Icons.arrow_back,
                          label: 'Go Back',
                          isPrimary: false,
                        ),

                      if (context.canPop()) const SizedBox(width: 16),

                      // Go Home Button
                      ActionButton(
                        onPressed: () => context.go('/'),
                        icon: Icons.home,
                        label: 'Go Home',
                        isPrimary: true,
                      ),
                    ],
                  ),

                  // Debug Info (only in debug mode)
                  if (const bool.fromEnvironment('dart.vm.product') ==
                      false) ...[
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Path: ${state?.matchedLocation ?? 'Unknown'}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (error != null)
                            Text(
                              'Error: ${error.toString()}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
