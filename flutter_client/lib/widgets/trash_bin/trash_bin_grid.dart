// lib/widgets/trash_bin/trash_bin_grid.dart
import 'package:flutter/material.dart';
import '../../models/trash_bin/trash_bin.dart';
import 'trash_bin_card.dart';

class TrashBinGrid extends StatelessWidget {
  final List<TrashBin> trashBins;
  final Function(String) onBinTap;
  final Function(TrashBin) onBinDetailsTap;

  const TrashBinGrid({
    Key? key,
    required this.trashBins,
    required this.onBinTap,
    required this.onBinDetailsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: trashBins.length,
          itemBuilder: (context, index) {
            final bin = trashBins[index];
            return TrashBinCard(
              bin: bin,
              onTap: () => onBinTap(bin.id),
              onArrowTap: () => onBinDetailsTap(bin),
            );
          },
        ),
      ),
    );
  }
}