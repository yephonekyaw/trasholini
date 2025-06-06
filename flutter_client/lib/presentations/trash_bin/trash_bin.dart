import 'package:flutter/material.dart';
import 'package:flutter_client/router/router.dart';
import 'package:flutter_client/widgets/nav/custom_bottom_navigation.dart';
import 'package:flutter_client/widgets/nav/floating_scan_button.dart';
import 'package:flutter_client/widgets/trash_bin/trash_bin_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trash_bin/trash_bin_provider.dart';
import '../../widgets/trash_bin/trash_bin_header.dart';
import 'trash_bin_details.dart'; // Import the details page

class TrashBinPage extends ConsumerWidget {
  const TrashBinPage({Key? key}) : super(key: key);

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Preferences saved successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
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

    return null;
  }

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
          onPressed: () => ref.read(routerProvider).go('/'),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header section
            TrashBinHeader(
              allSelected: trashBinNotifier.allSelected,
              onSelectAllTap: () {
                if (trashBinNotifier.allSelected) {
                  trashBinNotifier.deselectAllBins();
                } else {
                  trashBinNotifier.selectAllBins();
                }
              },
              onSavePressed: () async {
                try {
                  await trashBinNotifier.saveBinsToBackend();
                  _showSuccessMessage(context);
                } catch (e) {
                  // Handle error case
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Failed to save. Please try again.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                      elevation: 4,
                    ),
                  );
                }
              },
            ),

            // Grid section - wrapped in Container to give it proper height
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                    onTap: () => trashBinNotifier.toggleBinSelection(bin.id),
                    onArrowTap: () {
                      _navigateToDetailPage(context, bin);
                    },
                  );
                },
              ),
            ),

            // Bottom padding to account for floating action button
            const SizedBox(height: 50),
          ],
        ),
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
}
