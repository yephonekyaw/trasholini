import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import '../../models/main/waste_bin.dart';

class WasteBinProfile extends StatelessWidget {
  final List<WasteBin> bins;
  const WasteBinProfile({super.key, required this.bins});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap the entire card with GestureDetector
      onTap: () {
        context.go('/trash'); // Navigate to the /trash route
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Waste Bin Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'Bins categorized for proper waste disposal',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Bin list
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bins.length > 6 ? 6 + 1 : bins.length,
                itemBuilder: (context, index) {
                  if (index < 6 && index < bins.length) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: BinCard(bin: bins[index]),
                    );
                  } else if (index == 6 && bins.length > 6) {
                    return OverflowChip(extraCount: bins.length - 6);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BinCard extends StatelessWidget {
  final WasteBin bin;
  const BinCard({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 70,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            bin.imageUrl.endsWith('.svg')
                ? SvgPicture.asset(bin.imageUrl, fit: BoxFit.contain)
                : Image.asset(bin.imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}

class OverflowChip extends StatelessWidget {
  final int extraCount;
  const OverflowChip({super.key, required this.extraCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          '+$extraCount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
