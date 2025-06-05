import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/dio_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Model for waste detection results
class WasteDetectionResult {
  final String className;
  final double confidence;

  WasteDetectionResult({required this.className, required this.confidence});

  factory WasteDetectionResult.fromJson(Map<String, dynamic> json) {
    return WasteDetectionResult(
      className: json['class'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() =>
      'WasteDetectionResult(className: $className, confidence: $confidence)';
}

/// WebSocket service for real-time waste detection
class WasteDetectionWebSocketService {
  static WasteDetectionWebSocketService? _instance;

  WebSocketChannel? _channel;
  final _detectionController =
      StreamController<List<WasteDetectionResult>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  bool _isConnected = false;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  // Private constructor for singleton
  WasteDetectionWebSocketService._();

  /// Get singleton instance
  static WasteDetectionWebSocketService get instance {
    _instance ??= WasteDetectionWebSocketService._();
    return _instance!;
  }

  /// Stream of detection results
  Stream<List<WasteDetectionResult>> get detectionStream =>
      _detectionController.stream;

  /// Stream of connection status
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// WebSocket URL from DioClient
  String get _serverUrl => DioClient.wsUrl;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnected) {
      debugPrint('WasteDetectionWebSocketService: Already connected');
      return;
    }

    try {
      debugPrint('WasteDetectionWebSocketService: Connecting to $_serverUrl');

      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      _isConnected = true;
      _connectionController.add(true);

      // Start ping timer for connection health
      _startPingTimer();

      // Listen to WebSocket messages
      _channel!.stream.listen(
        _handleServerMessage,
        onError: _handleConnectionError,
        onDone: _handleConnectionClosed,
      );

      debugPrint('WasteDetectionWebSocketService: Connected successfully');
    } catch (e) {
      debugPrint('WasteDetectionWebSocketService: Failed to connect - $e');
      _handleConnectionError(e);
    }
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    debugPrint('WasteDetectionWebSocketService: Disconnecting...');

    _stopPingTimer();
    _stopReconnectTimer();

    await _channel?.sink.close();
    _channel = null;

    _isConnected = false;
    _connectionController.add(false);

    debugPrint('WasteDetectionWebSocketService: Disconnected');
  }

  /// Send image for waste detection
  Future<void> detectWaste(Uint8List imageBytes) async {
    if (!_isConnected || _channel == null) {
      debugPrint(
        'WasteDetectionWebSocketService: Not connected, cannot detect waste',
      );
      return;
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final message = json.encode({
        'type': 'detect',
        'image': base64Image,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('WasteDetectionWebSocketService: Error sending image - $e');
    }
  }

  /// Handle incoming WebSocket messages
  void _handleServerMessage(dynamic data) {
    try {
      final message = json.decode(data);
      final type = message['type'];

      switch (type) {
        case 'detection_result':
          _handleDetectionResult(message['data']);
          break;

        case 'error':
          debugPrint(
            'WasteDetectionWebSocketService: Server error - ${message['message']}',
          );
          _detectionController.add([]);
          break;

        case 'connected':
          debugPrint(
            'WasteDetectionWebSocketService: Server message - ${message['message']}',
          );
          break;

        case 'pong':
          // Connection is healthy
          break;

        default:
          debugPrint(
            'WasteDetectionWebSocketService: Unknown message type - $type',
          );
      }
    } catch (e) {
      debugPrint('WasteDetectionWebSocketService: Error parsing message - $e');
    }
  }

  /// Handle detection result from server
  void _handleDetectionResult(Map<String, dynamic> data) {
    if (data['success'] == true) {
      final detections =
          (data['detections'] as List)
              .map((d) => WasteDetectionResult.fromJson(d))
              .toList();
      _detectionController.add(detections);
    } else {
      debugPrint(
        'WasteDetectionWebSocketService: Detection failed - ${data['error']}',
      );
      _detectionController.add([]);
    }
  }

  /// Handle connection errors
  void _handleConnectionError(dynamic error) {
    debugPrint('WasteDetectionWebSocketService: Connection error - $error');
    _isConnected = false;
    _connectionController.add(false);
    _stopPingTimer();

    // Auto-reconnect after 5 seconds
    _scheduleReconnect();
  }

  /// Handle connection closed
  void _handleConnectionClosed() {
    debugPrint('WasteDetectionWebSocketService: Connection closed');
    _isConnected = false;
    _connectionController.add(false);
    _stopPingTimer();

    // Auto-reconnect after 3 seconds
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    _stopReconnectTimer();

    _reconnectTimer = Timer(Duration(seconds: 5), () {
      debugPrint('WasteDetectionWebSocketService: Attempting to reconnect...');
      connect();
    });
  }

  /// Start ping timer for connection health
  void _startPingTimer() {
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _sendPing();
    });
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Send ping to server
  void _sendPing() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(
          json.encode({
            'type': 'ping',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      } catch (e) {
        debugPrint('WasteDetectionWebSocketService: Error sending ping - $e');
      }
    }
  }

  /// Dispose of the service (call when app is closing)
  void dispose() {
    debugPrint('WasteDetectionWebSocketService: Disposing...');

    _stopPingTimer();
    _stopReconnectTimer();

    _channel?.sink.close();
    _detectionController.close();
    _connectionController.close();

    _instance = null;
  }
}
