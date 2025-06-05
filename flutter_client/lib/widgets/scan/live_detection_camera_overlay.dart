import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_client/services/scan/live_detection_service.dart';
import 'package:flutter_client/services/scan/websocket.dart';
import 'detection_popup_widget.dart';

/// Camera overlay that handles live waste detection
class LiveDetectionCameraOverlay extends StatefulWidget {
  final CameraController cameraController;
  final VoidCallback? onClose;

  const LiveDetectionCameraOverlay({
    Key? key,
    required this.cameraController,
    this.onClose,
  }) : super(key: key);

  @override
  State<LiveDetectionCameraOverlay> createState() =>
      _LiveDetectionCameraOverlayState();
}

class _LiveDetectionCameraOverlayState
    extends State<LiveDetectionCameraOverlay> {
  LiveDetectionService get _liveDetectionService =>
      LiveDetectionService.instance;
  LiveDetectionStatus _currentStatus = LiveDetectionStatus(
    isActive: false,
    isDetecting: false,
    isCooldownActive: false,
    isWebSocketConnected: false,
  );

  @override
  void initState() {
    super.initState();
    _initializeLiveDetection();
  }

  Future<void> _initializeLiveDetection() async {
    // Listen to status updates
    _liveDetectionService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });

    // Listen to detection results
    _liveDetectionService.detectionStream.listen((detection) {
      if (detection != null && mounted) {
        _showDetectionResult(detection);
      }
    });

    // Start live detection
    await _liveDetectionService.startLiveDetection(widget.cameraController);
  }

  void _showDetectionResult(WasteDetectionResult detection) {
    showDetectionPopup(context, detection);
  }

  void _stopDetectionAndClose() {
    _liveDetectionService.stopLiveDetection();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(child: CameraPreview(widget.cameraController)),

          // Top status bar
          SafeArea(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Connection indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentStatus.isWebSocketConnected
                              ? Colors.green
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),

                  SizedBox(width: 8),

                  // Status text
                  Text(
                    _currentStatus.displayText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Loading indicator when detecting
                  if (_currentStatus.isDetecting) ...[
                    SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Detection area frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _currentStatus.isCooldownActive
                          ? Colors.orange
                          : _currentStatus.isDetecting
                          ? Colors.blue
                          : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner frames
                  ..._buildCornerFrames(),

                  // Center instruction
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentStatus.isCooldownActive
                            ? 'Detection paused'
                            : 'Point at waste item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Close button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _stopDetectionAndClose,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Detection info
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Live AI Detection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              _currentStatus.isCooldownActive
                                  ? 'Waiting 10 seconds...'
                                  : 'Point camera at waste',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerFrames() {
    const frameSize = 20.0;
    const frameThickness = 3.0;
    const frameOffset = 12.0;

    final color =
        _currentStatus.isCooldownActive
            ? Colors.orange
            : _currentStatus.isDetecting
            ? Colors.blue
            : Colors.white;

    return [
      // Top-left
      Positioned(
        top: frameOffset,
        left: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: frameThickness),
              left: BorderSide(color: color, width: frameThickness),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: frameOffset,
        right: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: frameThickness),
              right: BorderSide(color: color, width: frameThickness),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: frameOffset,
        left: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: frameThickness),
              left: BorderSide(color: color, width: frameThickness),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: frameOffset,
        right: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: frameThickness),
              right: BorderSide(color: color, width: frameThickness),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _liveDetectionService.stopLiveDetection();
    super.dispose();
  }
}
