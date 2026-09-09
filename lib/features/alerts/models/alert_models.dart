/// Alert and emergency warning models (pure Dart without Freezed)
library alert_models;

/// Alert model representing smart alert notifications
class AlertModel {
  final String id;
  final String woredaId;
  final String? userId;
  final String hazardType;
  final String severity;
  final String title;
  final String message;
  final String? titleEn;
  final String? titleAm;
  final String? titleOm;
  final String? messageEn;
  final String? messageAm;
  final String? messageOm;
  final String status;
  final List<String> targetPhones;
  final double? affectedAreaKm2;
  final List<AlertAdvisory> advisories;
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
    this.titleEn,
    this.titleAm,
    this.titleOm,
    this.messageEn,
    this.messageAm,
    this.messageOm,
    this.status = 'SENT',
    this.targetPhones = const [],
    this.affectedAreaKm2,
    this.advisories = const [],
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

  /// Localized title accessor based on language code ('en', 'am', 'om')
  String getTitle([String? langCode]) {
    switch (langCode?.toLowerCase()) {
      case 'am':
        if (titleAm != null && titleAm!.trim().isNotEmpty) return titleAm!;
        break;
      case 'om':
        if (titleOm != null && titleOm!.trim().isNotEmpty) return titleOm!;
        break;
      case 'en':
        if (titleEn != null && titleEn!.trim().isNotEmpty) return titleEn!;
        break;
    }
    return title.isNotEmpty ? title : (titleEn ?? titleAm ?? 'Smart Alert');
  }

  /// Localized message accessor based on language code ('en', 'am', 'om')
  String getMessage([String? langCode]) {
    switch (langCode?.toLowerCase()) {
      case 'am':
        if (messageAm != null && messageAm!.trim().isNotEmpty) return messageAm!;
        break;
      case 'om':
        if (messageOm != null && messageOm!.trim().isNotEmpty) return messageOm!;
        break;
      case 'en':
        if (messageEn != null && messageEn!.trim().isNotEmpty) return messageEn!;
        break;
    }
    return message.isNotEmpty ? message : (messageEn ?? messageAm ?? '');
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final titleEn = json['titleEn']?.toString();
    final titleAm = json['titleAm']?.toString();
    final titleOm = json['titleOm']?.toString();
    final messageEn = json['messageEn']?.toString();
    final messageAm = json['messageAm']?.toString();
    final messageOm = json['messageOm']?.toString();

    final title = (json['title'] ?? titleEn ?? json['headline'] ?? titleAm ?? 'Smart Alert').toString();
    final message = (json['message'] ?? messageEn ?? messageAm ?? json['headline'] ?? '').toString();

    final actionItemsList = json['actionItems'] is List
        ? (json['actionItems'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final targetPhonesList = json['targetPhones'] is List
        ? (json['targetPhones'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final advisoriesList = json['advisories'] is List
        ? (json['advisories'] as List)
            .whereType<Map>()
            .map((a) => AlertAdvisory.fromJson(Map<String, dynamic>.from(a)))
            .toList()
        : <AlertAdvisory>[];

    final logsList = json['deliveryLogs'] is List
        ? (json['deliveryLogs'] as List)
            .map((l) => AlertDeliveryLog.fromJson(l as Map<String, dynamic>))
            .toList()
        : <AlertDeliveryLog>[];

    final affectedArea = json['affectedAreaKm2'] != null
        ? double.tryParse(json['affectedAreaKm2'].toString())
        : null;

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
      titleEn: titleEn,
      titleAm: titleAm,
      titleOm: titleOm,
      messageEn: messageEn,
      messageAm: messageAm,
      messageOm: messageOm,
      status: (json['status'] ?? 'SENT').toString(),
      targetPhones: targetPhonesList,
      affectedAreaKm2: affectedArea,
      advisories: advisoriesList,
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
    if (titleEn != null) 'titleEn': titleEn,
    if (titleAm != null) 'titleAm': titleAm,
    if (titleOm != null) 'titleOm': titleOm,
    if (messageEn != null) 'messageEn': messageEn,
    if (messageAm != null) 'messageAm': messageAm,
    if (messageOm != null) 'messageOm': messageOm,
    'status': status,
    'targetPhones': targetPhones,
    if (affectedAreaKm2 != null) 'affectedAreaKm2': affectedAreaKm2,
    'advisories': advisories.map((a) => a.toJson()).toList(),
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
    String? titleEn,
    String? titleAm,
    String? titleOm,
    String? messageEn,
    String? messageAm,
    String? messageOm,
    String? status,
    List<String>? targetPhones,
    double? affectedAreaKm2,
    List<AlertAdvisory>? advisories,
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
      titleEn: titleEn ?? this.titleEn,
      titleAm: titleAm ?? this.titleAm,
      titleOm: titleOm ?? this.titleOm,
      messageEn: messageEn ?? this.messageEn,
      messageAm: messageAm ?? this.messageAm,
      messageOm: messageOm ?? this.messageOm,
      status: status ?? this.status,
      targetPhones: targetPhones ?? this.targetPhones,
      affectedAreaKm2: affectedAreaKm2 ?? this.affectedAreaKm2,
      advisories: advisories ?? this.advisories,
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

/// Advisory linked directly to an alert
class AlertAdvisory {
  final String id;
  final String? title;
  final String? description;
  final String? recommendation;
  final String? language;
  final String? hazardType;
  final String? cropType;

  const AlertAdvisory({
    required this.id,
    this.title,
    this.description,
    this.recommendation,
    this.language,
    this.hazardType,
    this.cropType,
  });

  factory AlertAdvisory.fromJson(Map<String, dynamic> json) {
    return AlertAdvisory(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? json['titleEn']?.toString(),
      description: json['description']?.toString() ?? json['message']?.toString(),
      recommendation: json['recommendation']?.toString() ?? json['action']?.toString(),
      language: json['language']?.toString(),
      hazardType: json['hazardType']?.toString(),
      cropType: json['cropType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (recommendation != null) 'recommendation': recommendation,
    if (language != null) 'language': language,
    if (hazardType != null) 'hazardType': hazardType,
    if (cropType != null) 'cropType': cropType,
  };
}

/// Basic woreda information for alerts
class WoredaBasicInfo {
  final String id;
  final String name;
  final String? region;
  final String? zone;

  const WoredaBasicInfo({
    required this.id,
    required this.name,
    this.region,
    this.zone,
  });

  factory WoredaBasicInfo.fromJson(Map<String, dynamic> json) {
    return WoredaBasicInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      region: json['region']?.toString() ?? json['regionEn']?.toString(),
      zone: json['zone']?.toString() ?? json['zoneEn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (region != null) 'region': region,
    if (zone != null) 'zone': zone,
  };
}

/// Ground-truth feedback request
class AlertFeedbackRequest {
  final bool accurate;
  final String? notes;

  const AlertFeedbackRequest({
    required this.accurate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'accurate': accurate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

/// Ground-truth feedback response
class AlertFeedbackResponse {
  final String alertId;
  final String userId;
  final bool accurate;
  final String notes;
  final String submittedAt;

  const AlertFeedbackResponse({
    required this.alertId,
    required this.userId,
    required this.accurate,
    required this.notes,
    required this.submittedAt,
  });

  factory AlertFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return AlertFeedbackResponse(
      alertId: (json['alertId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      accurate: json['accurate'] is bool ? json['accurate'] as bool : true,
      notes: (json['notes'] ?? '').toString(),
      submittedAt: (json['submittedAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'alertId': alertId,
    'userId': userId,
    'accurate': accurate,
    'notes': notes,
    'submittedAt': submittedAt,
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
