/// Alert and emergency warning models (pure Dart without Freezed)
library alert_models;

/// Alert model representing early warning notifications
class AlertModel {
  final String id;
  final String woredaId;
  final String? userId;
  final String hazardType;
  final String severity;
  final String title;
  final String message;
  final List<String> actionItems;
  final int priority;
  final String? validUntil;
  final bool isActive;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? sentAt;
  final List<AlertDeliveryLog> deliveryLogs;
  final String createdAt;
  final String updatedAt;
  final WoredaBasicInfo? woreda;

  const AlertModel({
    required this.id,
    this.woredaId = '',
    this.userId,
    required this.hazardType,
    required this.severity,
    required this.title,
    required this.message,
    this.actionItems = const [],
    this.priority = 1,
    this.validUntil,
    this.isActive = true,
    this.isRead = false,
    this.readAt,
    this.sentAt,
    this.deliveryLogs = const [],
    required this.createdAt,
    required this.updatedAt,
    this.woreda,
  });

  DateTime get sentDate => sentAt ?? (DateTime.tryParse(createdAt) ?? DateTime.now());

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['titleEn'] ?? json['headline'] ?? json['titleAm'] ?? 'Early Warning Alert').toString();
    final message = (json['message'] ?? json['messageEn'] ?? json['messageAm'] ?? json['headline'] ?? '').toString();

    final actionItemsList = json['actionItems'] is List
        ? (json['actionItems'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final logsList = json['deliveryLogs'] is List
        ? (json['deliveryLogs'] as List)
            .map((l) => AlertDeliveryLog.fromJson(l as Map<String, dynamic>))
            .toList()
        : <AlertDeliveryLog>[];

    final createdStr = (json['createdAt'] ?? json['sentAt'] ?? DateTime.now().toIso8601String()).toString();
    final updatedStr = (json['updatedAt'] ?? createdStr).toString();
    final sentDate = json['sentAt'] != null
        ? (DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.tryParse(createdStr) ?? DateTime.now())
        : (DateTime.tryParse(createdStr) ?? DateTime.now());

    return AlertModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      woredaId: (json['woredaId'] ?? json['woreda']?['id'] ?? '').toString(),
      userId: json['userId'] as String?,
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      severity: (json['severity'] ?? 'MODERATE').toString(),
      title: title,
      message: message,
      actionItems: actionItemsList,
      priority: (json['priority'] ?? 1) as int,
      validUntil: json['validUntil'] as String?,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      sentAt: sentDate,
      deliveryLogs: logsList,
      createdAt: createdStr,
      updatedAt: updatedStr,
      woreda: json['woreda'] is Map<String, dynamic>
          ? WoredaBasicInfo.fromJson(json['woreda'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'woredaId': woredaId,
    if (userId != null) 'userId': userId,
    'hazardType': hazardType,
    'severity': severity,
    'title': title,
    'message': message,
    'actionItems': actionItems,
    'priority': priority,
    if (validUntil != null) 'validUntil': validUntil,
    'isActive': isActive,
    'isRead': isRead,
    if (readAt != null) 'readAt': readAt!.toIso8601String(),
    if (sentAt != null) 'sentAt': sentAt!.toIso8601String(),
    'deliveryLogs': deliveryLogs.map((l) => l.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (woreda != null) 'woreda': woreda!.toJson(),
  };

  AlertModel copyWith({
    String? id,
    String? woredaId,
    String? userId,
    String? hazardType,
    String? severity,
    String? title,
    String? message,
    List<String>? actionItems,
    int? priority,
    String? validUntil,
    bool? isActive,
    bool? isRead,
    DateTime? readAt,
    DateTime? sentAt,
    List<AlertDeliveryLog>? deliveryLogs,
    String? createdAt,
    String? updatedAt,
    WoredaBasicInfo? woreda,
  }) {
    return AlertModel(
      id: id ?? this.id,
      woredaId: woredaId ?? this.woredaId,
      userId: userId ?? this.userId,
      hazardType: hazardType ?? this.hazardType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      actionItems: actionItems ?? this.actionItems,
      priority: priority ?? this.priority,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
      deliveryLogs: deliveryLogs ?? this.deliveryLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      woreda: woreda ?? this.woreda,
    );
  }
}

/// Basic woreda information for alerts
class WoredaBasicInfo {
  final String id;
  final String name;

  const WoredaBasicInfo({
    required this.id,
    required this.name,
  });

  factory WoredaBasicInfo.fromJson(Map<String, dynamic> json) {
    return WoredaBasicInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// Alert delivery log tracking
class AlertDeliveryLog {
  final String id;
  final String alertId;
  final String userId;
  final String channel;
  final String status;
  final String? errorMessage;
  final Map<String, dynamic>? responsePayload;
  final int retryCount;
  final String? sentAt;
  final String? deliveredAt;
  final String createdAt;
  final String updatedAt;

  const AlertDeliveryLog({
    required this.id,
    required this.alertId,
    required this.userId,
    required this.channel,
    required this.status,
    this.errorMessage,
    this.responsePayload,
    this.retryCount = 0,
    this.sentAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertDeliveryLog.fromJson(Map<String, dynamic> json) {
    return AlertDeliveryLog(
      id: (json['id'] ?? '').toString(),
      alertId: (json['alertId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      channel: (json['channel'] ?? 'SMS').toString(),
      status: (json['status'] ?? 'SENT').toString(),
      errorMessage: json['errorMessage'] as String?,
      responsePayload: json['responsePayload'] as Map<String, dynamic>?,
      retryCount: (json['retryCount'] ?? 0) as int,
      sentAt: json['sentAt'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'alertId': alertId,
    'userId': userId,
    'channel': channel,
    'status': status,
    if (errorMessage != null) 'errorMessage': errorMessage,
    if (responsePayload != null) 'responsePayload': responsePayload,
    'retryCount': retryCount,
    if (sentAt != null) 'sentAt': sentAt,
    if (deliveredAt != null) 'deliveredAt': deliveredAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// Request model for creating alerts
class CreateAlertRequest {
  final String? woredaId;
  final String? woredaName;
  final String hazardType;
  final String severity;
  final String? titleEn;
  final String? titleAm;
  final String? messageEn;
  final String? messageAm;
  final String? headline;
  final String? message;
  final List<String> targetPhones;
  final List<String> actionItems;
  final int priority;
  final String language;

  const CreateAlertRequest({
    this.woredaId,
    this.woredaName,
    this.hazardType = 'DROUGHT',
    this.severity = 'HIGH',
    this.titleEn,
    this.titleAm,
    this.messageEn,
    this.messageAm,
    this.headline,
    this.message,
    this.targetPhones = const [],
    this.actionItems = const [],
    this.priority = 1,
    this.language = 'en',
  });

  factory CreateAlertRequest.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return const [];
    }

    return CreateAlertRequest(
      woredaId: json['woredaId'] as String?,
      woredaName: json['woredaName'] as String?,
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      severity: (json['severity'] ?? 'HIGH').toString(),
      titleEn: json['titleEn'] as String?,
      titleAm: json['titleAm'] as String?,
      messageEn: json['messageEn'] as String?,
      messageAm: json['messageAm'] as String?,
      headline: json['headline'] as String?,
      message: json['message'] as String?,
      targetPhones: parseList(json['targetPhones']),
      actionItems: parseList(json['actionItems']),
      priority: (json['priority'] ?? 1) as int,
      language: (json['language'] ?? 'en').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (woredaId != null) 'woredaId': woredaId,
    if (woredaName != null) 'woredaName': woredaName,
    'hazardType': hazardType,
    'severity': severity,
    if (titleEn != null) 'titleEn': titleEn,
    if (titleAm != null) 'titleAm': titleAm,
    if (messageEn != null) 'messageEn': messageEn,
    if (messageAm != null) 'messageAm': messageAm,
    if (headline != null) 'headline': headline,
    if (message != null) 'message': message,
    'targetPhones': targetPhones,
    'actionItems': actionItems,
    'priority': priority,
    'language': language,
  };
}

/// Alert statistics model
class AlertStatistics {
  final int total;
  final int critical;
  final int high;
  final int moderate;
  final int low;
  final int active;
  final int expired;
  final Map<String, int>? byHazardType;
  final Map<String, int>? byWoreda;

  const AlertStatistics({
    this.total = 0,
    this.critical = 0,
    this.high = 0,
    this.moderate = 0,
    this.low = 0,
    this.active = 0,
    this.expired = 0,
    this.byHazardType,
    this.byWoreda,
  });

  factory AlertStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return AlertStatistics(
      total: (json['total'] ?? 0) as int,
      critical: (json['critical'] ?? 0) as int,
      high: (json['high'] ?? 0) as int,
      moderate: (json['moderate'] ?? 0) as int,
      low: (json['low'] ?? 0) as int,
      active: (json['active'] ?? 0) as int,
      expired: (json['expired'] ?? 0) as int,
      byHazardType: parseMap(json['byHazardType']),
      byWoreda: parseMap(json['byWoreda']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'critical': critical,
    'high': high,
    'moderate': moderate,
    'low': low,
    'active': active,
    'expired': expired,
    if (byHazardType != null) 'byHazardType': byHazardType,
    if (byWoreda != null) 'byWoreda': byWoreda,
  };
}

/// Alert filter options
class AlertFilters {
  final String? woredaId;
  final String? severity;
  final String? hazardType;
  final bool? isActive;
  final int? limit;

  const AlertFilters({
    this.woredaId,
    this.severity,
    this.hazardType,
    this.isActive,
    this.limit,
  });

  factory AlertFilters.fromJson(Map<String, dynamic> json) {
    return AlertFilters(
      woredaId: json['woredaId'] as String?,
      severity: json['severity'] as String?,
      hazardType: json['hazardType'] as String?,
      isActive: json['isActive'] as bool?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (woredaId != null) 'woredaId': woredaId,
    if (severity != null) 'severity': severity,
    if (hazardType != null) 'hazardType': hazardType,
    if (isActive != null) 'isActive': isActive,
    if (limit != null) 'limit': limit,
  };

  AlertFilters copyWith({
    String? woredaId,
    String? severity,
    String? hazardType,
    bool? isActive,
    int? limit,
  }) {
    return AlertFilters(
      woredaId: woredaId ?? this.woredaId,
      severity: severity ?? this.severity,
      hazardType: hazardType ?? this.hazardType,
      isActive: isActive ?? this.isActive,
      limit: limit ?? this.limit,
    );
  }
}
