// ignore_for_file: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

/// Socket.IO client for real-time communication
class SocketClient {
  late IO.Socket _socket;
  final SecureStorageService _storage;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final List<String> _subscribedChannels = [];
  final Map<String, Function(dynamic)> _eventHandlers = {};

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
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(AppEnv.socketReconnectAttempts)
            .setReconnectionDelay(AppEnv.socketReconnectDelay)
            .setAuth({'token': token})
            .build(),
      );

      _setupEventHandlers();
      _socket.connect();
      
      AppLogger.info('Socket connecting to ${AppEnv.socketBaseUrl}');
    } catch (e, stackTrace) {
      AppLogger.error('Socket connection failed', e, stackTrace);
      _isConnecting = false;
    }
  }

  /// Setup socket event handlers
  void _setupEventHandlers() {
    _socket.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      AppLogger.info('Socket connected');
      
      // Re-subscribe to channels after reconnection
      for (final channel in _subscribedChannels) {
        _socket.emit('join', channel);
      }
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      AppLogger.warning('Socket disconnected');
    });

    _socket.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;
      AppLogger.error('Socket connection error', error);
    });

    _socket.onReconnect((attemptNumber) {
      AppLogger.info('Socket reconnected after $attemptNumber attempts');
    });

    _socket.onReconnectError((error) {
      AppLogger.error('Socket reconnection error', error);
    });

    _socket.onReconnectFailed((_) {
      _isConnected = false;
      _isConnecting = false;
      AppLogger.error('Socket reconnection failed');
    });
  }

  /// Subscribe to woreda-specific alerts and updates
  void subscribeToWoreda(String woredaId) {
    if (!_isConnected) {
      AppLogger.warning('Cannot subscribe - socket not connected');
      return;
    }

    final channel = 'woreda:$woredaId';
    if (!_subscribedChannels.contains(channel)) {
      _subscribedChannels.add(channel);
      _socket.emit('join', channel);
      AppLogger.info('Subscribed to $channel');
    }
  }

  /// Unsubscribe from woreda updates
  void unsubscribeFromWoreda(String woredaId) {
    if (!_isConnected) return;

    final channel = 'woreda:$woredaId';
    _subscribedChannels.remove(channel);
    _socket.emit('leave', channel);
    AppLogger.info('Unsubscribed from $channel');
  }

  /// Listen for alerts
  void onAlert(Function(dynamic) callback) {
    if (!_isConnected) {
      _eventHandlers['alert'] = callback;
      return;
    }
    
    _socket.on('alert', callback);
    _eventHandlers['alert'] = callback;
  }

  /// Listen for risk updates
  void onRiskUpdate(Function(dynamic) callback) {
    if (!_isConnected) {
      _eventHandlers['risk_update'] = callback;
      return;
    }
    
    _socket.on('risk_update', callback);
    _eventHandlers['risk_update'] = callback;
  }

  /// Listen for weather updates
  void onWeatherUpdate(Function(dynamic) callback) {
    if (!_isConnected) {
      _eventHandlers['weather_update'] = callback;
      return;
    }
    
    _socket.on('weather_update', callback);
    _eventHandlers['weather_update'] = callback;
  }

  /// Listen for sensor data
  void onSensorData(Function(dynamic) callback) {
    if (!_isConnected) {
      _eventHandlers['sensor_data'] = callback;
      return;
    }
    
    _socket.on('sensor_data', callback);
    _eventHandlers['sensor_data'] = callback;
  }

  /// Send acknowledgment for received alert
  void acknowledgeAlert(String alertId) {
    if (_isConnected) {
      _socket.emit('acknowledge_alert', {'alertId': alertId});
    }
  }

  /// Request real-time updates for specific farm
  void requestFarmUpdates(String farmId) {
    if (_isConnected) {
      _socket.emit('subscribe_farm', {'farmId': farmId});
    }
  }

  /// Stop farm updates
  void stopFarmUpdates(String farmId) {
    if (_isConnected) {
      _socket.emit('unsubscribe_farm', {'farmId': farmId});
    }
  }

  /// Listen for a generic event by name
  void on(String event, Function(dynamic) callback) {
    _eventHandlers[event] = callback;
    if (_isConnected) {
      _socket.on(event, callback);
    }
  }

  /// Remove a specific event listener by name
  void off(String event) {
    if (_isConnected) {
      _socket.off(event);
    }
    _eventHandlers.remove(event);
  }

  /// Remove event listeners (alias for off)
  void removeEventListener(String event) {
    off(event);
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    _isConnected = false;
    _isConnecting = false;
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

/// Provider for SocketClient
final socketClientProvider = Provider<SocketClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return SocketClient(storage);
});

/// Provider for socket connection status
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socketClient = ref.watch(socketClientProvider);
  
  // Return a stream that emits connection status changes
  return Stream.periodic(const Duration(seconds: 1), (_) => socketClient.isConnected)
      .distinct();
});
