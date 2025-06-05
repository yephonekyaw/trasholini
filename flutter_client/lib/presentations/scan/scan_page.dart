import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/scan_provider.dart';
import '../../utils/constants.dart';
import '../../utils/utility.dart';
import '../../widgets/scan_icon.dart';

class ScanPage extends ConsumerWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: AppConstants.lightGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header section - 10% of screen
            _buildHeader(context, size),

            // Main scan area - 60% of screen
            Expanded(
              flex: 60,
              child: _buildScanArea(context, scanState, size, isLandscape),
            ),

            // Action buttons section - 30% of screen
            Expanded(
              flex: 30,
              child: _buildActionButtons(
                context,
                ref,
                scanState,
                size,
                isLandscape,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: size.width * 0.11,
            height: size.width * 0.11,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.width * 0.03),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: size.width * 0.05,
              ),
            ),
          ),

          // Centered title with icon
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.02),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(size.width * 0.025),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppConstants.primaryGreen,
                    size: size.width * 0.045,
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Flexible(
                  child: Text(
                    'Scan Item',
                    style: TextStyle(
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.13), // Balance the row
        ],
      ),
    );
  }

  Widget _buildScanArea(
    BuildContext context,
    ScanState scanState,
    Size size,
    bool isLandscape,
  ) {
    final scanIconSize = isLandscape ? size.height * 0.25 : size.width * 0.3;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.07),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child:
                isLandscape
                    ? _buildLandscapeLayout(scanIconSize, size)
                    : _buildPortraitLayout(scanIconSize, size),
          ),

          // Corner frame indicators
          ..._buildCornerFrames(size),

          // Processing overlay
          if (scanState.isProcessing) _buildProcessingOverlay(size),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(double scanIconSize, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated scan icon with glow effect
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.06),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryGreen.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ScanIcon(size: scanIconSize),
        ),

        SizedBox(height: size.height * 0.02),

        // Instructions
        _buildInstructions(size),

        SizedBox(height: size.height * 0.015),

        // Tips section
        _buildTipsSection(size),
      ],
    );
  }

  Widget _buildLandscapeLayout(double scanIconSize, Size size) {
    return Row(
      children: [
        // Left side - Scan icon
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ScanIcon(size: scanIconSize),
              ),
            ],
          ),
        ),

        SizedBox(width: size.width * 0.04),

        // Right side - Instructions and tips
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructions(size),
              SizedBox(height: size.height * 0.02),
              _buildTipsSection(size),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(Size size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Position item in the frame',
          style: TextStyle(
            fontSize: size.width * 0.045,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'Make sure the item is clearly visible and well-lit for better recognition',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.black54,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTipsSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppConstants.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.primaryGreen,
                size: size.width * 0.04,
              ),
              SizedBox(width: size.width * 0.015),
              Flexible(
                child: Text(
                  'Tips for better results',
                  style: TextStyle(
                    fontSize: size.width * 0.032,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.008),
          _buildTipItem(
            'Good lighting helps identification',
            size.width * 0.028,
          ),
          _buildTipItem('Clean the item surface', size.width * 0.028),
          _buildTipItem('Include any labels or text', size.width * 0.028),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    Size size,
    bool isLandscape,
  ) {
    final cameraButtonSize =
        isLandscape ? size.height * 0.15 : size.width * 0.2;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      child: Center(
        child:
            isLandscape
                ? _buildLandscapeButtons(
                  context,
                  ref,
                  scanState,
                  size,
                  cameraButtonSize,
                )
                : _buildPortraitButtons(
                  context,
                  ref,
                  scanState,
                  size,
                  cameraButtonSize,
                ),
      ),
    );
  }

  Widget _buildPortraitButtons(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    Size size,
    double cameraButtonSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gallery button
        _buildGalleryButton(context, ref, scanState, size),

        SizedBox(height: size.height * 0.015),

        // Camera button
        _buildCameraButton(context, ref, scanState, size, cameraButtonSize),
      ],
    );
  }

  Widget _buildLandscapeButtons(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    Size size,
    double cameraButtonSize,
  ) {
    return Row(
      children: [
        // Gallery button
        Expanded(
          flex: 2,
          child: _buildGalleryButton(context, ref, scanState, size),
        ),

        SizedBox(width: size.width * 0.04),

        // Camera button
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCameraButton(context, ref, scanState, size, cameraButtonSize),
          ],
        ),

        SizedBox(width: size.width * 0.04),

        // Empty space for balance
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  Widget _buildGalleryButton(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    Size size,
  ) {
    return SizedBox(
      height: size.width * 0.12,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            scanState.isProcessing
                ? null
                : () => _pickFromGallery(context, ref),
        icon: Container(
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(size.width * 0.02),
          ),
          child: Icon(
            Icons.photo_library,
            color: AppConstants.primaryGreen,
            size: size.width * 0.05,
          ),
        ),
        label: Text(
          'Pick from Gallery',
          style: TextStyle(
            color: AppConstants.primaryGreen,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.primaryGreen,
          side: BorderSide(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.05),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCameraButton(
    BuildContext context,
    WidgetRef ref,
    ScanState scanState,
    Size size,
    double buttonSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Camera button
        GestureDetector(
          onTap:
              scanState.isProcessing ? null : () => _openCamera(context, ref),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryGreen,
                  AppConstants.primaryGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(size.width * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: buttonSize * 0.32,
                color: AppConstants.primaryGreen,
              ),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.01),

        // Camera button label
        Text(
          'Tap to scan',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerFrames(Size size) {
    final frameSize = size.width * 0.07;
    final frameThickness = size.width * 0.01;
    final frameOffset = size.width * 0.08;

    return [
      // Top-left corner
      Positioned(
        top: frameOffset,
        left: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
              left: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
            ),
          ),
        ),
      ),
      // Top-right corner
      Positioned(
        top: frameOffset,
        right: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
              right: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
            ),
          ),
        ),
      ),
      // Bottom-left corner
      Positioned(
        bottom: frameOffset,
        left: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
              left: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
            ),
          ),
        ),
      ),
      // Bottom-right corner
      Positioned(
        bottom: frameOffset,
        right: frameOffset,
        child: Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
              right: BorderSide(
                color: AppConstants.primaryGreen,
                width: frameThickness,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildProcessingOverlay(Size size) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(size.width * 0.07),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.2,
              height: size.width * 0.2,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryGreen,
                ),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Analyzing image...',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryGreen,
              ),
            ),
            SizedBox(height: size.height * 0.008),
            Text(
              'Please wait while we identify your item',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context, WidgetRef ref) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      try {
        final analysisResult = await ref
            .read(scanProvider.notifier)
            .processImage(image.path);
        context.push(
          '/category-details',
          extra: {'imagePath': image.path, 'analysisResult': analysisResult},
        );
      } catch (e) {
        Utility.showSnackBar(
          context,
          'Error processing image: ${Utility.getErrorMessage(e)}',
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

    if (image != null) {
      try {
        final analysisResult = await ref
            .read(scanProvider.notifier)
            .processImage(image.path);
        context.push(
          '/category-details',
          extra: {'imagePath': image.path, 'analysisResult': analysisResult},
        );
      } catch (e) {
        Utility.showSnackBar(
          context,
          'Error processing image: ${Utility.getErrorMessage(e)}',
          isError: true,
        );
      }
    }
  }
}
