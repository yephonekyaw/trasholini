import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/main/waste_category.dart';

class EnhancedCategoryCard extends StatefulWidget {
  final WasteCategory category;

  const EnhancedCategoryCard({super.key, required this.category});

  @override
  State<EnhancedCategoryCard> createState() => _EnhancedCategoryCardState();
}

class _EnhancedCategoryCardState extends State<EnhancedCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    // Assign colors based on category type for better visual hierarchy
    switch (widget.category.name.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF3B82F6); // Blue
      case 'paper':
        return const Color(0xFF8B5CF6); // Purple
      case 'glass':
        return const Color(0xFF06B6D4); // Cyan
      case 'metal':
        return const Color(0xFF6B7280); // Gray
      case 'organic':
        return const Color(0xFF10B981); // Emerald
      case 'e-waste':
        return const Color(0xFFF59E0B); // Amber
      case 'taxtile-waste':
        return const Color(0xFFEC4899); // Pink
      case 'construction':
        return const Color(0xFF8B5A2B); // Brown
      case 'inorganic':
        return const Color(0xFF6366F1); // Indigo
      default:
        return const Color(0xFF059669); // Default green
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              // Handle the tap action here instead of in onTap
              _handleCategoryTap();
            },
            onTapCancel: () => _animationController.reverse(),
            // Remove the onTap to prevent conflicts
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.15),
                    spreadRadius: 0,
                    blurRadius: _elevationAnimation.value * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Image container with gradient overlay
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // Background image
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.category.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Gradient overlay for better text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    categoryColor.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),

                            // Category icon overlay
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getCategoryIcon(),
                                  color: categoryColor,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Category info
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category name
                          Text(
                            widget.category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 2),

                          // Category description
                          Text(
                            widget.category.description,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Action indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withValues(alpha: 0.1),
                                  categoryColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Learn More',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: categoryColor,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 6,
                                  color: categoryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCategoryTap() {
    // 🔥 FIREBASE INTEGRATION POINT 11: HANDLE CATEGORY SELECTION
    HapticFeedback.lightImpact();

    // Show a simple debug message instead of navigation for now
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${widget.category.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // TODO: Track category interaction in Firebase Analytics
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'category_selected',
    //   parameters: {
    //     'category_id': widget.category.id,
    //     'category_name': widget.category.name,
    //   },
    // );

    // TODO: Navigate to category details screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CategoryDetailsScreen(
    //       category: widget.category,
    //     ),
    //   ),
    // );
  }

  IconData _getCategoryIcon() {
    switch (widget.category.name.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink;
      case 'paper':
        return Icons.description;
      case 'glass':
        return Icons.wine_bar;
      case 'metal':
        return Icons.construction;
      case 'organic':
        return Icons.eco;
      case 'e-waste':
        return Icons.computer;
      case 'taxtile-waste':
        return Icons.checkroom;
      case 'construction':
        return Icons.build;
      case 'inorganic':
        return Icons.science;
      case 'property':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
