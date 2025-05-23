import 'package:flutter/material.dart';
import 'package:flutter_client/presentations/error/main_error_screen.dart';

// Standalone error page for custom error scenarios
class CustomErrorPage extends StatelessWidget {
  final String title;
  final String message;

  const CustomErrorPage({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MainErrorScreen(error: Exception('$title: $message'));
  }
}
