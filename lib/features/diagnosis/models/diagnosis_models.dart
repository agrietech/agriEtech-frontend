/// Disease diagnosis models (pure Dart without Freezed)
library diagnosis_models;

/// Disease diagnosis model
class DiagnosisModel {
  final String id;
  final String farmId;
  final String imageUrl;
  final String? cropIdentified;
  final String? diseaseName;
  final double? confidenceScore;
  final String? treatment;
  final String? preventionTips;
  final Map<String, dynamic>? rawResponse;
  final String diagnosisStatus;
  final String createdAt;
  final FarmBasicInfo? farm;

  const DiagnosisModel({
    required this.id,
    required this.farmId,
    required this.imageUrl,
    this.cropIdentified,
    this.diseaseName,
    this.confidenceScore,
    this.treatment,
    this.preventionTips,
    this.rawResponse,
    this.diagnosisStatus = 'PENDING',
    required this.createdAt,
    this.farm,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: (json['id'] ?? '').toString(),
      farmId: (json['farmId'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image'] ?? '').toString(),
      cropIdentified: (json['cropIdentified'] ?? json['cropType'] ?? json['cropIdentifiedAm']) as String?,
      diseaseName: (json['diseaseName'] ?? json['diseaseNameAm']) as String?,
      confidenceScore: json['confidenceScore'] != null
          ? ((json['confidenceScore'] as num).toDouble())
          : (json['confidence'] != null ? ((json['confidence'] as num).toDouble()) : 0.9),
      treatment: (json['treatment'] ?? json['treatmentEn'] ?? json['treatmentAm'] ?? json['treatmentOm']) as String?,
      preventionTips: (json['preventionTips'] ?? json['preventionEn'] ?? json['preventionAm']) as String?,
      rawResponse: json['rawResponse'] as Map<String, dynamic>?,
      diagnosisStatus: (json['diagnosisStatus'] ?? json['status'] ?? 'SUCCESS').toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      farm: json['farm'] is Map<String, dynamic>
          ? FarmBasicInfo.fromJson(json['farm'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'imageUrl': imageUrl,
    if (cropIdentified != null) 'cropIdentified': cropIdentified,
    if (diseaseName != null) 'diseaseName': diseaseName,
    if (confidenceScore != null) 'confidenceScore': confidenceScore,
    if (treatment != null) 'treatment': treatment,
    if (preventionTips != null) 'preventionTips': preventionTips,
    if (rawResponse != null) 'rawResponse': rawResponse,
    'diagnosisStatus': diagnosisStatus,
    'createdAt': createdAt,
    if (farm != null) 'farm': farm!.toJson(),
  };

  DiagnosisModel copyWith({
    String? id,
    String? farmId,
    String? imageUrl,
    String? cropIdentified,
    String? diseaseName,
    double? confidenceScore,
    String? treatment,
    String? preventionTips,
    Map<String, dynamic>? rawResponse,
    String? diagnosisStatus,
    String? createdAt,
    FarmBasicInfo? farm,
  }) {
    return DiagnosisModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      imageUrl: imageUrl ?? this.imageUrl,
      cropIdentified: cropIdentified ?? this.cropIdentified,
      diseaseName: diseaseName ?? this.diseaseName,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      treatment: treatment ?? this.treatment,
      preventionTips: preventionTips ?? this.preventionTips,
      rawResponse: rawResponse ?? this.rawResponse,
      diagnosisStatus: diagnosisStatus ?? this.diagnosisStatus,
      createdAt: createdAt ?? this.createdAt,
      farm: farm ?? this.farm,
    );
  }
}

/// Basic farm information for diagnosis
class FarmBasicInfo {
  final String id;
  final String farmName;
  final String? primaryCrop;

  const FarmBasicInfo({
    required this.id,
    required this.farmName,
    this.primaryCrop,
  });

  factory FarmBasicInfo.fromJson(Map<String, dynamic> json) {
    return FarmBasicInfo(
      id: (json['id'] ?? '').toString(),
      farmName: (json['farmName'] ?? json['name'] ?? '').toString(),
      primaryCrop: json['primaryCrop'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmName': farmName,
    if (primaryCrop != null) 'primaryCrop': primaryCrop,
  };
}

/// Request model for creating diagnosis
class CreateDiagnosisRequest {
  final String farmId;
  final String imageBase64;
  final String? cropType;

  const CreateDiagnosisRequest({
    required this.farmId,
    required this.imageBase64,
    this.cropType,
  });

  factory CreateDiagnosisRequest.fromJson(Map<String, dynamic> json) {
    return CreateDiagnosisRequest(
      farmId: (json['farmId'] ?? '').toString(),
      imageBase64: (json['imageBase64'] ?? '').toString(),
      cropType: json['cropType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'farmId': farmId,
    'imageBase64': imageBase64,
    if (cropType != null) 'cropType': cropType,
  };
}

/// Diagnosis statistics
class DiagnosisStatistics {
  final int total;
  final int pending;
  final int success;
  final int failed;
  final Map<String, int>? byCrop;
  final Map<String, int>? byDisease;

  const DiagnosisStatistics({
    this.total = 0,
    this.pending = 0,
    this.success = 0,
    this.failed = 0,
    this.byCrop,
    this.byDisease,
  });

  factory DiagnosisStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return DiagnosisStatistics(
      total: (json['total'] ?? 0) as int,
      pending: (json['pending'] ?? 0) as int,
      success: (json['success'] ?? 0) as int,
      failed: (json['failed'] ?? 0) as int,
      byCrop: parseMap(json['byCrop']),
      byDisease: parseMap(json['byDisease']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'pending': pending,
    'success': success,
    'failed': failed,
    if (byCrop != null) 'byCrop': byCrop,
    if (byDisease != null) 'byDisease': byDisease,
  };
}

/// Diagnosis filter options
class DiagnosisFilters {
  final String? farmId;
  final String? status;
  final String? cropType;
  final int? limit;

  const DiagnosisFilters({
    this.farmId,
    this.status,
    this.cropType,
    this.limit,
  });

  factory DiagnosisFilters.fromJson(Map<String, dynamic> json) {
    return DiagnosisFilters(
      farmId: json['farmId'] as String?,
      status: json['status'] as String?,
      cropType: json['cropType'] as String?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (farmId != null) 'farmId': farmId,
    if (status != null) 'status': status,
    if (cropType != null) 'cropType': cropType,
    if (limit != null) 'limit': limit,
  };

  DiagnosisFilters copyWith({
    String? farmId,
    String? status,
    String? cropType,
    int? limit,
  }) {
    return DiagnosisFilters(
      farmId: farmId ?? this.farmId,
      status: status ?? this.status,
      cropType: cropType ?? this.cropType,
      limit: limit ?? this.limit,
    );
  }
}
