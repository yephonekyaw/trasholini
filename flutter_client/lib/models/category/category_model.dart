// Simplified data model - removed color field
class CategoryModel {
  final String id;
  final String name;
  final String imageAsset;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  // Add this static categories list
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      name: 'Plastic',
      imageAsset: 'assets/categories_images/plastic.jpg',
    ),
    CategoryModel(
      id: '2',
      name: 'Paper',
      imageAsset: 'assets/categories_images/paper.jpg',
    ),
    CategoryModel(
      id: '3',
      name: 'Property',
      imageAsset: 'assets/categories_images/property.jpg',
    ),
    CategoryModel(
      id: '4',
      name: 'Glass',
      imageAsset: 'assets/categories_images/glass.jpg',
    ),
    CategoryModel(
      id: '5',
      name: 'E-waste',
      imageAsset: 'assets/categories_images/e-waste.jpg',
    ),
    CategoryModel(
      id: '6',
      name: 'Textile waste',
      imageAsset: 'assets/categories_images/textile.jpg',
    ),
    CategoryModel(
      id: '7',
      name: 'Construction',
      imageAsset: 'assets/categories_images/construction.jpg',
    ),
    CategoryModel(
      id: '8',
      name: 'In-organic',
      imageAsset: 'assets/categories_images/in-organic.jpg',
    ),
    CategoryModel(
      id: '9',
      name: 'Organic',
      imageAsset: 'assets/categories_images/organic.jpg',
    ),
    CategoryModel(
      id: '10',
      name: 'Metal',
      imageAsset: 'assets/categories_images/metal.jpg',
    ),
  ];
}