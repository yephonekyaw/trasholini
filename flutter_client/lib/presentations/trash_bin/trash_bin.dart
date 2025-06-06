import 'package:flutter/material.dart';
import 'package:flutter_client/presentations/trash_bin/trash_bin_details.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trash_bin/trash_bin_provider.dart';
import '../../widgets/trash_bin/trash_bin_header.dart';
import '../../widgets/trash_bin/trash_bin_grid.dart';


class TrashBinPage extends ConsumerWidget {
  const TrashBinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashBins = ref.watch(trashBinProvider);
    final trashBinNotifier = ref.read(trashBinProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'TRASHOLINI',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TrashBinHeader(
            allSelected: trashBinNotifier.allSelected,
            onSelectAllTap: () {
              if (trashBinNotifier.allSelected) {
                trashBinNotifier.deselectAllBins();
              } else {
                trashBinNotifier.selectAllBins();
              }
            },
            onSavePressed: () {
              final selectedBins = trashBinNotifier.selectedBins;
              print(
                'Selected bins: ${selectedBins.map((b) => b.name).join(', ')}',
              );
            },
          ),
          TrashBinGrid(
            trashBins: trashBins,
            onBinTap: (binId) => trashBinNotifier.toggleBinSelection(binId),
            onBinDetailsTap: (bin) {
              print('Navigate to ${bin.name} details page');
              _navigateToDetailPage(context, bin);
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(),
      floatingActionButton: FloatingScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToDetailPage(BuildContext context, dynamic bin) {
    TrashBinDetailPage? detailPage = _getDetailPageForBin(bin);
    
    if (detailPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => detailPage),
      );
    } else {
      // Fallback for unknown bin types
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details for ${bin.name} coming soon!')),
      );
    }
  }

  TrashBinDetailPage? _getDetailPageForBin(dynamic bin) {
    // Map based on bin name or ID
    String binName = bin.name.toString().toLowerCase();
    
    if (binName.contains('green')) {
      return TrashBinData.greenBin;
    } else if (binName.contains('red')) {
      return TrashBinData.redBin;
    } else if (binName.contains('yellow')) {
      return TrashBinData.yellowBin;
    } else if (binName.contains('blue')) {
      return TrashBinData.blueBin;
    } else if (binName.contains('grey') || binName.contains('gray')) {
      return TrashBinData.greyBin;
    }
    
    // Alternative mapping based on ID if you have specific IDs
    // You can also use bin.id if your bin object has an ID field
    /*
    switch (bin.id) {
      case 'green_bin':
        return TrashBinData.greenBin;
      case 'red_bin':
        return TrashBinData.redBin;
      case 'yellow_bin':
        return TrashBinData.yellowBin;
      case 'blue_bin':
        return TrashBinData.blueBin;
      case 'grey_bin':
        return TrashBinData.greyBin;
      default:
        return null;
    }
    */
    
    return null;
  }
}