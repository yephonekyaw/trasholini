import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/services/scan/websocket.dart';

/// Popup widget that shows detection results
class DetectionPopup extends StatelessWidget {
  final WasteDetectionResult detection;
  final VoidCallback? onClose;

  const DetectionPopup({Key? key, required this.detection, this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getColorForClass(
                  detection.className,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorForClass(detection.className),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForClass(detection.className),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waste Detected!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'AI Analysis Complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (onClose != null)
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      iconSize: 20,
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Main detection result
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getColorForClass(
                          detection.className,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getColorForClass(detection.className),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatClassName(detection.className),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // Confidence score
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Confidence bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: detection.confidence,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getColorForClass(detection.className),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Quick disposal tip
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Tip',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                _getDisposalTip(detection.className),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getColorForClass(detection.className),
                          _getColorForClass(
                            detection.className,
                          ).withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onClose?.call();
                        },
                        child: Center(
                          child: Text(
                            'Continue Scanning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatClassName(String className) {
    switch (className.toLowerCase()) {
      case 'biodegradable':
        return 'Biodegradable Waste';
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

  String _getDisposalTip(String className) {
    switch (className.toLowerCase()) {
      case 'biodegradable':
        return 'Compost this item or dispose in organic waste bin';
      case 'cardboard':
        return 'Flatten and place in recycling bin';
      case 'glass':
        return 'Rinse and place in glass recycling container';
      case 'metal':
        return 'Clean and place in metal recycling bin';
      case 'paper':
        return 'Place in paper recycling bin';
      case 'plastic':
        return 'Check recycling number and dispose accordingly';
      default:
        return 'Check local disposal guidelines';
    }
  }
}

/// Show detection popup overlay
void showDetectionPopup(BuildContext context, WasteDetectionResult detection) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder:
        (context) => Center(
          child: DetectionPopup(
            detection: detection,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
  );
}
