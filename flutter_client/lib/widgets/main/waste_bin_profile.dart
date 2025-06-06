import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class WasteBinProfile extends StatelessWidget {
  const WasteBinProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Your real bin data
    final List<Map<String, String>> bins = [
      {
        'id': 'IAwm6VLUto6hIHKg2p2U',
        'name': 'Blue Bin',
        'colorHex': '#2196F3',
        'type': 'Recyclable Waste',
        'imageUrl': 'assets/trashbins/bluetrashbin.svg',
      },
      {
        'id': 'JWU85wViqZWpwa06T2Gp',
        'name': 'Red Bin',
        'colorHex': '#F44336',
        'type': 'Hazardous Waste',
        'imageUrl': 'assets/trashbins/redtrashbin.svg',
      },
      {
        'id': 'swBByWbqLGZPDpQr0WbJ',
        'name': 'Green Bin',
        'colorHex': '#4CAF50',
        'type': 'Green Waste',
        'imageUrl': 'assets/trashbins/greentrashbin.svg',
      },
      {
        'id': 'nnqLrEKtFYwN32rYyFpN',
        'name': 'Yellow Bin',
        'colorHex': '#FFC107',
        'type': 'Inorganic Waste',
        'imageUrl': 'assets/trashbins/yellowtrashbin.svg',
      },
      {
        'id': 'YEyKfXmPrwV9rT6PGvWi',
        'name': 'Grey Bin',
        'colorHex': '#9E9E9E', // Fixed the unknown color
        'type': 'Residual Waste',
        'imageUrl': 'assets/trashbins/greytrashbin.svg',
      },
    ];

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
                        Text(
                          '${bins.length} bins configured',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

              // Bins grid - horizontal scrollable
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bins.length,
                  itemBuilder: (context, index) {
                    final bin = bins[index];
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _parseColor(
                            bin['colorHex']!,
                          ).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _parseColor(
                              bin['colorHex']!,
                            ).withValues(alpha: 0.15),
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
                              color: _parseColor(
                                bin['colorHex']!,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                bin['imageUrl']!,
                                width: 32,
                                height: 32,
                                // Remove colorFilter to use original SVG colors
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bin name
                          Text(
                            bin['name']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _parseColor(bin['colorHex']!),
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
                              bin['type']!,
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

              // Scroll indicator
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
          ),
        ),
      ),
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
