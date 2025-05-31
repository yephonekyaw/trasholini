
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/main/users.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  // 🔥 FIREBASE INTEGRATION POINT 1: FETCH USER DATA
  Future<void> _loadUser() async {
    try {
      // TODO: Replace with Firebase Authentication to get current user ID
      // final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      // TODO: Fetch user data from Firestore
      // final userDoc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(currentUserId)
      //     .get();
      
      // TODO: Parse user data from Firebase document
      // if (userDoc.exists) {
      //   final userData = userDoc.data()!;
      //   state = User.fromJson(userData);
      // }

      // TEMPORARY: Static data (remove when backend is ready)
      state = const User(
        id: '1',
        name: 'Gay Zaw Oo',
        profileImageUrl: 'assets/Profile/elle fanning.jpg',
        wasteKg: 22,
        carbonKg: 22,
        points: 1000,
        rank: 1,
      );
    } catch (e) {
      // TODO: Handle Firebase errors
      print('Error loading user: $e');
    }
  }

  // 🔥 FIREBASE INTEGRATION POINT 2: UPDATE USER PROFILE
  Future<void> updateProfile({String? name, String? title}) async {
    if (state != null) {
      try {
        // TODO: Update user profile in Firestore
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(state!.id)
        //     .update({
        //   'name': name ?? state!.name,
        //   'title': title,
        //   'updatedAt': FieldValue.serverTimestamp(),
        // });

        // Update local state
        state = state!.copyWith(name: name, title: title);
      } catch (e) {
        // TODO: Handle Firebase errors
        print('Error updating profile: $e');
      }
    }
  }

  // 🔥 FIREBASE INTEGRATION POINT 3: ADD POINTS (FROM SCANNING WASTE)
  Future<void> addPoints(int points) async {
    if (state != null) {
      try {
        final newPoints = state!.points + points;
        
        // TODO: Update points in Firestore
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(state!.id)
        //     .update({
        //   'points': newPoints,
        //   'lastPointsUpdate': FieldValue.serverTimestamp(),
        // });

        // TODO: Add points transaction to history
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(state!.id)
        //     .collection('pointsHistory')
        //     .add({
        //   'points': points,
        //   'reason': 'waste_scan',
        //   'timestamp': FieldValue.serverTimestamp(),
        // });

        // Update local state
        state = state!.copyWith(points: newPoints);
      } catch (e) {
        // TODO: Handle Firebase errors
        print('Error adding points: $e');
      }
    }
  }

  // 🔥 FIREBASE INTEGRATION POINT 4: ADD WASTE (FROM SCANNING/DISPOSING)
  Future<void> addWaste(int kg) async {
    if (state != null) {
      try {
        final newWasteKg = state!.wasteKg + kg;
        
        // TODO: Update waste amount in Firestore
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(state!.id)
        //     .update({
        //   'wasteKg': newWasteKg,
        //   'lastWasteUpdate': FieldValue.serverTimestamp(),
        // });

        // TODO: Add waste disposal record
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(state!.id)
        //     .collection('wasteHistory')
        //     .add({
        //   'wasteKg': kg,
        //   'timestamp': FieldValue.serverTimestamp(),
        //   'location': 'current_location', // TODO: Add GPS coordinates
        // });

        // Update local state
        state = state!.copyWith(wasteKg: newWasteKg);
      } catch (e) {
        // TODO: Handle Firebase errors
        print('Error adding waste: $e');
      }
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});