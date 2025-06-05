import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/category/category_item_model.dart';

class CategoryService {
  /// 🔧 MAIN METHOD: Currently using mock data
  static Future<List<CategoryItemModel>> getCategoryItems(
    String categoryId,
  ) async {
    try {
      print('🔄 Fetching items for category: $categoryId');

      // 🔧 COMMENTED OUT: Backend integration (uncomment when backend is ready)
      /*
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/items'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      print('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        // Parse all items
        final allItems = jsonData.map((json) => CategoryItemModel.fromJson(json)).toList();
        
        // Filter items that belong to the requested category
        final categoryItems = allItems.where((item) => item.belongsToCategory(categoryId)).toList();
        
        print('✅ Successfully loaded ${categoryItems.length} items for category $categoryId');
        return categoryItems;
        
      } else if (response.statusCode == 404) {
        print('ℹ️ No items found for category $categoryId');
        return [];
      } else {
        throw Exception('Failed to load items: HTTP ${response.statusCode}');
      }
      */

      // 🎯 TEMPORARY: Using mock data (remove when backend is ready)
      print('⚠️ Using mock data for development');
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay

      final mockItems = _getMockData(categoryId);
      print('✅ Loaded ${mockItems.length} mock items for category $categoryId');
      return mockItems;
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw Exception('No internet connection');
    } on http.ClientException {
      print('❌ Network error: Failed to connect to server');
      throw Exception('Failed to connect to server');
    } on FormatException catch (e) {
      print('❌ Parse error: Invalid response format - $e');
      throw Exception('Invalid response format');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // 🔧 COMMENTED OUT: Alternative backend method (uncomment when needed)
  /*
  static Future<List<CategoryItemModel>> getCategoryItemsFromBackend(String categoryId) async {
    try {
      print('🔄 Fetching items for category from backend: $categoryId');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId/items'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CategoryItemModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load items: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  */

  // 🔧 COMMENTED OUT: Get all items method (uncomment when backend is ready)
  /*
  static Future<List<CategoryItemModel>> getAllItems() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/items'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CategoryItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all items: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  */

  // 🔧 COMMENTED OUT: Search items method (uncomment when backend is ready)
  /*
  static Future<List<CategoryItemModel>> searchItems(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/items/search?q=$query'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CategoryItemModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  */

  /// 🔧 OPTIONAL: Check internet connectivity (commented for now)
  /*
  static Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  */

  /// 🔧 MOCK DATA: Complete dataset with multi-category items
  static List<CategoryItemModel> _getMockData(String categoryId) {
    print('📋 Using mock data for category: $categoryId');

    // Complete mock dataset with multi-category items
    final allMockItems = [
      // PLASTIC ITEMS (Category: 1)
      CategoryItemModel(
        id: '1',
        name: 'Plastic Water Bottle',
        description: 'PET plastic bottle, recyclable',
        imageUrl: 'https://your-backend.com/images/items/plastic_bottle.jpg',
        category: ['1'], // Only plastic
        isRecyclable: true,
        disposalTip: 'Remove cap and rinse before recycling',
      ),
      CategoryItemModel(
        id: '2',
        name: 'Plastic Shopping Bag',
        description: 'Single-use plastic bag',
        imageUrl: 'https://your-backend.com/images/items/plastic_bag.jpg',
        category: ['1'], // Only plastic
        isRecyclable: false,
        disposalTip: 'Take to special collection points at grocery stores',
      ),
      CategoryItemModel(
        id: '3',
        name: 'Yogurt Container',
        description: 'Plastic yogurt container with foil lid',
        imageUrl: 'https://your-backend.com/images/items/yogurt_container.jpg',
        category: ['1'], // Only plastic
        isRecyclable: true,
        disposalTip: 'Remove foil lid, rinse container before recycling',
      ),

      // PAPER ITEMS (Category: 2)
      CategoryItemModel(
        id: '4',
        name: 'Newspaper',
        description: 'Daily newspaper, fully recyclable',
        imageUrl: 'https://your-backend.com/images/items/newspaper.jpg',
        category: ['2'], // Only paper
        isRecyclable: true,
        disposalTip: 'Keep dry and remove plastic inserts',
      ),
      CategoryItemModel(
        id: '5',
        name: 'Cardboard Box',
        description: 'Clean cardboard shipping box',
        imageUrl: 'https://your-backend.com/images/items/cardboard_box.jpg',
        category: ['2'], // Only paper
        isRecyclable: true,
        disposalTip: 'Flatten box and remove tape/labels',
      ),

      // MULTI-CATEGORY ITEMS
      CategoryItemModel(
        id: '6',
        name: 'Pizza Box',
        description: 'Cardboard box with grease stains',
        imageUrl: 'https://your-backend.com/images/items/pizza_box.jpg',
        category: ['2', '8'], // Paper AND Organic (grease)
        isRecyclable: false,
        disposalTip:
            'Remove food waste first, check if box is clean enough to recycle',
      ),
      CategoryItemModel(
        id: '7',
        name: 'Aluminum Can with Label',
        description: 'Soda can with plastic label',
        imageUrl: 'https://your-backend.com/images/items/aluminum_can.jpg',
        category: ['1', '10'], // Plastic label AND Metal can
        isRecyclable: true,
        disposalTip: 'Remove plastic label, rinse can before recycling',
      ),

      // GLASS ITEMS (Category: 4)
      CategoryItemModel(
        id: '8',
        name: 'Glass Wine Bottle',
        description: 'Clear glass bottle',
        imageUrl: 'https://your-backend.com/images/items/wine_bottle.jpg',
        category: ['4'], // Only glass
        isRecyclable: true,
        disposalTip: 'Remove cork and labels before recycling',
      ),
      CategoryItemModel(
        id: '9',
        name: 'Glass Jar with Metal Lid',
        description: 'Jam jar with metal twist lid',
        imageUrl: 'https://your-backend.com/images/items/glass_jar.jpg',
        category: ['4', '10'], // Glass AND Metal
        isRecyclable: true,
        disposalTip: 'Separate glass jar from metal lid for recycling',
      ),

      // E-WASTE ITEMS (Category: 5)
      CategoryItemModel(
        id: '10',
        name: 'Smartphone',
        description: 'Old smartphone with battery',
        imageUrl: 'https://your-backend.com/images/items/smartphone.jpg',
        category: ['5', '10'], // E-waste AND Metal
        isRecyclable: true,
        disposalTip: 'Take to certified e-waste recycling center',
      ),
      CategoryItemModel(
        id: '11',
        name: 'Laptop Computer',
        description: 'Old laptop with battery and plastic casing',
        imageUrl: 'https://your-backend.com/images/items/laptop.jpg',
        category: ['1', '5', '10'], // Plastic, E-waste, AND Metal
        isRecyclable: true,
        disposalTip:
            'Remove battery, take to e-waste center for proper recycling',
      ),

      // TEXTILE WASTE ITEMS (Category: 6)
      CategoryItemModel(
        id: '12',
        name: 'Old T-Shirt',
        description: 'Cotton t-shirt in good condition',
        imageUrl: 'https://your-backend.com/images/items/tshirt.jpg',
        category: ['6'], // Only textile
        isRecyclable: true,
        disposalTip: 'Donate if wearable, or take to textile recycling center',
      ),
      CategoryItemModel(
        id: '13',
        name: 'Sneakers with Rubber Soles',
        description: 'Athletic shoes with mixed materials',
        imageUrl: 'https://your-backend.com/images/items/sneakers.jpg',
        category: ['6', '1'], // Textile AND Plastic (rubber)
        isRecyclable: true,
        disposalTip: 'Take to specialized shoe recycling programs',
      ),

      // CONSTRUCTION ITEMS (Category: 7)
      CategoryItemModel(
        id: '14',
        name: 'Wooden Furniture',
        description: 'Old wooden chair with metal screws',
        imageUrl: 'https://your-backend.com/images/items/wooden_chair.jpg',
        category: ['7', '10'], // Construction AND Metal
        isRecyclable: true,
        disposalTip: 'Remove metal parts, donate if still usable',
      ),

      // ORGANIC ITEMS (Category: 8)
      CategoryItemModel(
        id: '15',
        name: 'Food-Stained Paper Plate',
        description: 'Paper plate with food residue',
        imageUrl: 'https://your-backend.com/images/items/paper_plate.jpg',
        category: ['2', '8'], // Paper AND Organic
        isRecyclable: false,
        disposalTip: 'Compost if biodegradable, otherwise general waste',
      ),
      CategoryItemModel(
        id: '16',
        name: 'Banana Peel',
        description: 'Organic food waste',
        imageUrl: 'https://your-backend.com/images/items/banana_peel.jpg',
        category: ['8'], // Only organic
        isRecyclable: true,
        disposalTip: 'Perfect for composting',
      ),

      // METAL ITEMS (Category: 10)
      CategoryItemModel(
        id: '17',
        name: 'Steel Can',
        description: 'Food can made of steel',
        imageUrl: 'https://your-backend.com/images/items/steel_can.jpg',
        category: ['10'], // Only metal
        isRecyclable: true,
        disposalTip: 'Remove label and rinse before recycling',
      ),

      // PROPERTY ITEMS (Category: 3) - Large household items
      CategoryItemModel(
        id: '18',
        name: 'Old Refrigerator',
        description: 'Large appliance with refrigerant',
        imageUrl: 'https://your-backend.com/images/items/refrigerator.jpg',
        category: ['3', '5', '10'], // Property, E-waste, AND Metal
        isRecyclable: true,
        disposalTip: 'Contact appliance recycling service for proper disposal',
      ),

      // IN-ORGANIC ITEMS (Category: 9) - Non-compostable waste
      CategoryItemModel(
        id: '19',
        name: 'Ceramic Plate',
        description: 'Broken ceramic dinnerware',
        imageUrl: 'https://your-backend.com/images/items/ceramic_plate.jpg',
        category: ['9'], // Only in-organic
        isRecyclable: false,
        disposalTip: 'Wrap in newspaper and dispose in general waste',
      ),
      CategoryItemModel(
        id: '20',
        name: 'Disposable Diaper',
        description: 'Used disposable diaper',
        imageUrl: 'https://your-backend.com/images/items/diaper.jpg',
        category: ['1', '9'], // Plastic AND In-organic
        isRecyclable: false,
        disposalTip: 'Dispose in general waste bin',
      ),
    ];

    // Filter items that belong to the requested category
    final categoryItems =
        allMockItems
            .where((item) => item.belongsToCategory(categoryId))
            .toList();

    print('📊 Found ${categoryItems.length} items for category $categoryId');
    return categoryItems;
  }
}

// 🔧 BACKEND INTEGRATION GUIDE (for when backend is ready):
/*
TO ENABLE BACKEND INTEGRATION:

1. Uncomment the backend integration code in getCategoryItems()
2. Comment out the mock data usage
3. Uncomment other methods as needed (getAllItems, searchItems, etc.)
4. Update api_config.dart with real backend URL
5. Test with real API endpoints

EXAMPLE OF WHAT TO UNCOMMENT:
- Line 15-35: Real API call in getCategoryItems()
- Line 45-65: getCategoryItemsFromBackend() method  
- Line 70-85: getAllItems() method
- Line 90-105: searchItems() method
- Line 110-120: hasInternetConnection() method

THEN COMMENT OUT:
- Line 40-43: Mock data usage in getCategoryItems()
*/
