///
/// @file socket_client.dart
/// @description Socket.IO client managing real-time websocket connections to AgriEtech backend.
/// @author Real-time Specialist
///
library socket_client;

import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/env.dart';

class SocketClient {
  late io.Socket socket;

  void connect() {
    socket = io.io(AppEnv.socketBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
  }

  void subscribeWoreda(String woredaId) {
    socket.emit('subscribe:woreda', woredaId);
  }
}
