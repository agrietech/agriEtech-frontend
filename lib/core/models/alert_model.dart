import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    String? userId,
    String? woredaId,
    required String hazardType,
    required String severity,
    required String title,
    required String message,
    required DateTime sentAt,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
}
