import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/waste_bin.dart';

// 🔥 FIREBASE INTEGRATION POINT 6: USER'S SELECTED WASTE BINS
// This will be dynamic based on user preferences stored in Firebase
final userSelectedBinsProvider = FutureProvider<List<WasteBin>>((ref) async {
  // TODO: Fetch user's selected waste bins from Firebase
  // final user = ref.watch(userProvider);
  // if (user == null) return [];

  // try {
  //   final userDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.id)
  //       .get();
  //
  //   final selectedBinIds = List<String>.from(userDoc.data()?['selectedBins'] ?? []);
  //
  //   if (selectedBinIds.isEmpty) {
  //     // Return default bins if user hasn't selected any
  //     return await _getDefaultWasteBins();
  //   }
  //
  //   final binsSnapshot = await FirebaseFirestore.instance
  //       .collection('wasteBins')
  //       .where(FieldPath.documentId, whereIn: selectedBinIds)
  //       .get();
  //
  //   return binsSnapshot.docs.map((doc) {
  //     final data = doc.data();
  //     data['id'] = doc.id; // Add document ID
  //     return WasteBin.fromJson(data);
  //   }).toList();
  // } catch (e) {
  //   debugPrint('Error fetching user selected bins: $e');
  //   return await _getDefaultWasteBins();
  // }

  // TEMPORARY: Static data (remove when backend is ready)
  return const [
    WasteBin(
      id: '1',
      name: 'General',
      colorHex: '#2196F3',
      type: 'general',
      imageUrl: 'assets/trashbins/bluetrashbin.svg',
    ),
    WasteBin(
      id: '2',
      name: 'Recycling',
      colorHex: '#4CAF50',
      type: 'recycling',
      imageUrl: 'assets/trashbins/redtrashbin.svg',
    ),
    WasteBin(
      id: '3',
      name: 'Organic',
      colorHex: '#8BC34A',
      type: 'organic',
      imageUrl: 'assets/trashbins/greentrashbin.svg',
    ),
    WasteBin(
      id: '4',
      name: 'Hazardous',
      colorHex: '#FFC107',
      type: 'hazardous',
      imageUrl: 'assets/trashbins/yellowtrashbin.svg',
    ),
  ];
});

// 🔥 FIREBASE INTEGRATION POINT 7: ALL AVAILABLE WASTE BINS
final wasteBinsProvider = FutureProvider<List<WasteBin>>((ref) async {
  // TODO: Fetch all available waste bins from Firestore
  // try {
  //   final binsSnapshot = await FirebaseFirestore.instance
  //       .collection('wasteBins')
  //       .orderBy('order')
  //       .get();
  //
  //   return binsSnapshot.docs.map((doc) {
  //     final data = doc.data();
  //     data['id'] = doc.id; // Add document ID
  //     return WasteBin.fromJson(data);
  //   }).toList();
  // } catch (e) {
  //   debugPrint('Error fetching waste bins: $e');
  //   return [];
  // }

  // TEMPORARY: Static data (remove when backend is ready)
  return const [
    WasteBin(
      id: '1',
      name: 'General',
      colorHex: '#2196F3',
      type: 'general',
      imageUrl: 'assets/trashbins/bluetrashbin.svg',
    ),
    WasteBin(
      id: '2',
      name: 'Recycling',
      colorHex: '#4CAF50',
      type: 'recycling',
      imageUrl: 'assets/trashbins/redtrashbin.svg',
    ),
    WasteBin(
      id: '3',
      name: 'Organic',
      colorHex: '#8BC34A',
      type: 'organic',
      imageUrl: 'assets/trashbins/greentrashbin.svg',
    ),
    WasteBin(
      id: '4',
      name: 'Hazardous',
      colorHex: '#FFC107',
      type: 'hazardous',
      imageUrl: 'assets/trashbins/yellowtrashbin.svg',
    ),
  ];
});
