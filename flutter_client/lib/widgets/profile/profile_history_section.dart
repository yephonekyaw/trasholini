import 'package:flutter/material.dart';

class ProfileHistorySection extends StatelessWidget {
  const ProfileHistorySection({super.key});

  List<Map<String, dynamic>> _getHistoryData() {
    return [
      {
        'date': 'May 2025',
        'entries': [
          {
            'day': 'Thu 29',
            'time': '14:30',
            'type': 'Scanned Plastic Bottle',
            'description': 'Recycled 30g plastic bottle',
            'amount': '+65 pts',
            'isGained': true,
            'materialIcon': Icons.recycling,
            'iconColor': Colors.green,
          },
          {
            'day': 'Thu 29',
            'time': '09:15',
            'type': 'Scanned Aluminum Can',
            'description': 'Recycled 15g aluminum can',
            'amount': '+85 pts',
            'isGained': true,
            'materialIcon': Icons.sports_bar,
            'iconColor': Colors.amber,
          },
          {
            'day': 'Wed 28',
            'time': '16:45',
            'type': 'Scanned Paper Document',
            'description': 'Recycled 50g paper sheets',
            'amount': '+35 pts',
            'isGained': true,
            'materialIcon': Icons.description,
            'iconColor': Colors.blue,
          },
        ],
      },
      {
        'date': 'April 2025',
        'entries': [
          {
            'day': 'Mon 24',
            'time': '11:20',
            'type': 'Scanned Glass Bottle',
            'description': 'Recycled 400g glass bottle',
            'amount': '+45 pts',
            'isGained': true,
            'materialIcon': Icons.local_drink,
            'iconColor': Colors.teal,
          },
          {
            'day': 'Sun 23',
            'time': '13:05',
            'type': 'Scanned Cardboard Box',
            'description': 'Recycled 200g cardboard',
            'amount': '+40 pts',
            'isGained': true,
            'materialIcon': Icons.inventory_2,
            'iconColor': Colors.brown,
          },
        ],
      },
    ];
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Date and Time
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  entry['day'].split(' ')[0],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  entry['day'].split(' ')[1],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  entry['time'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Material Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: entry['iconColor'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry['materialIcon'],
              color: entry['iconColor'],
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['type'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  entry['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Points
          Text(
            entry['amount'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: entry['isGained'] ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyData = _getHistoryData();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // History Section Header
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Scan History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                // Optional: Filter or sort button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // History List
            if (historyData.isEmpty)
              // Empty state
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No scan history yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start scanning waste items to see your activity here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              // History entries grouped by month
              ...historyData.map(
                (monthData) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              monthData['date'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Month Entries
                    ...monthData['entries']
                        .map<Widget>((entry) => _buildHistoryItem(entry))
                        .toList(),
                  ],
                ),
              ),
            // REMOVED: const SizedBox(height: 100), // This is now controlled by parent
          ],
        ),
      ),
    );
  }
}