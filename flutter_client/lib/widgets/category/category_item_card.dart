// lib/widgets/category_item_card.dart
import 'package:flutter/material.dart';
import '../../models/category/category_item_model.dart';
import 'category_badges.dart';
import 'item_detail_modal.dart';

class CategoryItemCard extends StatelessWidget {
  final CategoryItemModel item;
  final int index;

  const CategoryItemCard({
    Key? key,
    required this.item,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delay = index * 100;
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Enhanced screen detection
    final isSmallScreen = screenHeight < 700;
    final isNarrowScreen = screenWidth < 400;
    final isVeryCompact = isSmallScreen && isNarrowScreen;
    
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
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
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
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive image section
                      Expanded(
                        flex: isVeryCompact ? 1 : (isSmallScreen ? 2 : 3),
                        child: _buildImageSection(isSmallScreen, isNarrowScreen),
                      ),
                      // Responsive content section  
                      Expanded(
                        flex: isVeryCompact ? 2 : (isSmallScreen ? 3 : 2),
                        child: _buildContentSection(isSmallScreen, isNarrowScreen, isVeryCompact),
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

  Widget _buildImageSection(bool isSmallScreen, bool isNarrowScreen) {
    final margin = isNarrowScreen ? 6.0 : (isSmallScreen ? 8.0 : 12.0);
    
    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            if (item.category.isNotEmpty && !isNarrowScreen) // Hide badges on very narrow screens
              Positioned(
                top: isSmallScreen ? 4 : 8,
                left: isSmallScreen ? 4 : 8,
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

  Widget _buildContentSection(bool isSmallScreen, bool isNarrowScreen, bool isVeryCompact) {
    final horizontalPadding = isNarrowScreen ? 6.0 : (isSmallScreen ? 8.0 : 12.0);
    final verticalPadding = isNarrowScreen ? 6.0 : (isSmallScreen ? 8.0 : 12.0);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with enhanced responsive font size
          Flexible(
            flex: isVeryCompact ? 4 : (isSmallScreen ? 3 : 1),
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: isNarrowScreen ? 11 : (isSmallScreen ? 13 : 14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20),
                height: 1.1,
              ),
              maxLines: isVeryCompact ? 4 : (isSmallScreen ? 3 : 1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Description - only show on normal screens
          if (!isSmallScreen && !isNarrowScreen) ...[
            const SizedBox(height: 4),
            Flexible(
              flex: 2,
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          
          const Spacer(),
          
          // Bottom status with enhanced responsive sizing
          if (!isVeryCompact) // Hide on very compact screens to save space
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: isNarrowScreen ? 10 : (isSmallScreen ? 12 : 14),
                  color: Colors.blue.shade600,
                ),
                SizedBox(width: isNarrowScreen ? 2 : (isSmallScreen ? 2 : 4)),
                Expanded(
                  child: Text(
                    'Disposal tip',
                    style: TextStyle(
                      fontSize: isNarrowScreen ? 8 : (isSmallScreen ? 10 : 11),
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
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
            const Color(0xFF4CAF50).withOpacity(0.2),
            const Color(0xFF81C784).withOpacity(0.1),
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