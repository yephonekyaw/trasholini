// lib/widgets/trash_bin/trash_bin_card.dart
import 'package:flutter/material.dart';
import '../../models/trash_bin/trash_bin.dart';

class TrashBinCard extends StatelessWidget {
  final TrashBin bin;
  final VoidCallback onTap;
  final VoidCallback onArrowTap;

  const TrashBinCard({
    Key? key,
    required this.bin,
    required this.onTap,
    required this.onArrowTap,
  }) : super(key: key);

  // Get enhanced color for better visibility
  Color get enhancedBinColor {
    switch (bin.id) {
      case 'yellow':
        return const Color(0xFFF57C00); // Darker orange-yellow
      case 'grey':
        return const Color(0xFF757575); // Slightly lighter grey for better distinction
      case 'green':
        return const Color(0xFF388E3C); // Darker, more vibrant green
      default:
        return bin.color;
    }
  }

  // Get color for details box - always use enhanced colors for better visibility
  Color get detailsBoxColor {
    switch (bin.id) {
      case 'yellow':
        return const Color(0xFFF57C00); // Always use enhanced yellow for details
      case 'grey':
        return const Color(0xFF757575); // Slightly lighter grey for better distinction from blue
      case 'green':
        return const Color(0xFF388E3C); // Darker, more vibrant green
      default:
        return bin.color;
    }
  }

  // Get background opacity based on bin color for better visibility
  double get backgroundOpacity {
    switch (bin.id) {
      case 'yellow':
        return 0.2; // Higher opacity for yellow to make it more visible
      case 'grey':
        return 0.15; // Slightly higher for grey
      case 'green':
        return 0.15; // Higher opacity for green to make it more distinct from blue
      default:
        return 0.1; // Normal opacity for other colors
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayColor = enhancedBinColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bin.isSelected 
              ? displayColor.withOpacity(0.4)
              : Colors.grey.shade300, // More visible unselected border
            width: bin.isSelected ? 2.5 : 1.5, // Thicker borders
          ),
          boxShadow: [
            BoxShadow(
              color: bin.isSelected 
                ? displayColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
              blurRadius: bin.isSelected ? 10 : 6,
              offset: const Offset(0, 3),
              spreadRadius: bin.isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Selection indicator - Made smaller
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bin.isSelected
                          ? displayColor
                          : Colors.transparent,
                      border: Border.all(
                        color: bin.isSelected
                            ? displayColor
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                      boxShadow: bin.isSelected ? [
                        BoxShadow(
                          color: displayColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ] : [],
                    ),
                    child: bin.isSelected
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            
            // Bin image
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: bin.isSelected 
                    ? displayColor.withOpacity(0.15)
                    : detailsBoxColor.withOpacity(backgroundOpacity),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bin.isSelected 
                      ? displayColor.withOpacity(0.3)
                      : detailsBoxColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      bin.imagePath,
                      width: 45,
                      height: 55,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 45,
                          height: 55,
                          decoration: BoxDecoration(
                            color: bin.isSelected ? displayColor : detailsBoxColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: (bin.isSelected ? displayColor : detailsBoxColor).withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Bin info with enhanced styling
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bin name - Increased font size for readability
                    Text(
                      bin.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    
                    // Description - Increased font size for readability
                    Expanded(
                      child: Center(
                        child: Text(
                          bin.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    // Enhanced Arrow button with navigation - More compact
                    GestureDetector(
                      onTap: onArrowTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: bin.isSelected ? [
                              displayColor.withOpacity(0.15),
                              displayColor.withOpacity(0.25),
                            ] : [
                              detailsBoxColor.withOpacity(0.12),
                              detailsBoxColor.withOpacity(0.22),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: bin.isSelected 
                              ? displayColor.withOpacity(0.4)
                              : detailsBoxColor.withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (bin.isSelected ? displayColor : detailsBoxColor).withOpacity(0.15),
                              blurRadius: 1,
                              offset: const Offset(0, 0.5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: bin.isSelected 
                                  ? displayColor.withOpacity(0.8)
                                  : detailsBoxColor.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward,
                              size: 8,
                              color: bin.isSelected 
                                ? displayColor.withOpacity(0.8)
                                : detailsBoxColor.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}