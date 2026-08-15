///
/// @file socket_client.dart
/// @description Socket.IO client managing real-time websocket connections to AgriEtech backend.
/// @author Real-time Specialist
///
library socket_client;

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/env.dart';

class SocketClient {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(AppEnv.socketBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
  }

  void subscribeWoreda(String woredaId) {
    socket.emit('subscribe:woreda', woredaId);
  }
}
