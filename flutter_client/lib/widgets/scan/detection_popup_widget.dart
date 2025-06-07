import 'package:flutter/material.dart';
import 'package:flutter_client/services/scan/websocket.dart';

/// Minimalist widget that shows the current detection result
class MinimalistDetectionWidget extends StatelessWidget {
  final WasteDetectionResult? detection;
  final bool isDetecting;

  const MinimalistDetectionWidget({
    super.key,
    this.detection,
    this.isDetecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (detection == null && !isDetecting) {
      return SizedBox.shrink(); // Don't show anything if no detection
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDetecting
                ? Colors.black.withValues(alpha: 0.7)
                : _getColorForClass(
                  detection?.className ?? '',
                ).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDetecting
                  ? Icons.search
                  : _getIconForClass(detection?.className ?? ''),
              color: Colors.white,
              size: 14,
            ),
          ),

          SizedBox(width: 12),

          // Content
          if (isDetecting) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Scanning...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (detection != null) ...[
            // Class name
            Text(
              _formatClassName(detection!.className),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 12),

            // Confidence badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(detection!.confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatClassName(String className) {
    switch (className.toLowerCase()) {
      case 'biodegradable':
        return 'Biodegradable';
      case 'cardboard':
        return 'Cardboard';
      case 'glass':
        return 'Glass';
      case 'metal':
        return 'Metal';
      case 'paper':
        return 'Paper';
      case 'plastic':
        return 'Plastic';
      default:
        return className;
    }
  }

  Color _getColorForClass(String className) {
    switch (className.toLowerCase()) {
      case 'biodegradable':
        return Colors.green;
      case 'cardboard':
        return Colors.brown;
      case 'glass':
        return Colors.cyan;
      case 'metal':
        return Colors.red;
      case 'paper':
        return Colors.orange;
      case 'plastic':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  IconData _getIconForClass(String className) {
    switch (className.toLowerCase()) {
      case 'biodegradable':
        return Icons.eco;
      case 'cardboard':
        return Icons.inventory_2;
      case 'glass':
        return Icons.wine_bar;
      case 'metal':
        return Icons.build;
      case 'paper':
        return Icons.description;
      case 'plastic':
        return Icons.local_drink;
      default:
        return Icons.delete;
    }
  }
}
