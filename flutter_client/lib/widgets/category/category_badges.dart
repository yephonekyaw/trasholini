import 'package:flutter/material.dart';
import '../../utils/category/category_constants.dart';

class CategoryBadges extends StatelessWidget {
  final List<String> categories;
  final bool isCardView;

  const CategoryBadges({
    Key? key,
    required this.categories,
    this.isCardView = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    if (isCardView) {
      return _buildCardView();
    } else {
      return _buildModalView();
    }
  }

  Widget _buildCardView() {
    // For card view, limit to maximum 3 badges to avoid overcrowding
    final displayCategories = categories.take(3).toList();
    final hasMore = categories.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...displayCategories.take(2).map((categoryId) {
              final color = CategoryConstants.getColor(categoryId);
              final name = CategoryConstants.getName(categoryId);

              return Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  name.length > 6 ? name.substring(0, 6) : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
        if (displayCategories.length > 2 || hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (displayCategories.length > 2)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: CategoryConstants.getColor(displayCategories[2]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: CategoryConstants.getColor(
                            displayCategories[2],
                          ).withValues(alpha: 0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      CategoryConstants.getName(displayCategories[2]).length > 6
                          ? CategoryConstants.getName(
                            displayCategories[2],
                          ).substring(0, 6)
                          : CategoryConstants.getName(displayCategories[2]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (hasMore)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${categories.length - 3}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModalView() {
    // Modal view - show all categories in a flexible wrap layout
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          categories.map((categoryId) {
            final color = CategoryConstants.getColor(categoryId);
            final name = CategoryConstants.getName(categoryId);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
    );
  }
}
