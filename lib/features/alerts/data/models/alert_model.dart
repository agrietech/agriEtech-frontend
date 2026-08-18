///
/// @file alert_model.dart
/// @feature alerts
/// @description Data model, JSON contracts, and Hive TypeAdapter for alerts.
/// @author Feature Developer (alerts)
///
library alert_model;

import 'package:hive/hive.dart';

/// Severity levels used for badge coloring in the inbox (T5.3).
enum AlertSeverity { critical, high, moderate, low }

AlertSeverity severityFromString(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'CRITICAL':
      return AlertSeverity.critical;
    case 'HIGH':
      return AlertSeverity.high;
    case 'MODERATE':
    case 'WARNING':
      return AlertSeverity.moderate;
    default:
      return AlertSeverity.low;
  }
}

class AlertModel {
  final String id;
  final String woredaId;
  final String? woredaName;
  final String hazardType; // DROUGHT | FLOOD | LOCUST | VEGETATION
  final AlertSeverity severity;
  final String headline;
  final String? titleAm;
  final String? message;
  final String? messageAm;
  final String status;
  final DateTime createdAt;
  final String? audioAdvisoryUrl;
  final String? mitigationGuideUrl;
  bool isRead;

  AlertModel({
    required this.id,
    required this.woredaId,
    this.woredaName,
    required this.hazardType,
    required this.severity,
    required this.headline,
    this.titleAm,
    this.message,
    this.messageAm,
    this.status = 'ACTIVE',
    DateTime? createdAt,
    this.audioAdvisoryUrl,
    this.mitigationGuideUrl,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? '',
      woredaId: json['woredaId']?.toString() ?? '',
      woredaName: json['woredaName']?.toString(),
      hazardType: json['hazardType']?.toString() ?? 'DROUGHT',
      severity: severityFromString(json['severity']?.toString()),
      headline: json['headline']?.toString() ??
          json['titleAm']?.toString() ??
          'Alert',
      titleAm: json['titleAm']?.toString(),
      message: json['message']?.toString(),
      messageAm: json['messageAm']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      audioAdvisoryUrl: json['audioAdvisoryUrl']?.toString(),
      mitigationGuideUrl: json['mitigationGuideUrl']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'woredaId': woredaId,
        'woredaName': woredaName,
        'hazardType': hazardType,
        'severity': severity.name.toUpperCase(),
        'headline': headline,
        'titleAm': titleAm,
        'message': message,
        'messageAm': messageAm,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'audioAdvisoryUrl': audioAdvisoryUrl,
        'mitigationGuideUrl': mitigationGuideUrl,
        'isRead': isRead,
      };

  AlertModel copyWith({bool? isRead}) => AlertModel(
        id: id,
        woredaId: woredaId,
        woredaName: woredaName,
        hazardType: hazardType,
        severity: severity,
        headline: headline,
        titleAm: titleAm,
        message: message,
        messageAm: messageAm,
        status: status,
        createdAt: createdAt,
        audioAdvisoryUrl: audioAdvisoryUrl,
        mitigationGuideUrl: mitigationGuideUrl,
        isRead: isRead ?? this.isRead,
      );
}

/// Manual Hive TypeAdapter (no build_runner in this environment).
/// typeId 1 is reserved for AlertModel across the whole app — do not reuse.
class AlertModelAdapter extends TypeAdapter<AlertModel> {
  @override
  final int typeId = 1;

  @override
  AlertModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return AlertModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, AlertModel obj) {
    writer.writeMap(obj.toJson());
  }
}
