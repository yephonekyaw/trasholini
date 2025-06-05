// lib/widgets/category_item_card.dart
import 'package:flutter/material.dart';
import '../../models/category/category_item_model.dart';
import 'category_badges.dart';
import 'item_detail_modal.dart';

class CategoryItemCard extends StatelessWidget {
  final CategoryItemModel item;
  final int index;

  const CategoryItemCard({Key? key, required this.item, this.index = 0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delay = index * 100;
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Optimized detection for modern phones like Xiaomi 13
    final isModernPhone =
        screenHeight > 700 && screenHeight < 900 && screenWidth > 360;
    final isSmallScreen = screenHeight < 800; // Most modern phones
    final isLandscape = screenWidth > screenHeight;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => ItemDetailModal.show(context, item),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFF8FCF8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Optimized for Xiaomi 13 and similar phones
                      Expanded(
                        flex: isModernPhone ? 5 : (isSmallScreen ? 3 : 4),
                        child: _buildImageSection(isModernPhone, isSmallScreen),
                      ),
                      // Content section with optimal space for text
                      Expanded(
                        flex: isModernPhone ? 4 : (isSmallScreen ? 4 : 3),
                        child: _buildContentSection(
                          isModernPhone,
                          isSmallScreen,
                          isLandscape,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isModernPhone, bool isSmallScreen) {
    final margin = isModernPhone ? 10.0 : (isSmallScreen ? 8.0 : 12.0);

    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE8F5E8),
              child: _buildItemImage(),
            ),
            if (item.category.isNotEmpty)
              Positioned(
                top: 6,
                left: 6,
                child: CategoryBadges(
                  categories: item.category,
                  isCardView: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    bool isModernPhone,
    bool isSmallScreen,
    bool isLandscape,
  ) {
    final horizontalPadding =
        isModernPhone ? 10.0 : (isSmallScreen ? 8.0 : 12.0);
    final verticalPadding = isModernPhone ? 8.0 : (isSmallScreen ? 8.0 : 12.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        4,
        horizontalPadding,
        verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title optimized for Xiaomi 13 visibility
          Flexible(
            flex: 3,
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: isModernPhone ? 14 : (isSmallScreen ? 12 : 14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20),
                height: 1.15,
              ),
              maxLines: isLandscape ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Description - always one line with ellipsis for clean look
          if (isModernPhone || !isSmallScreen)
            Flexible(
              flex: 1,
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: isModernPhone ? 11 : (isSmallScreen ? 10 : 12),
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const Spacer(),

          // Bottom status - always show but compact
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: isModernPhone ? 12 : (isSmallScreen ? 10 : 14),
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Disposal tip',
                  style: TextStyle(
                    fontSize: isModernPhone ? 10 : (isSmallScreen ? 9 : 11),
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    if (item.imageUrl.startsWith('http')) {
      return Image.network(
        item.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: const Color(0xFF4CAF50),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    } else {
      return Image.asset(
        item.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withValues(alpha: 0.2),
            const Color(0xFF81C784).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Colors.grey[500],
      ),
    );
  }
}
