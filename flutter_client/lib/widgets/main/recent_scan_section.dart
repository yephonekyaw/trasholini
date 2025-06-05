// widgets/recent_scans_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/scan_history.dart'; // Uncomment when you have the model
// import '../providers/scan_history_provider.dart'; // Uncomment when you have the provider

class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual scan history from provider
    // final scanHistory = ref.watch(scanHistoryProvider);

    // Temporary mock data - replace with real data
    final mockScans = _getMockScanData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              const Expanded( // Make title flexible
                child: Text(
                  'Recent Scans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Optional: View all button
              GestureDetector(
                onTap: () {
                  // Navigate to full scan history page
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Show message if no scans
          if (mockScans.isEmpty)
            _buildEmptyState()
          else
            // Show recent scans
            ...mockScans.take(3).map((scan) => _buildScanItem(scan)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.qr_code_scanner, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start scanning waste items to see your impact!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildScanItem(Map<String, dynamic> scan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scan['iconColor'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              scan['materialIcon'],
              color: scan['iconColor'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded( // Make content area flexible
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned ${scan['material']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle text overflow
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  scan['timeAgo'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Small gap before points
          // Points with fixed width to prevent overflow
          Container(
            constraints: const BoxConstraints(minWidth: 60), // Ensure minimum width
            child: Text(
              scan['points'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Mock data - replace with real scan history
  List<Map<String, dynamic>> _getMockScanData() {
    return [
      {
        'material': 'Plastic Bottle',
        'points': '+80 pts',
        'timeAgo': '2 hours ago',
        'materialIcon': Icons.recycling,
        'iconColor': Colors.green,
      },
      {
        'material': 'Paper Document',
        'points': '+60 pts',
        'timeAgo': '1 day ago',
        'materialIcon': Icons.description,
        'iconColor': Colors.blue,
      },
      {
        'material': 'Aluminum Can',
        'points': '+120 pts',
        'timeAgo': '3 days ago',
        'materialIcon': Icons.sports_bar,
        'iconColor': Colors.amber,
      },
    ];
  }
}