import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/services/scan/live_detection_service.dart';
import 'package:flutter_client/services/scan/websocket.dart';
import 'package:flutter_client/widgets/scan/detection_popup_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Camera overlay that handles live waste detection with minimalist UI
class LiveDetectionCameraOverlay extends StatefulWidget {
  final CameraController cameraController;
  final WidgetRef ref;
  final Function(String imagePath)? onImageCaptured;

  const LiveDetectionCameraOverlay({
    Key? key,
    required this.cameraController,
    required this.ref,
    this.onImageCaptured,
  }) : super(key: key);

  @override
  State<LiveDetectionCameraOverlay> createState() =>
      _LiveDetectionCameraOverlayState();
}

class _LiveDetectionCameraOverlayState extends State<LiveDetectionCameraOverlay>
    with WidgetsBindingObserver {
  LiveDetectionService get _liveDetectionService =>
      LiveDetectionService.instance;

  LiveDetectionStatus _currentStatus = LiveDetectionStatus(
    isActive: false,
    isDetecting: false,
    isCooldownActive: false,
    isWebSocketConnected: false,
  );

  WasteDetectionResult? _currentDetection;
  bool _isCapturing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLiveDetection();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _liveDetectionService.stopLiveDetection();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!widget.cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Stop live detection when app goes inactive
      _liveDetectionService.stopLiveDetection();
    } else if (state == AppLifecycleState.resumed) {
      // Restart live detection when app resumes
      if (!_isDisposed) {
        _initializeLiveDetection();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future<void> _initializeLiveDetection() async {
    // Don't initialize if disposed or camera not ready
    if (_isDisposed || !widget.cameraController.value.isInitialized) {
      return;
    }

    // Listen to status updates
    _liveDetectionService.statusStream.listen((status) {
      if (mounted && !_isDisposed) {
        setState(() {
          _currentStatus = status;
        });
      }
    });

    // Listen to detection results
    _liveDetectionService.detectionStream.listen((detection) {
      if (detection != null && mounted && !_isDisposed) {
        setState(() {
          _currentDetection = detection;
        });

        // Add haptic feedback for new detection
        HapticFeedback.lightImpact();
      }
    });

    // Start live detection
    await _liveDetectionService.startLiveDetection(widget.cameraController);

    // Set initial detection if available
    if (_liveDetectionService.lastDetection != null &&
        mounted &&
        !_isDisposed) {
      setState(() {
        _currentDetection = _liveDetectionService.lastDetection;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing ||
        _isDisposed ||
        !widget.cameraController.value.isInitialized)
      return;

    setState(() {
      _isCapturing = true;
    });

    try {
      HapticFeedback.mediumImpact();

      // Use the camera controller directly instead of the service
      final XFile imageFile = await widget.cameraController.takePicture();
      final imagePath = imageFile.path;

      log('Photo captured: $imagePath');

      if (!_isDisposed && widget.onImageCaptured != null) {
        // Stop live detection before navigating
        _liveDetectionService.stopLiveDetection();
        widget.onImageCaptured!(imagePath);
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      // Show error feedback
      HapticFeedback.heavyImpact();
      if (mounted && !_isDisposed) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
    // Don't set _isCapturing to false here since we're navigating away
  }

  void _closeCamera() {
    // Stop detection
    _liveDetectionService.stopLiveDetection();

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Try multiple ways to close the camera overlay
    try {
      // Method 1: Pop the current route if using Navigator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      } else {
        // Method 2: Use GoRouter to navigate back to scan page
        widget.ref.read(routerProvider).go('/scan');
      }
    } catch (e) {
      // Method 3: Fallback - force navigation to scan page
      debugPrint('Error closing camera: $e');
      widget.ref.read(routerProvider).go('/scan');
    }
  }

  Color _getFrameColor() {
    if (_currentStatus.isCooldownActive) return Colors.orange;
    if (_currentStatus.isDetecting) return Colors.blue;
    if (_currentDetection != null) {
      return _getColorForClass(_currentDetection!.className);
    }
    return Colors.white;
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

  @override
  Widget build(BuildContext context) {
    // Add camera controller listener for errors
    if (widget.cameraController.value.hasError) {
      debugPrint(
        'Camera error: ${widget.cameraController.value.errorDescription}',
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview with proper lifecycle handling
          if (!_isDisposed && widget.cameraController.value.isInitialized)
            Positioned.fill(child: CameraPreview(widget.cameraController))
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Initializing Camera...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top status bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Connection status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        Text(
                          _currentStatus.isWebSocketConnected
                              ? 'Connected'
                              : 'Connecting...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Close button - FIXED
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _closeCamera, // Use the new close method
                      icon: Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                    ),
                  ),
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
                border: Border.all(color: _getFrameColor(), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner frames
                  ..._buildCornerFrames(),

                  // Center instruction (only when no detection)
                  if (_currentDetection == null && !_currentStatus.isDetecting)
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
                          'Point at waste item',
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

          // Detection result widget (top center)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: MinimalistDetectionWidget(
                detection: _currentDetection,
                isDetecting: _currentStatus.isDetecting,
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
                    // Info section
                    Expanded(
                      child: Container(
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
                              _getBottomStatusText(),
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

                    SizedBox(width: 20),

                    // Capture button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _isCapturing ? Colors.grey : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(35),
                          onTap: _isCapturing ? null : _capturePhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 4,
                              ),
                            ),
                            child:
                                _isCapturing
                                    ? Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[700],
                                      size: 30,
                                    ),
                          ),
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

  String _getBottomStatusText() {
    if (_currentStatus.isCooldownActive) return 'Next scan in 5s';
    if (_currentStatus.isDetecting) return 'AI is analyzing...';
    if (_currentDetection != null) return 'Tap capture to save photo';
    return 'Point camera at waste';
  }

  List<Widget> _buildCornerFrames() {
    const frameSize = 20.0;
    const frameThickness = 3.0;
    const frameOffset = 12.0;

    final color = _getFrameColor();

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
}
