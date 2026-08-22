/// Risk assessment and hazard models (pure Dart without Freezed)
library risk_models;

/// Hazard types
enum HazardType {
  drought('DROUGHT'),
  flood('FLOOD'),
  locustPest('LOCUST_PEST'),
  vegetationStress('VEGETATION_STRESS'),
  frost('FROST'),
  heatStress('HEAT_STRESS');

  final String value;
  const HazardType(this.value);

  static HazardType fromString(String? type) {
    if (type == null) return HazardType.drought;
    final upper = type.toUpperCase().trim();
    for (final h in HazardType.values) {
      if (h.value == upper) return h;
    }
    return HazardType.drought;
  }
}

/// Risk levels
enum RiskLevel {
  low('LOW'),
  moderate('MODERATE'),
  high('HIGH'),
  critical('CRITICAL');

  final String value;
  const RiskLevel(this.value);

  static RiskLevel fromString(String? level) {
    if (level == null) return RiskLevel.low;
    final upper = level.toUpperCase().trim();
    for (final r in RiskLevel.values) {
      if (r.value == upper) return r;
    }
    return RiskLevel.low;
  }
}

/// Risk assessment model
class RiskAssessment {
  final String id;
  final String woredaId;
  final String hazardType;
  final String riskLevel;
  final double riskScore;
  final double confidence;
  final String? description;
  final Map<String, dynamic>? indicators;
  final int? affectedPopulation;
  final DateTime assessedAt;
  final WoredaDetails? woreda;

  const RiskAssessment({
    required this.id,
    required this.woredaId,
    required this.hazardType,
    required this.riskLevel,
    required this.riskScore,
    required this.confidence,
    this.description,
    this.indicators,
    this.affectedPopulation,
    required this.assessedAt,
    this.woreda,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    final assessedDate = json['assessedAt'] != null
        ? (DateTime.tryParse(json['assessedAt'].toString()) ?? DateTime.now())
        : (json['assessmentDate'] != null
            ? (DateTime.tryParse(json['assessmentDate'].toString()) ?? DateTime.now())
            : DateTime.now());

    return RiskAssessment(
      id: (json['id'] ?? '').toString(),
      woredaId: (json['woredaId'] ?? '').toString(),
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      riskLevel: (json['riskLevel'] ?? json['alertLevel'] ?? 'MODERATE').toString(),
      riskScore: ((json['riskScore'] ?? json['compositeScore'] ?? 0.5) as num).toDouble(),
      confidence: ((json['confidence'] ?? json['confidenceScore'] ?? 0.85) as num).toDouble(),
      description: json['description'] as String?,
      indicators: json['indicators'] as Map<String, dynamic>?,
      affectedPopulation: json['affectedPopulation'] as int?,
      assessedAt: assessedDate,
      woreda: json['woreda'] is Map<String, dynamic>
          ? WoredaDetails.fromJson(json['woreda'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'woredaId': woredaId,
    'hazardType': hazardType,
    'riskLevel': riskLevel,
    'riskScore': riskScore,
    'confidence': confidence,
    if (description != null) 'description': description,
    if (indicators != null) 'indicators': indicators,
    if (affectedPopulation != null) 'affectedPopulation': affectedPopulation,
    'assessedAt': assessedAt.toIso8601String(),
    if (woreda != null) 'woreda': woreda!.toJson(),
  };

  RiskAssessment copyWith({
    String? id,
    String? woredaId,
    String? hazardType,
    String? riskLevel,
    double? riskScore,
    double? confidence,
    String? description,
    Map<String, dynamic>? indicators,
    int? affectedPopulation,
    DateTime? assessedAt,
    WoredaDetails? woreda,
  }) {
    return RiskAssessment(
      id: id ?? this.id,
      woredaId: woredaId ?? this.woredaId,
      hazardType: hazardType ?? this.hazardType,
      riskLevel: riskLevel ?? this.riskLevel,
      riskScore: riskScore ?? this.riskScore,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      indicators: indicators ?? this.indicators,
      affectedPopulation: affectedPopulation ?? this.affectedPopulation,
      assessedAt: assessedAt ?? this.assessedAt,
      woreda: woreda ?? this.woreda,
    );
  }
}

/// Woreda details
class WoredaDetails {
  final String id;
  final String name;
  final String? zoneName;
  final String? regionName;

  const WoredaDetails({
    required this.id,
    required this.name,
    this.zoneName,
    this.regionName,
  });

  factory WoredaDetails.fromJson(Map<String, dynamic> json) {
    return WoredaDetails(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      zoneName: (json['zoneName'] ?? json['zone']?['nameEn'] ?? json['zone']?['name']) as String?,
      regionName: (json['regionName'] ?? json['region']?['nameEn'] ?? json['zone']?['region']?['nameEn']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (zoneName != null) 'zoneName': zoneName,
    if (regionName != null) 'regionName': regionName,
  };
}

/// Evaluate risk request
class EvaluateRiskRequest {
  final String? woredaId;
  final String? hazardType;

  const EvaluateRiskRequest({
    this.woredaId,
    this.hazardType,
  });

  factory EvaluateRiskRequest.fromJson(Map<String, dynamic> json) {
    return EvaluateRiskRequest(
      woredaId: json['woredaId'] as String?,
      hazardType: json['hazardType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (woredaId != null) 'woredaId': woredaId,
    if (hazardType != null) 'hazardType': hazardType,
  };
}

/// Risk statistics response
class RiskStatistics {
  final String period;
  final int totalAssessments;
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;
  final int criticalRisk;
  final Map<String, HazardStats>? hazardBreakdown;
  final Map<String, int>? regionBreakdown;

  const RiskStatistics({
    required this.period,
    this.totalAssessments = 0,
    this.lowRisk = 0,
    this.moderateRisk = 0,
    this.highRisk = 0,
    this.criticalRisk = 0,
    this.hazardBreakdown,
    this.regionBreakdown,
  });

  factory RiskStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, HazardStats>? parseHazards(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), HazardStats.fromJson(v as Map<String, dynamic>)));
      }
      return null;
    }

    Map<String, int>? parseRegions(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return RiskStatistics(
      period: (json['period'] ?? 'CURRENT').toString(),
      totalAssessments: (json['totalAssessments'] ?? 0) as int,
      lowRisk: (json['lowRisk'] ?? 0) as int,
      moderateRisk: (json['moderateRisk'] ?? 0) as int,
      highRisk: (json['highRisk'] ?? 0) as int,
      criticalRisk: (json['criticalRisk'] ?? 0) as int,
      hazardBreakdown: parseHazards(json['hazardBreakdown']),
      regionBreakdown: parseRegions(json['regionBreakdown']),
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'totalAssessments': totalAssessments,
    'lowRisk': lowRisk,
    'moderateRisk': moderateRisk,
    'highRisk': highRisk,
    'criticalRisk': criticalRisk,
    if (hazardBreakdown != null)
      'hazardBreakdown': hazardBreakdown!.map((k, v) => MapEntry(k, v.toJson())),
    if (regionBreakdown != null) 'regionBreakdown': regionBreakdown,
  };
}

/// Hazard statistics
class HazardStats {
  final int count;
  final double averageRisk;
  final int affectedWoredas;

  const HazardStats({
    this.count = 0,
    this.averageRisk = 0.0,
    this.affectedWoredas = 0,
  });

  factory HazardStats.fromJson(Map<String, dynamic> json) {
    return HazardStats(
      count: (json['count'] ?? 0) as int,
      averageRisk: ((json['averageRisk'] ?? 0.0) as num).toDouble(),
      affectedWoredas: (json['affectedWoredas'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'averageRisk': averageRisk,
    'affectedWoredas': affectedWoredas,
  };
}

/// Risk trend data point
class RiskTrendPoint {
  final DateTime date;
  final String hazardType;
  final double riskScore;
  final int affectedWoredas;

  const RiskTrendPoint({
    required this.date,
    required this.hazardType,
    required this.riskScore,
    this.affectedWoredas = 0,
  });

  factory RiskTrendPoint.fromJson(Map<String, dynamic> json) {
    return RiskTrendPoint(
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      riskScore: ((json['riskScore'] ?? 0.0) as num).toDouble(),
      affectedWoredas: (json['affectedWoredas'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'hazardType': hazardType,
    'riskScore': riskScore,
    'affectedWoredas': affectedWoredas,
  };
}

/// Hazard type utilities
class HazardTypeUtils {
  static const Map<String, String> displayNames = {
    'DROUGHT': 'Drought',
    'FLOOD': 'Flood',
    'LOCUST_PEST': 'Locust/Pest',
    'VEGETATION_STRESS': 'Vegetation Stress',
    'FROST': 'Frost',
    'HEAT_STRESS': 'Heat Stress',
  };

  static const Map<String, String> descriptions = {
    'DROUGHT': 'Low rainfall and water scarcity',
    'FLOOD': 'Excessive rainfall and flooding',
    'LOCUST_PEST': 'Locust swarms and pest infestation',
    'VEGETATION_STRESS': 'Poor crop health and vegetation',
    'FROST': 'Low temperatures and frost damage',
    'HEAT_STRESS': 'High temperatures affecting crops',
  };

  static String getDisplayName(String hazardType) {
    return displayNames[hazardType] ?? hazardType;
  }

  static String getDescription(String hazardType) {
    return descriptions[hazardType] ?? '';
  }

  static List<String> get allHazardTypes => displayNames.keys.toList();
}

/// Risk level utilities
class RiskLevelUtils {
  static const Map<String, String> displayNames = {
    'LOW': 'Low Risk',
    'MODERATE': 'Moderate Risk',
    'HIGH': 'High Risk',
    'CRITICAL': 'Critical Risk',
  };

  static String getDisplayName(String riskLevel) {
    return displayNames[riskLevel] ?? riskLevel;
  }

  static int getRiskPriority(String riskLevel) {
    switch (riskLevel) {
      case 'CRITICAL':
        return 4;
      case 'HIGH':
        return 3;
      case 'MODERATE':
        return 2;
      case 'LOW':
        return 1;
      default:
        return 0;
    }
  }
}
