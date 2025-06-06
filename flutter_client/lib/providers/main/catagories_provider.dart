import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/waste_category.dart';

final categoriesProvider = FutureProvider<List<WasteCategory>>((ref) async {
  return const [
    WasteCategory(
      id: 'biodegradable',
      name: 'Biodegradable',
      imageUrl: 'assets/trash_catagories/organic.jpg',
      description: 'Food scraps, yard waste, compostable items',
    ),
    WasteCategory(
      id: 'cardboard',
      name: 'Cardboard',
      imageUrl: 'assets/trash_catagories/cardboard.jpg',
      description: 'Newspapers, cardboard, office paper',
    ),
    WasteCategory(
      id: 'glass',
      name: 'Glass',
      imageUrl: 'assets/trash_catagories/glass.jpg',
      description: 'Glass bottles, jars, windows',
    ),
    WasteCategory(
      id: 'metal',
      name: 'Metal',
      imageUrl: 'assets/trash_catagories/metal.jpg',
      description: 'Metal cans, aluminum foil, tin',
    ),
    WasteCategory(
      id: 'paper',
      name: 'Paper',
      imageUrl: 'assets/trash_catagories/paper.jpg',
      description: 'Paper products, newspapers',
    ),
    WasteCategory(
      id: 'plastic',
      name: 'Plastic',
      imageUrl: 'assets/trash_catagories/plastic.jpg',
      description: 'Plastic bottles, containers, bags',
    ),
  ];
});
