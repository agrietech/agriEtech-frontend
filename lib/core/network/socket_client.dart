
// ignore_for_file: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

/// Socket.IO client for real-time communication aligned with backend WebSocket server
class SocketClient {
  IO.Socket? _socket;
  final SecureStorageService _storage;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final List<String> _subscribedWoredas = [];
  final List<String> _subscribedChannels = [];
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  SocketClient(this._storage);

  /// Initialize and connect to socket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;
    
    try {
      final token = await _storage.getAccessToken();
      
      _socket = IO.io(
        AppEnv.socketBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(AppEnv.socketReconnectAttempts)
            .setReconnectionDelay(AppEnv.socketReconnectDelay)
            .setReconnectionDelayMax(10000)
            .setRandomizationFactor(0.5)
            .setAuth({'token': token})
            .build(),
      );

      _setupEventHandlers();
      _socket?.connect();
      
      AppLogger.info('Socket connecting to ${AppEnv.socketBaseUrl}');
    } catch (e, stackTrace) {
      AppLogger.error('Socket connection failed', e, stackTrace);
      _isConnecting = false;
    }
  }

  /// Setup socket event handlers
  void _setupEventHandlers() {
    final socket = _socket;
    if (socket == null) return;

    socket.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      AppLogger.info('Socket connected');
      
      // Re-subscribe to woreda rooms
      for (final woredaId in _subscribedWoredas) {
        socket.emit('subscribe:woreda', woredaId);
        socket.emit('join', 'woreda:$woredaId');
      }

      // Re-subscribe to other channels
      for (final channel in _subscribedChannels) {
        socket.emit('join', channel);
      }

      // Re-attach registered handlers
      _eventHandlers.forEach((event, handlers) {
        for (final handler in handlers) {
          socket.on(event, handler);
        }
      });
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      AppLogger.warning('Socket disconnected');
    });

    socket.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;
      AppLogger.error('Socket connection error', error);
    });

    socket.onReconnect((attemptNumber) {
      AppLogger.info('Socket reconnected after $attemptNumber attempts');
    });

    socket.onReconnectError((error) {
      AppLogger.error('Socket reconnection error', error);
    });

    socket.onReconnectFailed((_) {
      _isConnected = false;
      _isConnecting = false;
      AppLogger.error('Socket reconnection failed');
    });
  }

  /// Subscribe to woreda-specific alerts and updates
  void subscribeToWoreda(String woredaId) {
    if (!_subscribedWoredas.contains(woredaId)) {
      _subscribedWoredas.add(woredaId);
    }
    final channel = 'woreda:$woredaId';
    if (!_subscribedChannels.contains(channel)) {
      _subscribedChannels.add(channel);
    }
    if (_isConnected && _socket != null) {
      _socket!.emit('subscribe:woreda', woredaId);
      _socket!.emit('join', channel);
      AppLogger.info('Subscribed to woreda: $woredaId');
    }
  }

  /// Unsubscribe from woreda updates
  void unsubscribeFromWoreda(String woredaId) {
    _subscribedWoredas.remove(woredaId);
    final channel = 'woreda:$woredaId';
    _subscribedChannels.remove(channel);
    if (_isConnected && _socket != null) {
      _socket!.emit('leave', channel);
      AppLogger.info('Unsubscribed from $channel');
    }
  }

  /// Listen for emergency and standard alerts
  void onAlert(Function(dynamic) callback) {
    on('emergency:alert', callback);
    on('alert', callback);
    on('new_alert', callback);
    on('alert:new', callback);
    on('alert:broadcast', callback);
    on('notification:new', callback);
  }

  /// Listen for risk assessment updates
  void onRiskUpdate(Function(dynamic) callback) {
    on('risk:update', callback);
    on('risk_update', callback);
  }

  /// Listen for weather updates
  void onWeatherUpdate(Function(dynamic) callback) {
    on('weather:update', callback);
    on('weather_update', callback);
  }

  /// Listen for sensor telemetry
  void onSensorData(Function(dynamic) callback) {
    on('sensor:reading', callback);
    on('sensor_data', callback);
  }

  /// Send acknowledgment for received alert
  void acknowledgeAlert(String alertId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('acknowledge_alert', {'alertId': alertId});
    }
  }

  /// Request real-time updates for specific farm
  void requestFarmUpdates(String farmId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('subscribe_farm', {'farmId': farmId});
    }
  }

  /// Stop farm updates
  void stopFarmUpdates(String farmId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('unsubscribe_farm', {'farmId': farmId});
    }
  }

  /// Listen for a generic event by name
  void on(String event, Function(dynamic) callback) {
    _eventHandlers.putIfAbsent(event, () => []).add(callback);
    if (_isConnected && _socket != null) {
      _socket!.on(event, callback);
    }
  }

  /// Remove a specific event listener by name
  void off(String event) {
    if (_isConnected && _socket != null) {
      _socket!.off(event);
    }
    _eventHandlers.remove(event);
  }

  /// Remove event listeners (alias for off)
  void removeEventListener(String event) {
    off(event);
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      try {
        if (_socket!.connected) {
          _socket!.disconnect();
        }
      } catch (_) {}
    }
    _isConnected = false;
    _isConnecting = false;
    _subscribedWoredas.clear();
    _subscribedChannels.clear();
    _eventHandlers.clear();
    AppLogger.info('Socket disconnected');
  }

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Get connecting status  
  bool get isConnecting => _isConnecting;

  /// Manually reconnect
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(Duration(milliseconds: AppEnv.socketReconnectDelay));
    await connect();
  }
}

/// Provider for SocketClient with auto-connect & lifecycle disposal
final socketClientProvider = Provider<SocketClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final client = SocketClient(storage);
  client.connect();
  ref.onDispose(() {
    client.disconnect();
  });
  return client;
});

/// Provider for socket connection status
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socketClient = ref.watch(socketClientProvider);
  
  // Return a stream that emits connection status changes
  return Stream.periodic(const Duration(seconds: 1), (_) => socketClient.isConnected)
      .distinct();
});
