///
/// @file dio_client.dart
/// @description Configured Dio HTTP client with interceptors, timeouts, and logging.
/// @author Networking Specialist
///
library dio_client;

import 'package:dio/dio.dart';
import '../config/env.dart';
import 'api_interceptors.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(ApiInterceptors());
  }
}
