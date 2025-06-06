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
    if (!_scrollController.hasClients) return;
    
    // Calculate current page based on scroll position with safety checks
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = _getCardWidth(screenWidth);
    final double itemWidth = cardWidth + 12; // card width + margin
    
    if (itemWidth > 0) {
      final int newPage = (_scrollController.offset / itemWidth).round();
      if (newPage != _currentPage &&
          newPage >= 0 &&
          newPage < widget.categories.length) {
        setState(() {
          _currentPage = newPage;
        });
      }
    }
  }

  // Calculate responsive card width based on screen size
  double _getCardWidth(double screenWidth) {
    if (screenWidth < 360) {
      // Very small screens (old phones)
      return screenWidth * 0.85; // Show mostly one card
    } else if (screenWidth < 600) {
      // Regular phones
      return screenWidth * 0.7; // Show 1.4 cards
    } else if (screenWidth < 900) {
      // Large phones/small tablets
      return screenWidth * 0.45; // Show 2.2 cards
    } else {
      // Tablets and larger
      return screenWidth * 0.3; // Show 3+ cards
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = _getCardWidth(screenWidth);
    
    // Responsive padding
    final double horizontalPadding = screenWidth < 360 ? 12 : 20;
    final double verticalPadding = screenWidth < 360 ? 16 : 20;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth < 360 ? 8 : 16,
        vertical: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Responsive header
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
                  size: screenWidth < 360 ? 18 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Waste Categories',
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth < 360 ? 16 : 20),

          // Responsive categories list
          SizedBox(
            height: screenWidth < 360 ? 160 : 180,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: index == widget.categories.length - 1 ? 0 : 12,
                  ),
                  child: EnhancedCategoryCard(
                    category: category,
                    isCompact: screenWidth < 360,
                  ),
                );
              },
            ),
          ),

          // Responsive category indicators
          SizedBox(height: screenWidth < 360 ? 12 : 16),
          if (widget.categories.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.categories.length,
                (index) => GestureDetector(
                  onTap: () => _scrollToCategory(index, cardWidth),
                  child: Container(
                    width: screenWidth < 360 ? 6 : 8,
                    height: screenWidth < 360 ? 6 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: index == _currentPage
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

  void _scrollToCategory(int index, double cardWidth) {
    final double targetOffset = index * (cardWidth + 12);
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}