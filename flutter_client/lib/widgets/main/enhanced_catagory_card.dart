import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/waste_category.dart';

class EnhancedCategoryCard extends ConsumerStatefulWidget {
  final WasteCategory category;
  final bool isCompact;

  const EnhancedCategoryCard({
    super.key,
    required this.category,
    this.isCompact = false,
  });

  @override
  ConsumerState<EnhancedCategoryCard> createState() =>
      _EnhancedCategoryCardState();
}

class _EnhancedCategoryCardState extends ConsumerState<EnhancedCategoryCard>
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
    switch (widget.category.name.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF3B82F6);
      case 'paper':
        return const Color(0xFF8B5CF6);
      case 'glass':
        return const Color(0xFF06B6D4);
      case 'metal':
        return const Color(0xFF6B7280);
      case 'organic':
        return const Color(0xFF10B981);
      case 'e-waste':
        return const Color(0xFFF59E0B);
      case 'textile-waste':
      case 'taxtile-waste':
        return const Color(0xFFEC4899);
      case 'construction':
        return const Color(0xFF8B5A2B);
      case 'inorganic':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    // Responsive sizing
    final double borderRadius = widget.isCompact ? 14 : 16;
    final double imageBorderRadius = widget.isCompact ? 10 : 12;
    final double iconSize = widget.isCompact ? 10 : 12;
    final double titleFontSize = widget.isCompact ? 11 : 12;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              _handleCategoryTap();
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
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
                  // Responsive image container
                  Expanded(
                    flex: widget.isCompact ? 6 : 7,
                    child: Container(
                      margin: EdgeInsets.all(widget.isCompact ? 3 : 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(imageBorderRadius),
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
                        borderRadius: BorderRadius.circular(imageBorderRadius),
                        child: Stack(
                          children: [
                            // Background image with error handling
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.category.imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handle image loading error
                                  },
                                ),
                                // Fallback color if image fails
                                color: categoryColor.withValues(alpha: 0.1),
                              ),
                            ),

                            // Gradient overlay
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
                              top: widget.isCompact ? 4 : 6,
                              right: widget.isCompact ? 4 : 6,
                              child: Container(
                                padding: EdgeInsets.all(
                                  widget.isCompact ? 3 : 4,
                                ),
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
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Responsive category info
                  Expanded(
                    flex: widget.isCompact ? 2 : 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        widget.isCompact ? 4 : 6,
                        widget.isCompact ? 1 : 2,
                        widget.isCompact ? 4 : 6,
                        widget.isCompact ? 2 : 3,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Category name with overflow protection
                          Flexible(
                            child: Text(
                              widget.category.name,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    HapticFeedback.lightImpact();
    ref.read(routerProvider).go('/waste-items/${widget.category.name}');
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
      case 'textile-waste':
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
