///
/// @file socket_client.dart
/// @description Socket.IO client managing real-time websocket connections to AgriEtech backend.
/// @author Real-time Specialist
///
/// T5.2 (P0 Critical): powers live alert delivery + composite risk push updates.
/// Event names below must match backend/src/delivery/websocket/riskAssessmentChannel.js:
///   - 'alert:new'      -> woreda-scoped new advisory
///   - 'risk:updated'   -> woreda-scoped composite risk change
///   - 'emergency:alert'-> broadcast to every connected client, no woreda filter
///
library socket_client;

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/env.dart';

class SocketClient {
  io.Socket? _socket;
  final _alertController = StreamController<Map<String, dynamic>>.broadcast();
  final _riskUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Fires for every 'alert:new' and 'emergency:alert' event.
  Stream<Map<String, dynamic>> get alertStream => _alertController.stream;

  /// Fires for every 'risk:updated' event.
  Stream<Map<String, dynamic>> get riskUpdateStream =>
      _riskUpdateController.stream;

  /// Fires true on connect, false on disconnect — drive a small "live" indicator with it.
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null) return;

    _socket = io.io(
      AppEnv.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.maxFinite.toInt())
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );

    _socket!
      ..onConnect((_) => _connectionController.add(true))
      ..onDisconnect((_) => _connectionController.add(false))
      ..onConnectError((_) => _connectionController.add(false))
      ..onReconnect((_) => _connectionController.add(true))
      ..on('alert:new', (data) => _emitAlert(data))
      ..on('emergency:alert', (data) => _emitAlert(data))
      ..on('risk:updated', (data) => _emitRiskUpdate(data));
  }

  void _emitAlert(dynamic data) {
    if (data is Map) {
      _alertController.add(Map<String, dynamic>.from(data));
    }
  }

  void _emitRiskUpdate(dynamic data) {
    if (data is Map) {
      _riskUpdateController.add(Map<String, dynamic>.from(data));
    }
  }

  /// Join a woreda-scoped room so this device only receives alerts and risk
  /// updates relevant to the farmer's registered location.
  void subscribeWoreda(String woredaId) {
    _socket?.emit('subscribe:woreda', woredaId);
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _alertController.close();
    _riskUpdateController.close();
    _connectionController.close();
  }
}
