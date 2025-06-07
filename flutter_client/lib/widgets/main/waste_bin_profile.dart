import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_client/providers/trash_bin/trash_bin_provider.dart';

class WasteBinProfile extends ConsumerWidget {
  const WasteBinProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bins = ref.watch(trashBinProvider.notifier).selectedBins;
    final error = ref.watch(trashBinErrorProvider);

    // Use bins directly from the provider
    final accessibleBins = bins;

    return GestureDetector(
      onTap: () {
        context.go('/trash');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FFF8), Color(0xFFE8F5E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.recycling_rounded,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Waste Bins',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildSubtitle(accessibleBins.length, error),
                      ],
                    ),
                  ),

                  // Navigate indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bins content
              _buildBinsContent(context, accessibleBins, error, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(int binCount, String? error) {
    if (error != null) {
      return Text(
        'Error loading bins',
        style: TextStyle(
          fontSize: 15,
          color: Colors.red[600],
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      binCount == 1 ? '1 bin configured' : '$binCount bins configured',
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBinsContent(
    BuildContext context,
    List<dynamic> accessibleBins,
    String? error,
    WidgetRef ref,
  ) {
    if (error != null) {
      return _buildErrorState(error, ref);
    }

    if (accessibleBins.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildBinsGrid(accessibleBins);
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load bins',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(trashBinProvider.notifier).refreshBins();
              },
              icon: Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'No bins configured',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to set up your bins',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinsGrid(List<dynamic> accessibleBins) {
    return Column(
      children: [
        // Bins grid - horizontal scrollable
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: accessibleBins.length,
            itemBuilder: (context, index) {
              final bin = accessibleBins[index];
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _parseColor(bin.colorHex).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _parseColor(bin.colorHex).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bin icon with colored background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(bin.colorHex).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          bin.imagePath,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bin name
                    Text(
                      bin.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _parseColor(bin.colorHex),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Bin type
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        bin.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Scroll indicator (only show if there are bins and they can scroll)
        if (accessibleBins.length > 3)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swipe_left_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Swipe to see all bins',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _parseColor(String colorHex) {
    try {
      // Remove # if present and ensure it's 6 characters
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Fallback color if parsing fails
    }
    return const Color(0xFF9E9E9E); // Default grey
  }
}
