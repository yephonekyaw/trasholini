// Updated home screen using the WebSocket service
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/providers/user_profile_provider.dart';
import 'package:flutter_client/utils/websocket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_client/providers/google_auth_provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// Import the WebSocket service

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  List<WasteDetectionResult> _currentDetections = [];
  Timer? _detectionTimer;
  bool _isDetecting = false;
  bool _isCameraActive = false;
  bool _pauseDetection = false;
  bool _isConnected = false;

  // Get the WebSocket service instance
  WasteDetectionWebSocketService get _wasteService =>
      WasteDetectionWebSocketService.instance;

  @override
  void initState() {
    super.initState();
    _initializeWebSocketService();
  }

  Future<void> _initializeWebSocketService() async {
    // Connect to WebSocket service
    await _wasteService.connect();

    // Listen to detection results
    _wasteService.detectionStream.listen((detections) {
      setState(() {
        _currentDetections = detections;
        _isDetecting = false;

        if (detections.isNotEmpty) {
          // Pause detection for 15 seconds when we find something
          _pauseDetection = true;
          HapticFeedback.lightImpact();

          // Resume detection after 15 seconds
          Timer(Duration(seconds: 15), () {
            if (mounted) {
              setState(() {
                _pauseDetection = false;
              });
            }
          });
        }
      });
    });

    // Listen to connection status
    _wasteService.connectionStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });

    // Set initial connection status
    setState(() {
      _isConnected = _wasteService.isConnected;
    });
  }

  Future<void> _startCamera() async {
    try {
      await Permission.camera.request();

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();

        setState(() {
          _isCameraActive = true;
        });

        _startPeriodicDetection();
      }
    } catch (e) {
      debugPrint('Error starting camera: $e');
    }
  }

  void _startPeriodicDetection() {
    _detectionTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (!_isDetecting && !_pauseDetection && _cameraController != null) {
        _captureAndDetect();
      }
    });
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Use the WebSocket service to detect waste
      await _wasteService.detectWaste(imageBytes);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      setState(() {
        _isDetecting = false;
      });
    }
  }

  void _stopCamera() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    setState(() {
      _isCameraActive = false;
      _currentDetections.clear();
      _pauseDetection = false;
    });
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

  Widget _buildDetectionPanel() {
    if (!_isCameraActive) return Container();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child:
          _isDetecting
              ? Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Scanning...', style: TextStyle(fontSize: 16)),
                ],
              )
              : _currentDetections.isEmpty
              ? Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400], size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Point camera at waste item',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
              : _buildDetectionResults(),
    );
  }

  Widget _buildDetectionResults() {
    final bestDetection = _currentDetections.reduce(
      (a, b) => a.confidence > b.confidence ? a : b,
    );

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getColorForClass(bestDetection.className),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatClassName(bestDetection.className),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(bestDetection.confidence * 100).toStringAsFixed(1)}% confidence',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: Colors.green, size: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isCameraActive ? Colors.black : null,
      appBar:
          _isCameraActive
              ? null
              : AppBar(
                title: const Text('Waste Scanner Test'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
      body: _isCameraActive ? _buildCameraView() : _buildTestInterface(),
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),

        // Top status
        SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // Detection panel
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: _buildDetectionPanel(),
        ),

        // Close button
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Center(
            child: FloatingActionButton(
              onPressed: _stopCamera,
              backgroundColor: Colors.red,
              child: Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestInterface() {
    final userProfileAsyncValue = ref.watch(userProfileProvider);
    return userProfileAsyncValue.when(
      data: (userProfile) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Connection status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.wifi : Icons.wifi_off,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 12),
                      Text(
                        _isConnected
                            ? 'Connected to AI Server'
                            : 'Disconnected',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Main test button
              SizedBox(
                width: double.infinity,
                height: 200,
                child: ElevatedButton(
                  onPressed: _startCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Test Waste Scanner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to start detection',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // User info
              if (userProfile != null) ...[
                Text('Logged in as: ${userProfile.displayName ?? "Anonymous"}'),
                Text(
                  'Eco Points: ${userProfile.ecoPoints}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(googleAuthProvider.notifier).signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    // Note: Don't dispose the WebSocket service here as it's a singleton
    // that should persist across the app
    super.dispose();
  }
}
