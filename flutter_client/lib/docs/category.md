# Clean Backend Integration Guide

## 🏗️ Clean Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
├─────────────────────────────────────────────────────────────┤
│  📱 UI/Screens          │  🎛️ State Management             │
│  • categories_screen    │  • Riverpod Providers            │
│  • category_detail      │  • AsyncNotifierProvider         │
│  • Extracted Widgets    │  • Automatic State Management    │
└─────────────────────────────────────────────────────────────┘
                              ⬇️
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  📋 Models              │  🔄 Business Logic                │
│  • CategoryModel        │  • Multi-category Support        │
│  • CategoryItemModel    │  • Data Validation               │
│  • Category Constants   │  • Filtering Logic               │
└─────────────────────────────────────────────────────────────┘
                              ⬇️
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  🛠️ Services            │  ⚙️ Configuration                │
│  • CategoryService      │  • API Config                    │
│  • HTTP Calls           │  • Headers & Timeouts            │
│  • Error Handling       │  • Environment Settings          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Updated File Structure
```
lib/
├── main.dart                     ✅ Already has ProviderScope
├── core/
│   └── utils/
│       └── category_constants.dart ✅ Extracted constants
├── screens/
│   ├── categories_screen.dart    ✅ Enhanced UI (ConsumerWidget)
│   └── category_detail_screen.dart ✅ Clean architecture (~90 lines)
├── providers/
│   └── category_providers.dart   ✅ Enhanced with AsyncNotifierProvider
├── models/
│   ├── category_model.dart       ✅ No changes needed
│   └── category_item_model.dart  🔧 Update for category arrays
├── services/
│   └── category_service.dart     🔧 Currently using mock data
├── widgets/
│   ├── category_card.dart        ✅ No changes needed
│   ├── category_badges.dart      ✅ Extracted widget
│   ├── category_item_card.dart   ✅ Extracted widget
│   └── item_detail_modal.dart    ✅ Extracted widget
└── config/
    └── api_config.dart           🆕 Create this file
```

---

## 🎯 Step-by-Step Integration

### **Step 1: Create API Configuration**
**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  // 🔧 CHANGE THIS: Your actual backend URL
  static const String baseUrl = 'https://your-backend-api.com/api';
  
  // API endpoints
  static const String itemsEndpoint = '/items';
  static const String healthEndpoint = '/health';
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authentication if needed:
    // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
  };
  
  // Settings
  static const Duration timeout = Duration(seconds: 30);
  
  // Helper methods
  static String get allItemsUrl => '$baseUrl$itemsEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
}
```

### **Step 2: Update Category Item Model**
**File:** `lib/models/category_item_model.dart`

**Changes needed:**
- Change `categoryId` → `category` array
- Add helper methods for multi-category support

```dart
class CategoryItemModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> category; // 🔧 CHANGED: Array instead of single ID
  final bool isRecyclable;
  final String disposalTip;

  CategoryItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category, // 🔧 CHANGED
    required this.isRecyclable,
    required this.disposalTip,
  });

  // 🔧 UPDATED: Parse category array from JSON
  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      category: _parseCategoryArray(json['category']), // 🔧 NEW
      isRecyclable: json['is_recyclable'] == true,
      disposalTip: json['disposal_tip']?.toString() ?? '',
    );
  }

  // 🔧 NEW: Helper to safely parse category array
  static List<String> _parseCategoryArray(dynamic categoryData) {
    if (categoryData == null) return [];
    if (categoryData is List) {
      return categoryData.map((e) => e.toString()).toList();
    }
    if (categoryData is String) {
      return [categoryData]; // Single category as array
    }
    return [];
  }

  // 🔧 NEW: Check if item belongs to category
  bool belongsToCategory(String categoryId) {
    return category.contains(categoryId);
  }

  // 🔧 NEW: Check if item has multiple categories
  bool get isMultiCategory => category.length > 1;

  // 🔧 NEW: Get primary category (first in array)
  String get primaryCategory => category.isNotEmpty ? category.first : '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category, // 🔧 CHANGED: Send as array
      'is_recyclable': isRecyclable,
      'disposal_tip': disposalTip,
    };
  }

  CategoryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? category, // 🔧 CHANGED: Now array
    bool? isRecyclable,
    String? disposalTip,
  }) {
    return CategoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category, // 🔧 CHANGED
      isRecyclable: isRecyclable ?? this.isRecyclable,
      disposalTip: disposalTip ?? this.disposalTip,
    );
  }
}
```

### **Step 3: Update Category Service**
**File:** `lib/services/category_service.dart`

**What to change:**
1. Uncomment backend integration code
2. Comment out mock data usage
3. Update API URL

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category_item_model.dart';
import '../config/api_config.dart';

class CategoryService {
  static Future<List<CategoryItemModel>> getCategoryItems(String categoryId) async {
    try {
      // 🔧 STEP 3A: Uncomment this section for backend integration
      /*
      final response = await http.get(
        Uri.parse(ApiConfig.allItemsUrl),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final allItems = jsonData.map((json) => CategoryItemModel.fromJson(json)).toList();
        
        // Filter items by category using new belongsToCategory method
        return allItems.where((item) => item.belongsToCategory(categoryId)).toList();
      } else {
        throw Exception('Failed to load items: HTTP ${response.statusCode}');
      }
      */
      
      // 🔧 STEP 3B: Comment out this section when backend is ready
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockData(categoryId);
      
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Keep mock data for testing (remove when backend works)
  static List<CategoryItemModel> _getMockData(String categoryId) {
    final List<CategoryItemModel> allMockItems = [
      CategoryItemModel(
        id: '1',
        name: 'Plastic Water Bottle',
        description: 'PET plastic bottle, recyclable',
        imageUrl: 'assets/items/plastic_bottle.jpg',
        category: ['1'], // Single category
        isRecyclable: true,
        disposalTip: 'Remove cap and rinse before recycling',
      ),
      CategoryItemModel(
        id: '6',
        name: 'Pizza Box',
        description: 'Cardboard box with grease stains',
        imageUrl: 'assets/items/pizza_box.jpg',
        category: ['2', '8'], // Multi-category item
        isRecyclable: false,
        disposalTip: 'Remove food waste first, check local guidelines',
      ),
      // Add more mock items here...
    ];

    // Filter items that belong to the requested category
    return allMockItems.where((item) => item.belongsToCategory(categoryId)).toList();
  }
}
```

### **Step 4: Update Enhanced Providers (Already Done)**
Your `category_providers.dart` is already updated with:
- ✅ **AsyncNotifierProvider** for better state management
- ✅ **Search functionality** with filtered providers
- ✅ **Statistics provider** for category analytics
- ✅ **Proper error handling** with retry mechanisms

### **Step 5: Test Backend Integration**

#### **5A: Update API URL**
```dart
// In lib/config/api_config.dart
static const String baseUrl = 'https://your-real-backend.com/api';
```

#### **5B: Enable Backend Code**
```dart
// In lib/services/category_service.dart
// 1. Uncomment lines with backend integration code
// 2. Comment out mock data usage lines
```

#### **5C: Test With Clean Architecture**
1. Run your app
2. Tap on "Plastic" category - should use `CategoryItemCard` widget
3. Tap on any item - should open `ItemDetailModal` with `CategoryBadges`
4. Check console logs for API calls
5. Verify multi-category items show badges correctly

### **Step 6: Verify Backend Response**
Your backend must return this exact JSON structure:

```json
[
  {
    "id": "1",
    "name": "Plastic Water Bottle",
    "description": "PET plastic bottle, recyclable",
    "image_url": "https://your-backend.com/images/plastic_bottle.jpg",
    "category": ["1"],
    "is_recyclable": true,
    "disposal_tip": "Remove cap and rinse before recycling"
  },
  {
    "id": "6", 
    "name": "Pizza Box",
    "description": "Cardboard box with grease stains",
    "image_url": "https://your-backend.com/images/pizza_box.jpg",
    "category": ["2", "8"],
    "is_recyclable": false,
    "disposal_tip": "Remove food waste first"
  }
]
```

---

## ✅ Integration Checklist

### **Phase 1: Setup (5 minutes)**
- [ ] Create `lib/config/api_config.dart`
- [ ] Add your backend URL to `ApiConfig.baseUrl`
- [ ] Ensure `http: ^1.1.0` is in `pubspec.yaml`
- [ ] Verify widget files are in correct locations:
  - [ ] `lib/core/utils/category_constants.dart`
  - [ ] `lib/widgets/category_badges.dart`
  - [ ] `lib/widgets/category_item_card.dart`
  - [ ] `lib/widgets/item_detail_modal.dart`

### **Phase 2: Model Updates (5 minutes)**
- [ ] Update `CategoryItemModel` to use `category` array
- [ ] Add `belongsToCategory()` method
- [ ] Add `isMultiCategory` getter
- [ ] Test JSON parsing with sample data

### **Phase 3: Service Updates (5 minutes)**
- [ ] Uncomment backend integration code in `CategoryService`
- [ ] Update filtering to use `belongsToCategory()` method
- [ ] Comment out mock data usage
- [ ] Test API call with one category

### **Phase 4: Widget Integration Testing (10 minutes)**
- [ ] Test `CategoryBadges` displays correctly in cards (max 3 + overflow)
- [ ] Test `CategoryBadges` displays all categories in modal
- [ ] Test `CategoryItemCard` animations and interactions
- [ ] Test `ItemDetailModal` opens with full category display
- [ ] Verify multi-category items appear in multiple category screens

### **Phase 5: Provider Testing (10 minutes)**
- [ ] Test `categoryItemsNotifierProvider` loads data correctly
- [ ] Test error handling with retry functionality
- [ ] Test pull-to-refresh using `invalidateAndRefresh()`
- [ ] Test search functionality (if implemented)
- [ ] Test statistics provider (if implemented)

### **Phase 6: Cleanup (5 minutes)**
- [ ] Remove mock data methods when backend is stable
- [ ] Remove debug print statements
- [ ] Add authentication headers if needed
- [ ] Verify all imports are correct

---

## 🔧 Updated Import Statements

Make sure your import statements match the new file structure:

### **In category_detail_screen.dart:**
```dart
import '../models/category_item_model.dart';
import '../providers/category_providers.dart';
import '../widgets/category_item_card.dart';
```

### **In category_item_card.dart:**
```dart
import '../models/category_item_model.dart';
import 'category_badges.dart';
import 'item_detail_modal.dart';
```

### **In category_badges.dart:**
```dart
import '../core/utils/category_constants.dart';
```

### **In item_detail_modal.dart:**
```dart
import '../models/category_item_model.dart';
import 'category_badges.dart';
```

---

## 🎯 Architecture Benefits After Today's Changes

### **✅ What You Now Have:**
- **Modular widgets** - Each component has single responsibility
- **Reusable components** - Widgets can be used across different screens
- **Clean main screen** - Only ~90 lines focused on navigation and state
- **Centralized constants** - Category colors/names in one place
- **Enhanced state management** - Better Riverpod patterns with retry/refresh
- **Multi-category support** - Items can belong to multiple categories
- **Search functionality** - Built-in filtering capabilities
- **Statistics tracking** - Category analytics and percentages

### **🚀 Production Ready Features:**
- **Automatic caching** - Data fetched once, cached by Riverpod
- **Error recovery** - Retry buttons with proper state management
- **Loading states** - Built-in loading indicators
- **Pull-to-refresh** - Smooth refresh functionality
- **Memory efficient** - Automatic widget disposal
- **Type safety** - Compile-time error checking
- **Hot reload friendly** - State persists during development

Your app now follows clean architecture principles with properly separated concerns and is ready for production backend integration! 🎉