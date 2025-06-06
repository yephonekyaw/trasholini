import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';
import '../../providers/waste_analysis_provider.dart';

// Model for parsed disposal tips
class ParsedDisposalTips {
  final String disposalTips;
  final String preparationSteps;
  final String environmentalNote;

  ParsedDisposalTips({
    required this.disposalTips,
    required this.preparationSteps,
    required this.environmentalNote,
  });

  factory ParsedDisposalTips.fromRawTips(String rawTips) {
    try {
      // Extract JSON from the raw tips
      final jsonMatch = RegExp(
        r'```json\s*\n(.*?)\n```',
        dotAll: true,
      ).firstMatch(rawTips);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(1);
        if (jsonString != null) {
          final parsed = json.decode(jsonString);

          return ParsedDisposalTips(
            disposalTips: parsed['disposal_tips'] ?? '',
            preparationSteps: parsed['preparation_steps'] ?? '',
            environmentalNote: parsed['environmental_note'] ?? '',
          );
        }
      }

      // Fallback: try to extract individual sections from the raw text
      final lines =
          rawTips.split('\n').where((line) => line.trim().isNotEmpty).toList();
      String disposalTips = '';
      String preparationSteps = '';
      String environmentalNote = '';

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.startsWith('Preparation:')) {
          preparationSteps = line.replaceFirst('Preparation:', '').trim();
        } else if (line.startsWith('Environmental Note:')) {
          environmentalNote =
              line.replaceFirst('Environmental Note:', '').trim();
        } else if (!line.startsWith('```') &&
            !line.startsWith('{') &&
            !line.startsWith('}') &&
            !line.contains('recommended_bin_id')) {
          if (disposalTips.isEmpty &&
              !line.startsWith('Preparation:') &&
              !line.startsWith('Environmental Note:')) {
            disposalTips = line;
          }
        }
      }

      // If we still don't have disposal tips, use the first meaningful line
      if (disposalTips.isEmpty) {
        disposalTips = lines.firstWhere(
          (line) =>
              !line.startsWith('```') &&
              !line.startsWith('{') &&
              !line.startsWith('}') &&
              !line.contains('recommended_bin_id') &&
              !line.startsWith('Preparation:') &&
              !line.startsWith('Environmental Note:'),
          orElse: () => rawTips,
        );
      }

      return ParsedDisposalTips(
        disposalTips: disposalTips.isEmpty ? rawTips : disposalTips,
        preparationSteps:
            preparationSteps.isEmpty
                ? 'Clean the item if necessary before disposal'
                : preparationSteps,
        environmentalNote:
            environmentalNote.isEmpty
                ? 'Proper disposal helps protect our environment'
                : environmentalNote,
      );
    } catch (e) {
      // Complete fallback - return raw tips
      return ParsedDisposalTips(
        disposalTips: rawTips,
        preparationSteps: 'Clean the item if necessary before disposal',
        environmentalNote: 'Proper disposal helps protect our environment',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'disposal_tips': disposalTips,
      'preparation_steps': preparationSteps,
      'environmental_note': environmentalNote,
    };
  }
}

class DisposalInstructionsPage extends ConsumerStatefulWidget {
  final String imagePath;
  final WasteAnalysisResult? analysisResult;

  const DisposalInstructionsPage({
    super.key,
    required this.imagePath,
    this.analysisResult,
  });

  @override
  ConsumerState<DisposalInstructionsPage> createState() =>
      _DisposalInstructionsPageState();
}

class _DisposalInstructionsPageState
    extends ConsumerState<DisposalInstructionsPage> {
  bool isExpanded = false;

  Future<void> _saveTips(
    BuildContext context,
    WidgetRef ref,
    WasteAnalysisResult analysisResult,
  ) async {
    try {
      // Call the save method
      final result = await ref
          .read(wasteAnalysisProvider.notifier)
          .saveTips(imagePath: widget.imagePath, result: analysisResult);

      // Show success snack bar immediately after successful save
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ??
                        'Scan saved successfully to your history!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppConstants.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        ref.read(routerProvider).go('/');
      }
    } catch (e) {
      // Show error snack bar immediately
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to save tips: ${e.toString()}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    // Get analysis result from widget parameter or provider
    final analysisResult =
        widget.analysisResult ?? ref.watch(wasteAnalysisProvider).result;

    // If no analysis result available, show error or redirect
    if (analysisResult == null) {
      return Scaffold(
        backgroundColor: AppConstants.lightGreen,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'No analysis result found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please go back and analyze your image first',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                  ),
                  child: Text(
                    'Back to Scan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.lightGreen,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header with back button and title
                _buildHeader(context, size, isTablet),

                // Main content - scrollable
                Expanded(
                  child:
                      isLandscape
                          ? _buildLandscapeLayout(
                            size,
                            isTablet,
                            analysisResult,
                          )
                          : _buildPortraitLayout(
                            size,
                            isTablet,
                            analysisResult,
                          ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
      floatingActionButton: FloatingScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context, Size size, bool isTablet) {
    final padding = size.width * 0.04;
    final titleFontSize = isTablet ? 26.0 : size.width * 0.045;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: Icon(
                  Icons.recycling,
                  color: AppConstants.primaryGreen,
                  size: isTablet ? 32 : 28,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Flexible(
                child: Text(
                  'Disposal Instructions',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          // Back button (absolute positioned)
          Positioned(
            left: 0,
            child: Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(
    Size size,
    bool isTablet,
    WasteAnalysisResult analysisResult,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          // Image container
          _buildImageContainer(size, isTablet, analysisResult),
          SizedBox(height: size.height * 0.025),

          // Analysis info card
          _buildAnalysisInfoCard(size, isTablet, analysisResult),
          SizedBox(height: size.height * 0.02),

          // Instructions card
          _buildInstructionsCard(size, isTablet, analysisResult),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    Size size,
    bool isTablet,
    WasteAnalysisResult analysisResult,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image
              Expanded(
                flex: 2,
                child: _buildImageContainer(size, isTablet, analysisResult),
              ),
              SizedBox(width: size.width * 0.04),
              // Right side - Analysis info
              Expanded(
                flex: 3,
                child: _buildAnalysisInfoCard(size, isTablet, analysisResult),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          // Instructions below
          _buildInstructionsCard(size, isTablet, analysisResult),
        ],
      ),
    );
  }

  Widget _buildImageContainer(
    Size size,
    bool isTablet,
    WasteAnalysisResult analysisResult,
  ) {
    final isLandscape = size.width > size.height;
    final imageHeight = isLandscape ? size.height * 0.4 : size.height * 0.35;

    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Confidence overlay
          Positioned(
            bottom: isTablet ? 20 : 16,
            right: isTablet ? 20 : 16,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8,
                vertical: isTablet ? 8 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: isTablet ? 16 : 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Confidence: ${(analysisResult.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
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

  Widget _buildAnalysisInfoCard(
    Size size,
    bool isTablet,
    WasteAnalysisResult analysisResult,
  ) {
    final titleFontSize = isTablet ? 18.0 : size.width * 0.04;
    final valueFontSize = isTablet ? 16.0 : size.width * 0.035;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppConstants.primaryGreen,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: 8),
              Text(
                'Analysis Results',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Detected Item
          _buildInfoRow(
            'Detected Item',
            analysisResult.wasteClass.replaceAll('_', ' ').toUpperCase(),
            Icons.category,
            valueFontSize,
            isTablet,
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Recommended Bin
          if (analysisResult.recommendedBin != null)
            _buildInfoRow(
              'Recommended Bin',
              '${analysisResult.recommendedBin!.name} - ${analysisResult.recommendedBin!.description}',
              Icons.delete_outline,
              valueFontSize,
              isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    double fontSize,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 8 : 6),
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
          ),
          child: Icon(
            icon,
            color: AppConstants.primaryGreen,
            size: isTablet ? 20 : 16,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard(
    Size size,
    bool isTablet,
    WasteAnalysisResult analysisResult,
  ) {
    // Parse the disposal tips
    final parsedTips = ParsedDisposalTips.fromRawTips(
      analysisResult.disposalTips,
    );

    final iconSize = isTablet ? 140.0 : size.width * 0.28;
    final titleFontSize = isTablet ? 20.0 : size.width * 0.045;
    final contentFontSize = isTablet ? 16.0 : size.width * 0.035;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bin icon or placeholder
          Center(
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppConstants.lightGreen,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              ),
              child:
                  analysisResult.recommendedBin != null
                      ? Icon(
                        _getBinIcon(analysisResult.recommendedBin!.name),
                        size: iconSize * 0.6,
                        color: AppConstants.primaryGreen,
                      )
                      : Icon(
                        Icons.delete_outline,
                        size: iconSize * 0.6,
                        color: AppConstants.primaryGreen,
                      ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Title centered
          Center(
            child: Text(
              analysisResult.recommendedBin?.name ?? 'Disposal Instructions',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (analysisResult.recommendedBin != null) ...[
            SizedBox(height: 8),
            Center(
              child: Text(
                analysisResult.recommendedBin!.description,
                style: TextStyle(
                  fontSize: titleFontSize * 0.8,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          SizedBox(height: isTablet ? 24 : 16),

          // Disposal Tips Section
          _buildInstructionSection(
            'How to Dispose',
            parsedTips.disposalTips,
            Icons.recycling,
            contentFontSize,
            isTablet,
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Preparation Steps Section
          _buildInstructionSection(
            'Preparation Steps',
            parsedTips.preparationSteps,
            Icons.cleaning_services,
            contentFontSize,
            isTablet,
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Environmental Note Section
          _buildInstructionSection(
            'Environmental Impact',
            parsedTips.environmentalNote,
            Icons.eco,
            contentFontSize,
            isTablet,
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Save Tips Button
          SizedBox(
            width: double.infinity,
            child: Consumer(
              builder: (context, ref, child) {
                final isSaving = ref.watch(wasteAnalysisSavingProvider);

                return ElevatedButton.icon(
                  onPressed:
                      isSaving
                          ? null
                          : () => _saveTips(context, ref, analysisResult),
                  icon:
                      isSaving
                          ? SizedBox(
                            width: isTablet ? 20 : 16,
                            height: isTablet ? 20 : 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.bookmark_add,
                            color: Colors.white,
                            size: isTablet ? 24 : 20,
                          ),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save These Tips',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSaving
                            ? AppConstants.primaryGreen.withValues(alpha: 0.7)
                            : AppConstants.primaryGreen,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : size.height * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isTablet ? 16 : size.width * 0.03,
                      ),
                    ),
                    elevation: isSaving ? 1 : 2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection(
    String title,
    String content,
    IconData icon,
    double fontSize,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppConstants.lightGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color: AppConstants.primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                ),
                child: Icon(
                  icon,
                  color: AppConstants.primaryGreen,
                  size: isTablet ? 20 : 16,
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),

          // Section content
          Text(
            content,
            style: TextStyle(
              fontSize: fontSize * 0.9,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBinIcon(String binName) {
    switch (binName.toLowerCase()) {
      case 'blue bin':
        return Icons.recycling;
      case 'green bin':
        return Icons.eco;
      case 'red bin':
        return Icons.dangerous;
      case 'yellow bin':
        return Icons.warning;
      case 'grey bin':
      case 'gray bin':
        return Icons.delete;
      default:
        return Icons.delete_outline;
    }
  }
}
