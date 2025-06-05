import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'constants.dart';

class Utility {

  // File operations
  static Future<String> getAppDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> saveImageToLocal(String imagePath) async {
    final appDir = await getAppDocumentsPath();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final localPath = path.join(appDir, 'scanned_images', fileName);
    
    // Create directory if it doesn't exist
    final directory = Directory(path.dirname(localPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Copy file to local storage
    final originalFile = File(imagePath);
    await originalFile.copy(localPath);
    
    return localPath;
  }

  // Image processing utilities
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Date formatting
  static String formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$month $day, $year - $hour:$minute';
  }

  // Location utilities
  static String getCurrentLocation() {
    // For demo purposes - replace with actual location service
    return 'Bangkok, Thailand';
  }

  // Validation utilities
  static bool isValidImagePath(String? path) {
    if (path == null || path.isEmpty) return false;
    final file = File(path);
    return file.existsSync();
  }

  // Error handling
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  // UI helpers
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppConstants.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    );
  }

  // Animation helpers
  static Widget fadeInWidget(Widget child, {Duration duration = AppConstants.defaultAnimationDuration}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}