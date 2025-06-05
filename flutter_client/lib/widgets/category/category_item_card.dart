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
                      Expanded(flex: 3, child: _buildImageSection()),
                      Expanded(flex: 2, child: _buildContentSection()),
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

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.all(12),
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
            if (item.category.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: CategoryBadges(categories: item.category, isCardView: true),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: item.isRecyclable ? Colors.green.shade600 : Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.isRecyclable ? Icons.recycling : Icons.delete_outline,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5E20),
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          const Spacer(),
          Row(
            children: [
              Icon(
                item.isRecyclable ? Icons.eco : Icons.warning_amber_rounded,
                size: 14,
                color: item.isRecyclable ? Colors.green.shade600 : Colors.orange.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.isRecyclable ? 'Recyclable' : 'Non-recyclable',
                  style: TextStyle(
                    fontSize: 11,
                    color: item.isRecyclable ? Colors.green.shade600 : Colors.orange.shade600,
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