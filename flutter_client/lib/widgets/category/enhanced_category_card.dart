import 'package:flutter/material.dart';
import '../../models/category/category_model.dart';

class EnhancedCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final int index;

  const EnhancedCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Create a staggered animation delay
    final delay = index * 100;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
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
                onTap: onTap,
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
                    children: [
                      // Image container with enhanced styling
                      Expanded(flex: 3, child: _buildImageContainer()),
                      // Title section with enhanced typography
                      Expanded(flex: 1, child: _buildTitleSection()),
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

  Widget _buildImageContainer() {
    return Container(
      margin: const EdgeInsets.all(12),
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
            // Category image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                category.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          const Color(0xFF81C784).withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.category,
                      size: 40,
                      color: Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay for better visual depth
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
