import 'package:flutter/material.dart';

import 'package:flutter_client/widgets/main/enhanced_catagory_card.dart';
import '../../models/main/waste_category.dart';

class CategoriesSection extends StatefulWidget {
  final List<WasteCategory> categories;

  const CategoriesSection({super.key, required this.categories});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  late ScrollController _scrollController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Use ScrollController instead of PageController for better control
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Calculate current page based on scroll position
    final double itemWidth = MediaQuery.of(context).size.width * 0.32 + 8;
    final int newPage = (_scrollController.offset / itemWidth).round();
    if (newPage != _currentPage &&
        newPage >= 0 &&
        newPage < widget.categories.length) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate card width based on screen
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.32;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - simplified without button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: Colors.green[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Waste Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Enhanced categories with ListView for better left alignment
          SizedBox(
            height: 180,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero, // Remove any default padding
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: index == widget.categories.length - 1 ? 0 : 8,
                  ),
                  child: EnhancedCategoryCard(category: category),
                );
              },
            ),
          ),

          // Category indicators
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.categories.length,
              (index) => GestureDetector(
                onTap: () {
                  // Scroll to the selected category
                  final double targetOffset = index * (cardWidth + 8);
                  _scrollController.animateTo(
                    targetOffset,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color:
                        index == _currentPage
                            ? Colors.green[600]
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
