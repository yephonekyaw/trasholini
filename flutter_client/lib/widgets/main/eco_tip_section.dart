// widgets/eco_tip_section.dart

import 'package:flutter/material.dart';

class EcoTipSection extends StatelessWidget {
  const EcoTipSection({super.key});

  // List of eco tips that can rotate daily
  static const List<String> ecoTips = [
    'Rinse containers before recycling to avoid contamination and improve recycling efficiency!',
    'Remove caps and lids from bottles before recycling - they\'re often made of different materials.',
    'Flatten cardboard boxes to save space in recycling bins and transportation.',
    'Paper with plastic coating (like coffee cups) needs special recycling - check local guidelines!',
    'Aluminum cans are 100% recyclable and can be recycled indefinitely without quality loss.',
    'Glass containers should be separated by color (clear, brown, green) for better recycling.',
    'Remove batteries from electronic devices before recycling them at special collection points.',
    'Pizza boxes with grease stains should go to compost, not recycling.',
    'Plastic bags can\'t go in regular recycling - take them to special collection points at stores.',
    'Shredded paper can be composted if it doesn\'t contain sensitive information.',
  ];

  // Get tip of the day based on current date
  String _getTipOfTheDay() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return ecoTips[dayOfYear % ecoTips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F7BA), // Same as profile card
            Color(0x524CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Eco Tip of the Day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),

              // Optional: Add refresh button to get random tip
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco, color: Colors.green[700], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTipOfTheDay(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
