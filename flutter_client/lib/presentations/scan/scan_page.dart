import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/widgets/scan/live_detection_camera_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/utility.dart';

class ScanPage extends ConsumerWidget {
  final ImagePicker _picker = ImagePicker();

  ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8), // Match the background color
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(child: _buildScanCard(context, size)),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, ref, size),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => ref.read(routerProvider).go('/'),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Your Waste',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Capture or select an image to get started',
                  style: TextStyle(
                    color: const Color(0xFF388E3C).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Scan area with dashed border
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
                    ),
                    child: Stack(
                      children: [
                        // Dashed border effect
                        CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: DashedBorderPainter(),
                        ),

                        // Center content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Camera icon with pulse animation
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Live Detection Camera',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Point camera at waste for instant AI recognition',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Corner frames
                        ..._buildCornerFrames(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Processing overlay (removed since we're not processing here anymore)
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Size size) {
    return Column(
      children: [
        // Primary camera button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openLiveDetectionCamera(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Open Live Detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary gallery button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _pickFromGallery(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Choose from Gallery',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerFrames() {
    const frameSize = 20.0;
    const frameThickness = 3.0;
    const frameOffset = 16.0;

    return [
      // Top-left
      Positioned(
        top: frameOffset,
        left: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF4CAF50), width: frameThickness),
              left: BorderSide(color: Color(0xFF4CAF50), width: frameThickness),
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
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF4CAF50), width: frameThickness),
              right: BorderSide(
                color: Color(0xFF4CAF50),
                width: frameThickness,
              ),
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
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF4CAF50),
                width: frameThickness,
              ),
              left: BorderSide(color: Color(0xFF4CAF50), width: frameThickness),
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
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF4CAF50),
                width: frameThickness,
              ),
              right: BorderSide(
                color: Color(0xFF4CAF50),
                width: frameThickness,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _openLiveDetectionCamera(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Request camera permission
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (context.mounted) {
          Utility.showSnackBar(
            context,
            'No cameras found on this device',
            isError: true,
          );
        }
        return;
      }

      // Initialize camera controller with max resolution
      final cameraController = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
        fps: 60,
      );

      await cameraController.initialize();

      if (context.mounted) {
        // Navigate to live detection camera overlay
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => LiveDetectionCameraOverlay(
                  cameraController: cameraController,
                  ref: ref,
                  onImageCaptured: (imagePath) async {
                    // Navigate directly to preview page with captured image
                    if (context.mounted) {
                      ref
                          .read(routerProvider)
                          .go(
                            '/image-preview',
                            extra: {'imagePath': imagePath},
                          );
                    }
                  },
                ),
          ),
        );

        // Dispose camera controller when returning
        await cameraController.dispose();
      }
    } catch (e) {
      if (context.mounted) {
        Utility.showSnackBar(
          context,
          'Error accessing camera: ${Utility.getErrorMessage(e)}',
          isError: true,
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      // Navigate directly to preview page with selected image
      context.push('/image-preview', extra: {'imagePath': image.path});
    }
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF4CAF50).withValues(alpha: 0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(20),
          ),
        );

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
