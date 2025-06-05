import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/waste_category.dart';

final categoriesProvider = FutureProvider<List<WasteCategory>>((ref) async {
  // TEMPORARY: Static data (remove when backend is ready)
  return const [
    WasteCategory(
      id: '1',
      name: 'Plastic',
      imageUrl: 'assets/trash_catagories/plastic.jpg',
      description: 'Plastic bottles, containers, bags',
    ),
    WasteCategory(
      id: '2',
      name: 'Paper',
      imageUrl: 'assets/trash_catagories/paper.jpg',
      description: 'Newspapers, cardboard, office paper',
    ),
    WasteCategory(
      id: '3',
      name: 'Property',
      imageUrl: 'assets/trash_catagories/property.jpg',
      description: 'Electronic devices, furniture',
    ),
    WasteCategory(
      id: '4',
      name: 'Glass',
      imageUrl: 'assets/trash_catagories/glass.jpg',
      description: 'Glass bottles, jars, containers',
    ),
    WasteCategory(
      id: '5',
      name: 'E-Waste',
      imageUrl: 'assets/trash_catagories/e-waste.jpg',
      description: 'phone, laptops, chargers, and other electronic devices',
    ),
    WasteCategory(
      id: '6',
      name: 'Taxtile-Waste',
      imageUrl: 'assets/trash_catagories/taxtile-waste.jpg',
      description: 'Old clothes, fabrics, and textiles',
    ),
    WasteCategory(
      id: '7',
      name: 'Construction',
      imageUrl: 'assets/trash_catagories/construction-waste.jpg',
      description: 'Construction debris, bricks, concrete',
    ),
    WasteCategory(
      id: '8',
      name: 'Inorganic',
      imageUrl: 'assets/trash_catagories/inorganic.jpg',
      description: 'Inorganic materials like metals, glass, and ceramics',
    ),
    WasteCategory(
      id: '9',
      name: 'organic',
      imageUrl: 'assets/trash_catagories/organic.jpg',
      description: 'Food scraps, yard waste, biodegradable materials',
    ),
    WasteCategory(
      id: '10',
      name: 'metal',
      imageUrl: 'assets/trash_catagories/metal.jpg',
      description: 'Metal cans, aluminum foil, and other metal items',
    ),
  ];
});
