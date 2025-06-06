import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';
import '../../providers/waste_analysis_provider.dart';
import '../../utils/utility.dart';

class ImagePreviewPage extends ConsumerWidget {
  final String imagePath;

  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final wasteAnalysisState = ref.watch(wasteAnalysisProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8), // Match other pages
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  children: [
                    _buildImageContainer(context, size),
                    SizedBox(height: size.height * 0.030),
                    _buildActionCard(context, size, ref, wasteAnalysisState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
      floatingActionButton: FloatingScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
              onTap: () => ref.read(routerProvider).go('/scan'),
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
                  'Image Preview',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review your captured image',
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

  Widget _buildImageContainer(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * 0.04),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: size.width * 0.15,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Image not found',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    Size size,
    WidgetRef ref,
    WasteAnalysisState wasteAnalysisState,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.1,
                height: size.width * 0.1,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.preview,
                  color: Colors.white,
                  size: size.width * 0.05,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                'Image Preview',
                style: TextStyle(
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),

          // Preview info text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
            child: Column(
              children: [
                Icon(
                  wasteAnalysisState.isLoading
                      ? Icons.hourglass_empty
                      : Icons.info_outline,
                  color: AppConstants.primaryGreen,
                  size: size.width * 0.06,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  wasteAnalysisState.isLoading
                      ? 'Analyzing your waste item...'
                      : 'Ready to analyze your waste item',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  wasteAnalysisState.isLoading
                      ? 'Please wait while our AI analyzes the image'
                      : 'Get personalized disposal tips and bin recommendations',
                  style: TextStyle(
                    fontSize: size.width * 0.032,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                // Show error if any
                if (wasteAnalysisState.error != null) ...[
                  SizedBox(height: size.height * 0.01),
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(size.width * 0.02),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: size.width * 0.04,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: Text(
                            wasteAnalysisState.error!,
                            style: TextStyle(
                              fontSize: size.width * 0.03,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: size.height * 0.025),

          // Get Disposal Tips Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  wasteAnalysisState.isLoading
                      ? null
                      : () => _analyzeWaste(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    wasteAnalysisState.isLoading
                        ? Colors.grey[400]
                        : AppConstants.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                ),
                elevation: 0,
              ),
              child:
                  wasteAnalysisState.isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: size.width * 0.04,
                            height: size.width * 0.04,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.03),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: size.width * 0.05,
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            'Get Disposal Tips',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),

          SizedBox(height: size.height * 0.015),

          // Retake Photo Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed:
                  wasteAnalysisState.isLoading
                      ? null
                      : () => context.go('/scan'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color:
                      wasteAnalysisState.isLoading
                          ? Colors.grey[400]!
                          : AppConstants.primaryGreen,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color:
                        wasteAnalysisState.isLoading
                            ? Colors.grey[400]
                            : AppConstants.primaryGreen,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Retake Photo',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color:
                          wasteAnalysisState.isLoading
                              ? Colors.grey[400]
                              : AppConstants.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeWaste(BuildContext context, WidgetRef ref) async {
    try {
      // Clear any previous errors
      ref.read(wasteAnalysisProvider.notifier).clearError();

      // Call the analysis API
      final result = await ref
          .read(wasteAnalysisProvider.notifier)
          .analyzeWaste(imagePath);

      if (context.mounted) {
        // Navigate to disposal instructions page with the result
        context.push(
          '/disposal-instructions',
          extra: {'imagePath': imagePath, 'analysisResult': result},
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Error is already handled in the provider state
        // Optionally show a snackbar for immediate feedback
        Utility.showSnackBar(
          context,
          'Failed to analyze waste: ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true,
        );
      }
    }
  }
}
