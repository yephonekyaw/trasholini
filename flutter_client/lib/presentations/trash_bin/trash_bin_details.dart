import 'package:flutter/material.dart';

class TrashBinDetailPage extends StatelessWidget {
  final String binName;
  final Color binColor;
  final Color backgroundColor;
  final String wasteDescription;
  final String binIconAsset;
  final List<WasteItem> wasteItems;

  const TrashBinDetailPage({
    Key? key,
    required this.binName,
    required this.binColor,
    required this.backgroundColor,
    required this.wasteDescription,
    required this.binIconAsset,
    required this.wasteItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TRASHOLINI',
          style: TextStyle(
            color: Color(0xFF7CB342),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Bin Icon and Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bin Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: binColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        binIconAsset,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.delete_outline,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bin Name
                  Text(
                    binName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      children: _buildDescriptionSpan(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Waste Items Grid
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: wasteItems.length,
                  itemBuilder: (context, index) {
                    return _buildWasteItemCard(wasteItems[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildDescriptionSpan() {
    final parts = wasteDescription.split('**');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        spans.add(TextSpan(text: parts[i]));
      } else {
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(fontWeight: FontWeight.bold, color: binColor),
          ),
        );
      }
    }
    return spans;
  }

  Widget _buildWasteItemCard(WasteItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image for item
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: binColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.assetPath,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.red[100],
                    child: Icon(Icons.error, size: 24, color: Colors.red),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WasteItem {
  final String name;
  final String assetPath;

  WasteItem({required this.name, required this.assetPath});
}

// Example usage and data models
class TrashBinData {
  static final greenBin = TrashBinDetailPage(
    binName: 'Green Trash Bin',
    binColor: Color(0xFF4CAF50),
    backgroundColor: Color(0xFFE8F5E8),
    wasteDescription:
        'What type of waste is collected in **green trash bin**?\n\n**Organic waste** such as biodegradable and compostable waste',
    binIconAsset: 'assets/trash_images/green.png',
    wasteItems: [
      WasteItem(
        name: 'Green Waste',
        assetPath: 'assets/trash_images/green_waste.png',
      ),
      WasteItem(
        name: 'Food Waste',
        assetPath: 'assets/trash_images/food_waste.jpg',
      ),
    ],
  );

  static final redBin = TrashBinDetailPage(
    binName: 'Red Trash Bin',
    binColor: Color(0xFFF44336),
    backgroundColor: Color(0xFFFFEBEE),
    wasteDescription:
        'What type of waste is collected in **red trash bin**?\n\n**B3 waste** such as hazardous and toxic materials',
    binIconAsset: 'assets/trash_images/red.png',
    wasteItems: [
      WasteItem(name: 'Battery', assetPath: 'assets/trash_images/battery.png'),
      WasteItem(
        name: 'Glass Bottle',
        assetPath: 'assets/trash_images/glass_bottle.jpg',
      ),
      WasteItem(
        name: 'Detergent',
        assetPath: 'assets/trash_images/detergent.png',
      ),
      WasteItem(
        name: 'Pesticide',
        assetPath: 'assets/trash_images/pesticide.png',
      ),
    ],
  );

  static final yellowBin = TrashBinDetailPage(
    binName: 'Yellow Trash Bin',
    binColor: Color(0xFFFF9800),
    backgroundColor: Color(0xFFFFF8E1),
    wasteDescription:
        'What type of waste is collected in **yellow trash bin**?\n\n**Anorganic waste** such as plastic, can, and styrofoam',
    binIconAsset: 'assets/trash_images/yellow.png',
    wasteItems: [
      WasteItem(
        name: 'Plastic Bag',
        assetPath: 'assets/trash_images/plastic_bag.jpg',
      ),
      WasteItem(
        name: 'Plastic Bottle',
        assetPath: 'assets/trash_images/plastic_bottle.png',
      ),
      WasteItem(name: 'Styrofoam', assetPath: 'assets/trash_images/foam.png'),
      WasteItem(name: 'Can', assetPath: 'assets/trash_images/can.jpg'),
    ],
  );

  static final blueBin = TrashBinDetailPage(
    binName: 'Blue Trash Bin',
    binColor: Color(0xFF2196F3),
    backgroundColor: Color(0xFFE3F2FD),
    wasteDescription:
        'What type of waste is collected in **blue trash bin**?\n\n**Recyclable materials** like dry waste',
    binIconAsset: 'assets/trash_images/blue.png',
    wasteItems: [
      WasteItem(
        name: 'Newspaper',
        assetPath: 'assets/trash_images/newspaper.png',
      ),
      WasteItem(name: 'Paper', assetPath: 'assets/trash_images/paper.png'),
      WasteItem(
        name: 'Cardboard',
        assetPath: 'assets/trash_images/cardboard.png',
      ),
    ],
  );

  static final greyBin = TrashBinDetailPage(
    binName: 'Grey Trash Bin',
    binColor: Color(0xFF757575),
    backgroundColor: Color(0xFFF5F5F5),
    wasteDescription:
        'What type of waste is collected in **grey trash bin**?\n\n**Residual waste** that cannot be classified as recyclable and compostable',
    binIconAsset: 'assets/trash_images/grey.png',
    wasteItems: [
      WasteItem(
        name: 'Cigarette',
        assetPath: 'assets/trash_images/cigarette.png',
      ),
      WasteItem(name: 'Diaper', assetPath: 'assets/trash_images/diaper.png'),
      WasteItem(
        name: 'Sanitary Napkin',
        assetPath: 'assets/trash_images/napkin.png',
      ),
    ],
  );
}
