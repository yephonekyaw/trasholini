import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';

class DisposalInstructionsPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  const DisposalInstructionsPage({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  State<DisposalInstructionsPage> createState() =>
      _DisposalInstructionsPageState();
}

class _DisposalInstructionsPageState extends State<DisposalInstructionsPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: AppConstants.lightGreen,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header section
                _buildHeader(context, size, isTablet),

                // Main content - scrollable
                Expanded(
                  child:
                      isLandscape
                          ? _buildLandscapeLayout(size, isTablet)
                          : _buildPortraitLayout(size, isTablet),
                ),

                // Bottom navigation
                _buildBottomNavigation(size, isTablet),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size, bool isTablet) {
    final padding = size.width * 0.04;
    final titleFontSize = isTablet ? 26.0 : size.width * 0.045;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          // Back button
          Container(
            width: isTablet ? 56 : 48,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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

          // Centered title with icon
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  //padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Icon(
                    Icons.recycling,
                    color: AppConstants.primaryGreen,
                    size: isTablet ? 32 : 28,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 8),
                Flexible(
                  child: Text(
                    'How to dispose this item',
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
          ),

          SizedBox(width: isTablet ? 68 : 1), // Balance the row
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(Size size, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          // Image container
          _buildImageContainer(size, isTablet),
          SizedBox(height: size.height * 0.025),

          // Instructions card
          _buildInstructionsCard(size, isTablet),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(Size size, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Image
          Expanded(flex: 2, child: _buildImageContainer(size, isTablet)),

          SizedBox(width: size.width * 0.04),

          // Right side - Instructions
          Expanded(flex: 3, child: _buildInstructionsCard(size, isTablet)),
        ],
      ),
    );
  }

  Widget _buildImageContainer(Size size, bool isTablet) {
    final isLandscape = size.width > size.height;
    final imageHeight = isLandscape ? size.height * 0.6 : size.height * 0.35;

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

          // Location overlay
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
                    Icons.location_on,
                    color: Colors.white,
                    size: isTablet ? 16 : 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'May 10, 2025 - 19:27\nBangkok, Thailand',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
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

  Widget _buildInstructionsCard(Size size, bool isTablet) {
    List<String> fullInstructions = [
      'Rinse the bottle before disposing. Flatten to save space in the bin',
      'Remove bottle caps and labels before recycling',
      'Make sure the bottle is completely empty before disposal',
      'Check for any plastic film or shrink wrap that should be removed',
      'Clean any sticky residue from labels',
      'Sort by plastic type if your recycling center requires it',
      'Place in the designated green bin for recyclable plastics',
      'Do not mix with other types of waste materials',
    ];

    List<String> previewInstructions = fullInstructions.take(3).toList();
    final iconSize = isTablet ? 140.0 : size.width * 0.28;
    final titleFontSize = isTablet ? 20.0 : size.width * 0.045;
    final instructionFontSize = isTablet ? 16.0 : size.width * 0.035;

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
          // Icon at top center
          Center(
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppConstants.lightGreen,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              ),
              child: Image.asset(
                "assets/disposal_instruction_page/bin.jpg",
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Title centered
          Center(
            child: Text(
              'Green Bin (Recyclable Plastic)',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Scrollable instruction list with bullet points
          Container(
            constraints: BoxConstraints(
              maxHeight: isExpanded ? double.infinity : (isTablet ? 160 : 120),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(isExpanded ? fullInstructions : previewInstructions)
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildInstructionItem(
                          entry.key + 1,
                          entry.value,
                          instructionFontSize,
                          isTablet,
                        ),
                      )
                      .toList(),
                  if (!isExpanded && fullInstructions.length > 3)
                    Padding(
                      padding: EdgeInsets.only(
                        left: isTablet ? 28 : 20,
                        top: 4,
                      ),
                      child: Text(
                        '...',
                        style: TextStyle(
                          fontSize: instructionFontSize,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: isTablet ? 20 : 12),

          // Expand/Collapse button
          if (fullInstructions.length > 3) _buildExpandButton(size, isTablet),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    int index,
    String instruction,
    double fontSize,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: isTablet ? 28 : 24,
            height: isTablet ? 28 : 24,
            margin: EdgeInsets.only(right: isTablet ? 16 : 14, top: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryGreen,
                  AppConstants.primaryGreen.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Instruction text
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(Size size, bool isTablet) {
    final buttonFontSize = isTablet ? 16.0 : size.width * 0.035;

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: AppConstants.lightGreen,
          borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
          border: Border.all(
            color: AppConstants.primaryGreen.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isExpanded ? 'Show less' : 'Show more steps',
              style: TextStyle(
                fontSize: buttonFontSize,
                color: AppConstants.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppConstants.primaryGreen,
                size: isTablet ? 24 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(Size size, bool isTablet) {
    final navHeight = isTablet ? 100.0 : 80.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final fontSize = isTablet ? 14.0 : 12.0;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true, iconSize, fontSize),
          _buildNavItem(
            Icons.category,
            'Categories',
            false,
            iconSize,
            fontSize,
          ),
          _buildNavItem(Icons.settings, 'Settings', false, iconSize, fontSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    double iconSize,
    double fontSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? AppConstants.primaryGreen : Colors.grey,
          size: iconSize,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: isActive ? AppConstants.primaryGreen : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../utils/constants.dart';

// class DisposalInstructionsPage extends StatefulWidget {
//   final String imagePath;
//   final Map<String, dynamic> analysisResult;

//   const DisposalInstructionsPage({
//     super.key,
//     required this.imagePath,
//     required this.analysisResult,
//   });

//   @override
//   State<DisposalInstructionsPage> createState() =>
//       _DisposalInstructionsPageState();
// }

// class _DisposalInstructionsPageState extends State<DisposalInstructionsPage> {
//   bool isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: AppConstants.lightGreen,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // Header section
//             _buildHeader(context, size),

//             // Main content - scrollable
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(size.width * 0.04),
//                 child: Column(
//                   children: [
//                     // Image container
//                     _buildImageContainer(size),
//                     SizedBox(height: size.height * 0.025),

//                     // Instructions card
//                     _buildInstructionsCard(size),
//                   ],
//                 ),
//               ),
//             ),

//             // Bottom navigation
//             _buildBottomNavigation(size),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, Size size) {
//     final padding = size.width * 0.04;
//     final titleFontSize = size.width * 0.045;

//     return Container(
//       padding: EdgeInsets.all(padding),
//       child: Row(
//         children: [
//           // Back button
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha:0.1),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24),
//               onPressed: () => context.pop(),
//             ),
//           ),

//           // Centered title with icon
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppConstants.primaryGreen.withValues(alpha:0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.recycling,
//                     color: AppConstants.primaryGreen,
//                     size: 28,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Flexible(
//                   child: Text(
//                     'How to dispose this item',
//                     style: TextStyle(
//                       fontSize: titleFontSize,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(width: 48), // Balance the row
//         ],
//       ),
//     );
//   }

//   Widget _buildImageContainer(Size size) {
//     final imageHeight = size.height * 0.35;

//     return Container(
//       height: imageHeight,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.1),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.file(
//               File(widget.imagePath),
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           ),

//           // Location overlay
//           Positioned(
//             bottom: 16,
//             right: 16,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.location_on, color: Colors.white, size: 12),
//                   SizedBox(width: 4),
//                   Text(
//                     'May 10, 2025 - 19:27\nBangkok, Thailand',
//                     style: TextStyle(color: Colors.white, fontSize: 10),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInstructionsCard(Size size) {
//     List<String> fullInstructions = [
//       'Rinse the bottle before disposing. Flatten to save space in the bin',
//       'Remove bottle caps and labels before recycling',
//       'Make sure the bottle is completely empty before disposal',
//       'Check for any plastic film or shrink wrap that should be removed',
//       'Clean any sticky residue from labels',
//       'Sort by plastic type if your recycling center requires it',
//       'Place in the designated green bin for recyclable plastics',
//       'Do not mix with other types of waste materials',
//     ];

//     List<String> previewInstructions = fullInstructions.take(3).toList();
//     final iconSize = size.width * 0.28;
//     final titleFontSize = size.width * 0.045;
//     final instructionFontSize = size.width * 0.035;

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.1),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Icon at top center
//           Center(
//             child: Container(
//               width: iconSize,
//               height: iconSize,
//               decoration: BoxDecoration(
//                 color: AppConstants.lightGreen,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Image.asset(
//                 "assets/disposal_instruction_page/bin.jpg",
//                 width: iconSize,
//                 height: iconSize,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 16),

//           // Title centered
//           Center(
//             child: Text(
//               'Green Bin (Recyclable Plastic)',
//               style: TextStyle(
//                 fontSize: titleFontSize,
//                 fontWeight: FontWeight.bold,
//                 color: AppConstants.primaryGreen,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           SizedBox(height: 16),

//           // Scrollable instruction list with bullet points
//           Container(
//             constraints: BoxConstraints(
//               maxHeight: isExpanded ? double.infinity : 120,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ...(isExpanded ? fullInstructions : previewInstructions)
//                       .asMap()
//                       .entries
//                       .map(
//                         (entry) => _buildInstructionItem(
//                           entry.key + 1,
//                           entry.value,
//                           instructionFontSize,
//                         ),
//                       )
//                       .toList(),
//                   if (!isExpanded && fullInstructions.length > 3)
//                     Padding(
//                       padding: EdgeInsets.only(left: 20, top: 4),
//                       child: Text(
//                         '...',
//                         style: TextStyle(
//                           fontSize: instructionFontSize,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 12),

//           // Expand/Collapse button
//           if (fullInstructions.length > 3) _buildExpandButton(size),
//         ],
//       ),
//     );
//   }

//   Widget _buildInstructionItem(int index, String instruction, double fontSize) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Step number
//           Container(
//             width: 24,
//             height: 24,
//             margin: EdgeInsets.only(right: 14, top: 2),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppConstants.primaryGreen,
//                   AppConstants.primaryGreen.withValues(alpha:0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 '$index',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Instruction text
//           Expanded(
//             child: Text(
//               instruction,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 color: Colors.black87,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpandButton(Size size) {
//     final buttonFontSize = size.width * 0.035;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isExpanded = !isExpanded;
//         });
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: AppConstants.lightGreen,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(
//             color: AppConstants.primaryGreen.withValues(alpha:0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               isExpanded ? 'Show less' : 'Show more steps',
//               style: TextStyle(
//                 fontSize: buttonFontSize,
//                 color: AppConstants.primaryGreen,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(width: 8),
//             AnimatedRotation(
//               turns: isExpanded ? 0.5 : 0.0,
//               duration: Duration(milliseconds: 300),
//               child: Icon(
//                 Icons.keyboard_arrow_down,
//                 color: AppConstants.primaryGreen,
//                 size: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation(Size size) {
//     const navHeight = 80.0;

//     return Container(
//       height: navHeight,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.1),
//             blurRadius: 12,
//             offset: Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(Icons.home, 'Home', true),
//           _buildNavItem(Icons.category, 'Categories', false),
//           _buildNavItem(Icons.settings, 'Settings', false),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? AppConstants.primaryGreen : Colors.grey,
//           size: 24,
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isActive ? AppConstants.primaryGreen : Colors.grey,
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
