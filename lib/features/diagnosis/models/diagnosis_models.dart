/// Disease diagnosis models (pure Dart without Freezed)
library diagnosis_models;

/// Disease diagnosis model
class DiagnosisModel {
  final String id;
  final String farmId;
  final String imageUrl;
  final String? cropIdentified;
  final String? cropIdentifiedAm;
  final String? diseaseName;
  final String? diseaseNameAm;
  final String? pathogen;
  final String? severity;
  final double? confidenceScore;
  final String? treatment;
  final String? treatmentEn;
  final String? treatmentAm;
  final String? treatmentOm;
  final String? preventionTips;
  final String? preventionEn;
  final String? preventionAm;
  final String? symptomsEn;
  final String? symptomsAm;
  final String? aiModel;
  final Map<String, dynamic>? rawResponse;
  final String diagnosisStatus;
  final String createdAt;
  final FarmBasicInfo? farm;

  const DiagnosisModel({
    required this.id,
    required this.farmId,
    required this.imageUrl,
    this.cropIdentified,
    this.cropIdentifiedAm,
    this.diseaseName,
    this.diseaseNameAm,
    this.pathogen,
    this.severity,
    this.confidenceScore,
    this.treatment,
    this.treatmentEn,
    this.treatmentAm,
    this.treatmentOm,
    this.preventionTips,
    this.preventionEn,
    this.preventionAm,
    this.symptomsEn,
    this.symptomsAm,
    this.aiModel,
    this.rawResponse,
    this.diagnosisStatus = 'PENDING',
    required this.createdAt,
    this.farm,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    final rawResp = json['rawResponse'] is Map ? Map<String, dynamic>.from(json['rawResponse'] as Map) : null;
    final geminiDiag = rawResp != null && rawResp['gemini'] is Map ? Map<String, dynamic>.from(rawResp['gemini'] as Map) : null;

    final cropEn = json['cropIdentified'] ?? json['cropType'] ?? geminiDiag?['cropIdentified']?['nameEn'];
    final cropAm = json['cropIdentifiedAm'] ?? geminiDiag?['cropIdentified']?['nameAm'];
    final disEn = json['diseaseName'] ?? geminiDiag?['diseaseName']?['nameEn'];
    final disAm = json['diseaseNameAm'] ?? geminiDiag?['diseaseName']?['nameAm'];
    final pathogenVal = json['pathogen'] ?? geminiDiag?['pathogen'];
    final severityVal = json['severity'] ?? geminiDiag?['severity'] ?? 'MODERATE';

    final treatEn = json['treatmentEn'] ?? json['treatment'] ?? geminiDiag?['treatment']?['chemicalEn'];
    final treatAm = json['treatmentAm'] ?? geminiDiag?['treatment']?['chemicalAm'];
    final treatOm = json['treatmentOm'] ?? geminiDiag?['treatment']?['culturalOm'];
    final prevEn = json['preventionEn'] ?? json['preventionTips'] ?? geminiDiag?['prevention']?['en'];
    final prevAm = json['preventionAm'] ?? geminiDiag?['prevention']?['am'];
    final sympEn = json['symptomsEn'] ?? geminiDiag?['symptoms']?['en'];
    final sympAm = json['symptomsAm'] ?? geminiDiag?['symptoms']?['am'];
    final modelName = json['aiModel'] ?? 'Plant.id Botanical + Google Gemini 2.5 Flash';

    return DiagnosisModel(
      id: (json['id'] ?? '').toString(),
      farmId: (json['farmId'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image'] ?? '').toString(),
      cropIdentified: cropEn as String?,
      cropIdentifiedAm: cropAm as String?,
      diseaseName: disEn as String?,
      diseaseNameAm: disAm as String?,
      pathogen: pathogenVal as String?,
      severity: severityVal as String?,
      confidenceScore: json['confidenceScore'] != null
          ? ((json['confidenceScore'] as num).toDouble())
          : (json['confidence'] != null ? ((json['confidence'] as num).toDouble()) : 0.94),
      treatment: (json['treatment'] ?? treatEn ?? treatAm ?? treatOm) as String?,
      treatmentEn: treatEn as String?,
      treatmentAm: treatAm as String?,
      treatmentOm: treatOm as String?,
      preventionTips: (json['preventionTips'] ?? prevEn ?? prevAm) as String?,
      preventionEn: prevEn as String?,
      preventionAm: prevAm as String?,
      symptomsEn: sympEn as String?,
      symptomsAm: sympAm as String?,
      aiModel: modelName as String?,
      rawResponse: rawResp,
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
    if (cropIdentifiedAm != null) 'cropIdentifiedAm': cropIdentifiedAm,
    if (diseaseName != null) 'diseaseName': diseaseName,
    if (diseaseNameAm != null) 'diseaseNameAm': diseaseNameAm,
    if (pathogen != null) 'pathogen': pathogen,
    if (severity != null) 'severity': severity,
    if (confidenceScore != null) 'confidenceScore': confidenceScore,
    if (treatment != null) 'treatment': treatment,
    if (treatmentEn != null) 'treatmentEn': treatmentEn,
    if (treatmentAm != null) 'treatmentAm': treatmentAm,
    if (treatmentOm != null) 'treatmentOm': treatmentOm,
    if (preventionTips != null) 'preventionTips': preventionTips,
    if (preventionEn != null) 'preventionEn': preventionEn,
    if (preventionAm != null) 'preventionAm': preventionAm,
    if (symptomsEn != null) 'symptomsEn': symptomsEn,
    if (symptomsAm != null) 'symptomsAm': symptomsAm,
    if (aiModel != null) 'aiModel': aiModel,
    if (rawResponse != null) 'rawResponse': rawResponse,
    'diagnosisStatus': diagnosisStatus,
    'createdAt': createdAt,
    if (farm != null) 'farm': farm!.toJson(),
  };
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
  final String? imagePath;
  final List<int>? imageBytes;
  final String? cropType;
  final String language;

  const CreateDiagnosisRequest({
    required this.farmId,
    this.imageBase64 = '',
    this.imagePath,
    this.imageBytes,
    this.cropType,
    this.language = 'en',
  });

  factory CreateDiagnosisRequest.fromJson(Map<String, dynamic> json) {
    return CreateDiagnosisRequest(
      farmId: (json['farmId'] ?? '').toString(),
      imageBase64: (json['imageBase64'] ?? '').toString(),
      imagePath: json['imagePath'] as String?,
      cropType: json['cropType'] as String?,
      language: (json['language'] ?? 'en').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'farmId': farmId,
    if (imageBase64.isNotEmpty) 'imageBase64': imageBase64,
    if (imagePath != null) 'imagePath': imagePath,
    if (cropType != null) 'cropType': cropType,
    'language': language,
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
