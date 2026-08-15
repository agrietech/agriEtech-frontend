///
/// @file api_response_model.dart
/// @description Generic API response envelope (success, message, data, errors).
/// @author Frontend Core
///
library api_response_model;

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<dynamic>? errors;

  ApiResponse({required this.success, this.message, this.data, this.errors});
}
