import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for storing and retrieving user authentication data
class TokenStorageService {
  static TokenStorageService? _instance;
  SharedPreferences? _prefs;

  // Storage keys
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhotoKey = 'user_photo';
  static const String _isAuthenticatedKey = 'is_authenticated';

  TokenStorageService._internal();

  factory TokenStorageService() {
    _instance ??= TokenStorageService._internal();
    return _instance!;
  }

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Store user authentication data
  Future<void> storeUserData({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    await initialize();

    await Future.wait([
      _prefs!.setString(_userIdKey, userId),
      _prefs!.setString(_userEmailKey, email),
      _prefs!.setString(_userNameKey, displayName ?? ''),
      _prefs!.setString(_userPhotoKey, photoUrl ?? ''),
      _prefs!.setBool(_isAuthenticatedKey, true),
    ]);

    debugPrint('TokenStorage: User data stored for ID: $userId');
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    await initialize();
    final userId = _prefs!.getString(_userIdKey);
    debugPrint('TokenStorage: Retrieved user ID: $userId');
    return userId;
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    await initialize();
    return _prefs!.getString(_userEmailKey);
  }

  /// Get stored user name
  Future<String?> getUserName() async {
    await initialize();
    return _prefs!.getString(_userNameKey);
  }

  /// Get stored user photo URL
  Future<String?> getUserPhotoUrl() async {
    await initialize();
    return _prefs!.getString(_userPhotoKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    await initialize();
    return _prefs!.getBool(_isAuthenticatedKey) ?? false;
  }

  /// Clear all stored user data (for logout)
  Future<void> clearUserData() async {
    await initialize();

    await Future.wait([
      _prefs!.remove(_userIdKey),
      _prefs!.remove(_userEmailKey),
      _prefs!.remove(_userNameKey),
      _prefs!.remove(_userPhotoKey),
      _prefs!.setBool(_isAuthenticatedKey, false),
    ]);

    debugPrint('TokenStorage: User data cleared');
  }

  /// Get all stored user data as a map
  Future<Map<String, String?>> getAllUserData() async {
    await initialize();

    return {
      'userId': await getUserId(),
      'email': await getUserEmail(),
      'displayName': await getUserName(),
      'photoUrl': await getUserPhotoUrl(),
    };
  }

  /// Check if storage has valid user data
  Future<bool> hasValidUserData() async {
    final userId = await getUserId();
    final email = await getUserEmail();
    final isAuth = await isAuthenticated();

    return userId != null &&
        email != null &&
        userId.isNotEmpty &&
        email.isNotEmpty &&
        isAuth;
  }
}
