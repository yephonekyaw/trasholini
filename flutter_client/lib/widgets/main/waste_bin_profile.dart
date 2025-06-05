import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/main/waste_bin.dart';

class WasteBinProfile extends StatelessWidget {
  final List<WasteBin> bins;

  const WasteBinProfile({super.key, required this.bins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Waste Bin Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Bin Icons
          Row(
            children:
                bins
                    .map(
                      (bin) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: BinIcon(bin: bin),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class BinIcon extends StatelessWidget {
  final WasteBin bin;

  const BinIcon({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            bin.imageUrl.endsWith('.svg')
                ? SvgPicture.asset(bin.imageUrl, fit: BoxFit.contain)
                : Image.asset(
                  bin.imageUrl,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
      ),
    );
  }
}
