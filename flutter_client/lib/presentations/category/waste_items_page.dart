import 'package:flutter/material.dart';
import 'package:flutter_client/models/waste_history_model.dart';
import 'package:flutter_client/providers/waste_history_provider.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WasteItemsPage extends ConsumerStatefulWidget {
  final String wasteClass;

  const WasteItemsPage({Key? key, required this.wasteClass}) : super(key: key);

  @override
  ConsumerState<WasteItemsPage> createState() => _WasteItemsPageState();
}

class _WasteItemsPageState extends ConsumerState<WasteItemsPage> {
  String get displayName {
    // Convert wasteClass to a readable display name
    return widget.wasteClass[0].toUpperCase() +
        widget.wasteClass.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    // Load waste items for this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(wasteHistoryProvider.notifier)
          .loadByWasteClass(wasteClass: widget.wasteClass);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wasteHistoryState = ref.watch(wasteHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(child: _buildBody(context, wasteHistoryState)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => ref.read(routerProvider).go('/categories'),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your scanned ${displayName.toLowerCase()} items',
                  style: TextStyle(
                    color: const Color(0xFF388E3C).withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WasteHistoryState state) {
    if (state.isLoading && state.items.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null) {
      return _buildErrorState(context);
    }

    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSuccessState(context, state.items);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50)),
          SizedBox(height: 16),
          Text(
            'Loading waste items...',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Failed to load waste items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(wasteHistoryProvider.notifier)
                  .loadByWasteClass(wasteClass: widget.wasteClass);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${displayName.toLowerCase()} items found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning items to see them here!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    List<DisposalHistoryItem> items,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(wasteHistoryProvider.notifier).refresh();
      },
      color: const Color(0xFF4CAF50),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return _buildWasteItemCard(context, item);
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteItemCard(BuildContext context, DisposalHistoryItem item) {
    return GestureDetector(
      onTap: () => _showItemDetails(context, item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Main image
              Positioned.fill(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8F5E8),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Color(0xFF4CAF50),
                      ),
                    );
                  },
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Overlay content
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recommended bin badge
                    if (item.recommendedBin != null)
                      _buildBadge(
                        item.recommendedBin!.description,
                        Colors.blue.withValues(alpha: 0.9),
                        Icons.delete_outline,
                      ),
                    const SizedBox(height: 4),
                    // Confidence badge
                    _buildBadge(
                      '${(item.confidence * 100).toStringAsFixed(1)}% confident',
                      Colors.green.withValues(alpha: 0.9),
                      Icons.verified,
                    ),
                    // const SizedBox(height: 4),
                    // // Disposal tips preview
                    // _buildBadge(
                    //   _truncateText(item.disposalTips, 50),
                    //   Colors.orange.withValues(alpha: 0.9),
                    //   Icons.tips_and_updates,
                    // ),
                    // const SizedBox(height: 4),
                    // // Date badge
                    // _buildBadge(
                    //   _formatDate(item.savedAt),
                    //   Colors.purple.withValues(alpha: 0.9),
                    //   Icons.access_time,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // String _truncateText(String text, int maxLength) {
  //   if (text.length <= maxLength) return text;
  //   return '${text.substring(0, maxLength)}...';
  // }

  // String _formatDate(String savedAt) {
  //   try {
  //     final date = DateTime.parse(savedAt);
  //     final now = DateTime.now();
  //     final difference = now.difference(date);

  //     if (difference.inDays == 0) {
  //       return DateFormat('HH:mm').format(date);
  //     } else if (difference.inDays == 1) {
  //       return 'Yesterday';
  //     } else if (difference.inDays < 7) {
  //       return '${difference.inDays}d ago';
  //     } else {
  //       return DateFormat('MMM dd').format(date);
  //     }
  //   } catch (e) {
  //     return 'Unknown';
  //   }
  // }

  void _showItemDetails(BuildContext context, DisposalHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailBottomSheet(context, item),
    );
  }

  Widget _buildDetailBottomSheet(
    BuildContext context,
    DisposalHistoryItem item,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image and basic info
                      _buildDetailHeader(item),
                      const SizedBox(height: 24),
                      // Confidence and bin info
                      _buildQuickInfo(item),
                      const SizedBox(height: 24),
                      // Disposal tips section
                      _buildDetailSection(
                        'Disposal Instructions',
                        item.disposalTips,
                        Icons.tips_and_updates,
                        Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      // Preparation steps
                      if (item.preparationSteps.isNotEmpty)
                        _buildDetailSection(
                          'Preparation Steps',
                          item.preparationSteps,
                          Icons.list_alt,
                          Colors.blue,
                        ),
                      const SizedBox(height: 20),
                      // Environmental note
                      if (item.environmentalNote.isNotEmpty)
                        _buildDetailSection(
                          'Environmental Impact',
                          item.environmentalNote,
                          Icons.eco,
                          Colors.green,
                        ),
                      const SizedBox(height: 32),
                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailHeader(DisposalHistoryItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: const Color(0xFFE8F5E8),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 30,
                  color: Color(0xFF4CAF50),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.wasteClass.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scanned on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item.savedAt))}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(item.confidence * 100).toStringAsFixed(1)}% Confidence',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(DisposalHistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'Recommended Bin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (item.recommendedBin != null)
            Text(
              '${item.recommendedBin!.name} - ${item.recommendedBin!.description}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            )
          else
            Text(
              'No specific bin recommended',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
