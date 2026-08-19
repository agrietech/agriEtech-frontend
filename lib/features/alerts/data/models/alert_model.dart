/// Alert data model matching backend /api/v1/alerts response
library alert_model;

class AlertModel {
  final String id;
  final String woredaId;
  final String hazardType; // DROUGHT, FLOOD, LOCUST, DISEASE
  final String severity;   // LOW, MEDIUM, HIGH, CRITICAL
  final String titleEn;
  final String titleAm;
  final String messageEn;
  final String messageAm;
  final bool isActive;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.woredaId,
    required this.hazardType,
    required this.severity,
    required this.titleEn,
    required this.titleAm,
    required this.messageEn,
    required this.messageAm,
    required this.isActive,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String? ?? '',
      woredaId: json['woredaId'] as String? ?? '',
      hazardType: json['hazardType'] as String? ?? 'DROUGHT',
      severity: json['severity'] as String? ?? 'LOW',
      titleEn: (json['titleEn'] ?? json['title'] ?? json['headline'] ?? '') as String,
      titleAm: (json['titleAm'] ?? json['titleEn'] ?? '') as String,
      messageEn: (json['messageEn'] ?? json['message'] ?? '') as String,
      messageAm: (json['messageAm'] ?? json['messageEn'] ?? '') as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'woredaId': woredaId, 'hazardType': hazardType,
    'severity': severity, 'titleEn': titleEn, 'titleAm': titleAm,
    'messageEn': messageEn, 'messageAm': messageAm,
    'isActive': isActive, 'createdAt': createdAt.toIso8601String(),
  };

  String localizedTitle(String lang) => lang == 'am' ? titleAm : titleEn;
  String localizedMessage(String lang) => lang == 'am' ? messageAm : messageEn;
}
