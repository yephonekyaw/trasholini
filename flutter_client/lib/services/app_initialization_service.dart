import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/apis/dio_client.dart';
import 'package:flutter_client/services/token_storage_service.dart';

/// Service to initialize all app dependencies in the correct order
class AppInitializationService {
  static bool _isInitialized = false;

  /// Initialize all app services
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AppInit: Already initialized, skipping...');
      return;
    }

    try {
      debugPrint('AppInit: Starting app initialization...');

      // 1. Initialize token storage first
      debugPrint('AppInit: Initializing token storage...');
      await TokenStorageService().initialize();

      // 2. Initialize Dio client (which depends on token storage)
      debugPrint('AppInit: Initializing Dio client...');
      await DioClient().initialize();

      // 3. Add any other service initializations here
      // await OtherService().initialize();

      _isInitialized = true;
      debugPrint('AppInit: All services initialized successfully!');
    } catch (e, st) {
      debugPrint('AppInit: Initialization failed: $e');
      debugPrint('AppInit: Stack trace: $st');
      rethrow;
    }
  }

  /// Check if app is properly initialized
  static bool get isInitialized => _isInitialized;

  /// Reset initialization (useful for testing)
  static void reset() {
    _isInitialized = false;
    debugPrint('AppInit: Reset initialization state');
  }
}
