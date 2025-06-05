import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter_client/services/scan/websocket.dart';

/// Service for handling live waste detection during camera sessions
class LiveDetectionService {
  static LiveDetectionService? _instance;

  Timer? _detectionTimer;
  Timer? _cooldownTimer;
  bool _isDetecting = false;
  bool _isCooldownActive = false;
  CameraController? _cameraController;
  WasteDetectionResult? _lastDetection; // Store the last detection

  final _detectionController =
      StreamController<WasteDetectionResult?>.broadcast();
  final _statusController = StreamController<LiveDetectionStatus>.broadcast();

  // Private constructor for singleton
  LiveDetectionService._();

  /// Get singleton instance
  static LiveDetectionService get instance {
    _instance ??= LiveDetectionService._();
    return _instance!;
  }

  /// Stream of detection results (updates with every new detection)
  Stream<WasteDetectionResult?> get detectionStream =>
      _detectionController.stream;

  /// Stream of detection status updates
  Stream<LiveDetectionStatus> get statusStream => _statusController.stream;

  /// Get the last detection result
  WasteDetectionResult? get lastDetection => _lastDetection;

  /// Start live detection with camera controller
  Future<void> startLiveDetection(CameraController cameraController) async {
    if (_detectionTimer != null) {
      debugPrint('LiveDetectionService: Already running');
      return;
    }

    _cameraController = cameraController;
    _lastDetection = null; // Reset last detection

    // Ensure WebSocket is connected
    await WasteDetectionWebSocketService.instance.connect();

    // Listen to WebSocket detection results
    WasteDetectionWebSocketService.instance.detectionStream.listen((
      detections,
    ) {
      if (detections.isNotEmpty && !_isCooldownActive) {
        final bestDetection = detections.reduce(
          (a, b) => a.confidence > b.confidence ? a : b,
        );

        // Update last detection and emit
        _lastDetection = bestDetection;
        _detectionController.add(bestDetection);

        // Start 10-second cooldown
        _startCooldown();

        debugPrint(
          'LiveDetectionService: Detection updated - ${bestDetection.className} (${(bestDetection.confidence * 100).toStringAsFixed(1)}%)',
        );
      }

      _isDetecting = false;
      _updateStatus();
    });

    // Start periodic detection every 1 second
    _detectionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isDetecting && !_isCooldownActive) {
        _captureAndDetect();
      }
    });

    debugPrint('LiveDetectionService: Started live detection');
    _updateStatus();
  }

  /// Stop live detection
  void stopLiveDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;

    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    _isDetecting = false;
    _isCooldownActive = false;
    _cameraController = null;
    _lastDetection = null;

    debugPrint('LiveDetectionService: Stopped live detection');
    _updateStatus();
  }

  /// Capture image and send for detection
  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _isDetecting = true;
    _updateStatus();

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Send to WebSocket service
      await WasteDetectionWebSocketService.instance.detectWaste(imageBytes);
    } catch (e) {
      debugPrint('LiveDetectionService: Error capturing image - $e');
      _isDetecting = false;
      _updateStatus();
    }
  }

  /// Start 5-second cooldown after detection
  void _startCooldown() {
    _isCooldownActive = true;
    _updateStatus();

    _cooldownTimer = Timer(Duration(seconds: 5), () {
      _isCooldownActive = false;
      _updateStatus();
      debugPrint('LiveDetectionService: Cooldown ended, resuming detection');
    });

    debugPrint('LiveDetectionService: Started 5-second cooldown');
  }

  /// Capture a photo for manual analysis
  Future<String?> capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      debugPrint('LiveDetectionService: Photo captured - ${imageFile.path}');
      return imageFile.path;
    } catch (e) {
      debugPrint('LiveDetectionService: Error capturing photo - $e');
      return null;
    }
  }

  /// Update status for UI
  void _updateStatus() {
    final status = LiveDetectionStatus(
      isActive: _detectionTimer != null,
      isDetecting: _isDetecting,
      isCooldownActive: _isCooldownActive,
      isWebSocketConnected: WasteDetectionWebSocketService.instance.isConnected,
    );

    _statusController.add(status);
  }

  /// Get current status
  LiveDetectionStatus get currentStatus => LiveDetectionStatus(
    isActive: _detectionTimer != null,
    isDetecting: _isDetecting,
    isCooldownActive: _isCooldownActive,
    isWebSocketConnected: WasteDetectionWebSocketService.instance.isConnected,
  );

  /// Dispose of the service
  void dispose() {
    stopLiveDetection();
    _detectionController.close();
    _statusController.close();
    _instance = null;
  }
}

/// Status of live detection service
class LiveDetectionStatus {
  final bool isActive;
  final bool isDetecting;
  final bool isCooldownActive;
  final bool isWebSocketConnected;

  LiveDetectionStatus({
    required this.isActive,
    required this.isDetecting,
    required this.isCooldownActive,
    required this.isWebSocketConnected,
  });

  String get displayText {
    if (!isWebSocketConnected) return 'Connecting to AI...';
    if (!isActive) return 'Live detection stopped';
    if (isCooldownActive) return 'Next scan in 5s';
    if (isDetecting) return 'Scanning...';
    return 'Ready to detect';
  }

  @override
  String toString() =>
      'LiveDetectionStatus('
      'active: $isActive, '
      'detecting: $isDetecting, '
      'cooldown: $isCooldownActive, '
      'connected: $isWebSocketConnected)';
}
