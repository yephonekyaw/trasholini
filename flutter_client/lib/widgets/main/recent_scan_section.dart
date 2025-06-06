import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_client/providers/waste_history_provider.dart';
import 'package:flutter_client/models/waste_history_model.dart';

class RecentScansSection extends ConsumerStatefulWidget {
  const RecentScansSection({super.key});

  @override
  ConsumerState<RecentScansSection> createState() => _RecentScansSectionState();
}

class _RecentScansSectionState extends ConsumerState<RecentScansSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Load recent scans when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentScansProvider.notifier).loadRecentScans(limit: 10);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentScansState = ref.watch(recentScansProvider);
    final isLoading = recentScansState.isLoading;
    final error = recentScansState.error;
    final recentScans = recentScansState.items;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean Header
            _buildHeader(context),

            // Content
            if (isLoading)
              _buildLoadingState()
            else if (error != null)
              _buildErrorState(error)
            else if (recentScans.isEmpty)
              _buildEmptyState()
            else
              _buildScansList(recentScans),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              'Recent Scans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),

          Text(
            'Unable to load scans',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Check your connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              ref.read(recentScansProvider.notifier).refresh(limit: 10);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              size: 36,
              color: Colors.blue.shade600,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Start scanning waste items to track your environmental impact!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => context.go('/scan'),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScansList(List<DisposalHistoryItem> recentScans) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          ...recentScans.take(5).map((scan) => _buildScanItem(scan)),

          if (recentScans.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => context.go('/disposal-history'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View ${recentScans.length - 5} more scans',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanItem(DisposalHistoryItem scan) {
    final wasteColor = _getWasteClassColor(scan.wasteClass);
    final wasteIcon = _getWasteClassIcon(scan.wasteClass);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: wasteColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: wasteColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(wasteIcon, color: wasteColor, size: 20),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWasteClass(scan.wasteClass),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeAgo(DateTime.parse(scan.savedAt)),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                if (scan.confidence > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(
                        scan.confidence,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(scan.confidence * 100).toInt()}% confidence',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getConfidenceColor(scan.confidence),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  // Helper methods remain the same
  IconData _getWasteClassIcon(String wasteClass) {
    final lowerClass = wasteClass.toLowerCase();

    if (lowerClass.contains('plastic') || lowerClass.contains('bottle')) {
      return Icons.local_drink_rounded;
    } else if (lowerClass.contains('paper') ||
        lowerClass.contains('cardboard')) {
      return Icons.description_rounded;
    } else if (lowerClass.contains('glass')) {
      return Icons.wine_bar_rounded;
    } else if (lowerClass.contains('metal') ||
        lowerClass.contains('can') ||
        lowerClass.contains('aluminum')) {
      return Icons.sports_bar_rounded;
    } else if (lowerClass.contains('electronic') ||
        lowerClass.contains('battery')) {
      return Icons.electrical_services_rounded;
    } else if (lowerClass.contains('food') || lowerClass.contains('organic')) {
      return Icons.restaurant_rounded;
    } else if (lowerClass.contains('textile') ||
        lowerClass.contains('fabric')) {
      return Icons.checkroom_rounded;
    } else {
      return Icons.delete_outline_rounded;
    }
  }

  Color _getWasteClassColor(String wasteClass) {
    final lowerClass = wasteClass.toLowerCase();

    if (lowerClass.contains('plastic') || lowerClass.contains('bottle')) {
      return Colors.blue.shade600;
    } else if (lowerClass.contains('paper') ||
        lowerClass.contains('cardboard')) {
      return Colors.amber.shade600;
    } else if (lowerClass.contains('glass')) {
      return Colors.green.shade600;
    } else if (lowerClass.contains('metal') ||
        lowerClass.contains('can') ||
        lowerClass.contains('aluminum')) {
      return Colors.grey.shade600;
    } else if (lowerClass.contains('electronic') ||
        lowerClass.contains('battery')) {
      return Colors.red.shade600;
    } else if (lowerClass.contains('food') || lowerClass.contains('organic')) {
      return Colors.brown.shade600;
    } else if (lowerClass.contains('textile') ||
        lowerClass.contains('fabric')) {
      return Colors.purple.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green.shade600;
    } else if (confidence >= 0.6) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  String _formatWasteClass(String wasteClass) {
    return wasteClass
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    }
  }
}
