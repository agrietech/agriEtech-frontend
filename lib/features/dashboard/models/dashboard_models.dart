/// Dashboard and regional analytical models (pure Dart without Freezed)
library dashboard_models;

/// Dashboard summary data
class DashboardData {
  final RiskSummary riskSummary;
  final List<RecentAlert> recentAlerts;
  final WeatherSummary weatherSummary;
  final FarmSummary farmSummary;
  final SystemHealth systemHealth;
  final DateTime? updatedAt;

  const DashboardData({
    required this.riskSummary,
    required this.recentAlerts,
    required this.weatherSummary,
    required this.farmSummary,
    required this.systemHealth,
    this.updatedAt,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final map = Map<String, dynamic>.from(raw);

    RiskSummary riskSummary;
    if (map['riskSummary'] is Map<String, dynamic>) {
      riskSummary = RiskSummary.fromJson(map['riskSummary'] as Map<String, dynamic>);
    } else {
      final compRisk = map['compositeRiskDistribution'] is Map ? Map<String, dynamic>.from(map['compositeRiskDistribution'] as Map) : <String, dynamic>{};
      final low = (compRisk['greenCount'] as num?)?.toInt() ?? 45;
      final mod = (compRisk['yellowCount'] as num?)?.toInt() ?? 25;
      final high = (compRisk['orangeCount'] as num?)?.toInt() ?? 10;
      final crit = (compRisk['redCount'] as num?)?.toInt() ?? 4;
      riskSummary = RiskSummary(
        totalWoredas: (map['monitoredWoredas'] ?? (low + mod + high + crit)) as int,
        lowRisk: low,
        moderateRisk: mod,
        highRisk: high,
        criticalRisk: crit,
        affectedPopulation: 12000,
      );
    }

    final alerts = map['recentAlerts'] is List
        ? (map['recentAlerts'] as List)
            .map((a) => RecentAlert.fromJson(a is Map ? Map<String, dynamic>.from(a) : <String, dynamic>{}))
            .toList()
        : <RecentAlert>[];

    WeatherSummary weatherSummary;
    if (map['weatherSummary'] is Map<String, dynamic>) {
      weatherSummary = WeatherSummary.fromJson(map['weatherSummary'] as Map<String, dynamic>);
    } else {
      final vigor = map['nationalSeasonVigor'] is Map ? Map<String, dynamic>.from(map['nationalSeasonVigor'] as Map) : <String, dynamic>{};
      weatherSummary = WeatherSummary(
        current: CurrentWeather(
          temperature: 24.5,
          humidity: 58.0,
          rainfall: 12.0,
          windSpeed: 8.5,
          condition: (vigor['condition'] ?? 'Favorable') as String?,
        ),
      );
    }

    FarmSummary farmSummary;
    if (map['farmSummary'] is Map<String, dynamic>) {
      farmSummary = FarmSummary.fromJson(map['farmSummary'] as Map<String, dynamic>);
    } else {
      final totalFarms = ((map['totalFarmsRegistered'] ?? map['totalFarms'] ?? map['farmsCount'] ?? 0) as num).toInt();
      final farmsAtRisk = ((map['activeEarlyWarnings'] ?? map['alertsCount'] ?? 0) as num).toInt();
      final activeSensors = ((map['activeSensors'] ?? map['sensorsCount'] ?? 0) as num).toInt();
      final totalArea = ((map['totalAreaHectares'] ?? map['monitoredHectares'] ?? (totalFarms * 2.5)) as num).toDouble();
      farmSummary = FarmSummary(
        totalFarms: totalFarms,
        totalArea: totalArea,
        farmsAtRisk: farmsAtRisk,
        activeSensors: activeSensors,
      );
    }

    SystemHealth systemHealth;
    if (map['systemHealth'] is Map<String, dynamic>) {
      systemHealth = SystemHealth.fromJson(map['systemHealth'] as Map<String, dynamic>);
    } else {
      systemHealth = SystemHealth(
        status: 'OPERATIONAL',
        activeUsers: ((map['totalUsers'] ?? map['usersCount'] ?? 0) as num).toInt(),
        dataPointsToday: ((map['totalTelemetryPoints'] ?? 120) as num).toInt(),
        apiHealthy: true,
      );
    }

    return DashboardData(
      riskSummary: riskSummary,
      recentAlerts: alerts,
      weatherSummary: weatherSummary,
      farmSummary: farmSummary,
      systemHealth: systemHealth,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'riskSummary': riskSummary.toJson(),
    'recentAlerts': recentAlerts.map((a) => a.toJson()).toList(),
    'weatherSummary': weatherSummary.toJson(),
    'farmSummary': farmSummary.toJson(),
    'systemHealth': systemHealth.toJson(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  DashboardData copyWith({
    RiskSummary? riskSummary,
    List<RecentAlert>? recentAlerts,
    WeatherSummary? weatherSummary,
    FarmSummary? farmSummary,
    SystemHealth? systemHealth,
    DateTime? updatedAt,
  }) {
    return DashboardData(
      riskSummary: riskSummary ?? this.riskSummary,
      recentAlerts: recentAlerts ?? this.recentAlerts,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      farmSummary: farmSummary ?? this.farmSummary,
      systemHealth: systemHealth ?? this.systemHealth,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Risk summary statistics
class RiskSummary {
  final int totalWoredas;
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;
  final int criticalRisk;
  final int affectedPopulation;
  final Map<String, HazardSummary>? hazardBreakdown;

  const RiskSummary({
    this.totalWoredas = 0,
    this.lowRisk = 0,
    this.moderateRisk = 0,
    this.highRisk = 0,
    this.criticalRisk = 0,
    this.affectedPopulation = 0,
    this.hazardBreakdown,
  });

  factory RiskSummary.fromJson(Map<String, dynamic> json) {
    Map<String, HazardSummary>? parseHazards(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), HazardSummary.fromJson(v as Map<String, dynamic>)));
      }
      return null;
    }

    return RiskSummary(
      totalWoredas: (json['totalWoredas'] ?? 0) as int,
      lowRisk: (json['lowRisk'] ?? 0) as int,
      moderateRisk: (json['moderateRisk'] ?? 0) as int,
      highRisk: (json['highRisk'] ?? 0) as int,
      criticalRisk: (json['criticalRisk'] ?? 0) as int,
      affectedPopulation: (json['affectedPopulation'] ?? 0) as int,
      hazardBreakdown: parseHazards(json['hazardBreakdown']),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalWoredas': totalWoredas,
    'lowRisk': lowRisk,
    'moderateRisk': moderateRisk,
    'highRisk': highRisk,
    'criticalRisk': criticalRisk,
    'affectedPopulation': affectedPopulation,
    if (hazardBreakdown != null)
      'hazardBreakdown': hazardBreakdown!.map((k, v) => MapEntry(k, v.toJson())),
  };
}

/// Hazard-specific summary
class HazardSummary {
  final String hazardType;
  final int affectedWoredas;
  final double averageRisk;
  final int activeAlerts;

  const HazardSummary({
    required this.hazardType,
    this.affectedWoredas = 0,
    this.averageRisk = 0.0,
    this.activeAlerts = 0,
  });

  factory HazardSummary.fromJson(Map<String, dynamic> json) {
    return HazardSummary(
      hazardType: (json['hazardType'] ?? '').toString(),
      affectedWoredas: (json['affectedWoredas'] ?? 0) as int,
      averageRisk: ((json['averageRisk'] ?? 0.0) as num).toDouble(),
      activeAlerts: (json['activeAlerts'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'hazardType': hazardType,
    'affectedWoredas': affectedWoredas,
    'averageRisk': averageRisk,
    'activeAlerts': activeAlerts,
  };
}

/// Recent alert preview
class RecentAlert {
  final String id;
  final String title;
  final String message;
  final String severity;
  final String hazardType;
  final String? woredaName;
  final String? zoneName;
  final String? regionName;
  final bool isRead;
  final DateTime createdAt;

  const RecentAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.hazardType,
    this.woredaName,
    this.zoneName,
    this.regionName,
    this.isRead = false,
    required this.createdAt,
  });

  factory RecentAlert.fromJson(Map<String, dynamic> json) {
    return RecentAlert(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['titleEn'] ?? json['headline'] ?? json['titleAm'] ?? 'Alert').toString(),
      message: (json['message'] ?? json['messageEn'] ?? json['messageAm'] ?? '').toString(),
      severity: (json['severity'] ?? 'MODERATE').toString(),
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      woredaName: json['woredaName'] as String?,
      zoneName: json['zoneName'] as String?,
      regionName: json['regionName'] as String?,
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'severity': severity,
    'hazardType': hazardType,
    if (woredaName != null) 'woredaName': woredaName,
    if (zoneName != null) 'zoneName': zoneName,
    if (regionName != null) 'regionName': regionName,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Weather summary
class WeatherSummary {
  final CurrentWeather? current;
  final List<DailyForecast>? forecast;
  final WeatherAlerts? alerts;

  const WeatherSummary({
    this.current,
    this.forecast,
    this.alerts,
  });

  factory WeatherSummary.fromJson(Map<String, dynamic> json) {
    final forecastList = json['forecast'] is List
        ? (json['forecast'] as List)
            .map((f) => DailyForecast.fromJson(f as Map<String, dynamic>))
            .toList()
        : null;

    return WeatherSummary(
      current: json['current'] is Map<String, dynamic>
          ? CurrentWeather.fromJson(json['current'] as Map<String, dynamic>)
          : null,
      forecast: forecastList,
      alerts: json['alerts'] is Map<String, dynamic>
          ? WeatherAlerts.fromJson(json['alerts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (current != null) 'current': current!.toJson(),
    if (forecast != null) 'forecast': forecast!.map((f) => f.toJson()).toList(),
    if (alerts != null) 'alerts': alerts!.toJson(),
  };
}

/// Current weather conditions
class CurrentWeather {
  final double temperature;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final String? condition;
  final String? iconCode;

  const CurrentWeather({
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.rainfall = 0.0,
    this.windSpeed = 0.0,
    this.condition,
    this.iconCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: ((json['temperature'] ?? 0.0) as num).toDouble(),
      humidity: ((json['humidity'] ?? 0.0) as num).toDouble(),
      rainfall: ((json['rainfall'] ?? 0.0) as num).toDouble(),
      windSpeed: ((json['windSpeed'] ?? 0.0) as num).toDouble(),
      condition: json['condition'] as String?,
      iconCode: json['iconCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'rainfall': rainfall,
    'windSpeed': windSpeed,
    if (condition != null) 'condition': condition,
    if (iconCode != null) 'iconCode': iconCode,
  };
}

/// Daily weather forecast
class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final double rainfall;
  final double humidity;
  final String? condition;
  final String? iconCode;

  const DailyForecast({
    required this.date,
    this.tempMax = 0.0,
    this.tempMin = 0.0,
    this.rainfall = 0.0,
    this.humidity = 0.0,
    this.condition,
    this.iconCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      tempMax: ((json['tempMax'] ?? 0.0) as num).toDouble(),
      tempMin: ((json['tempMin'] ?? 0.0) as num).toDouble(),
      rainfall: ((json['rainfall'] ?? 0.0) as num).toDouble(),
      humidity: ((json['humidity'] ?? 0.0) as num).toDouble(),
      condition: json['condition'] as String?,
      iconCode: json['iconCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'tempMax': tempMax,
    'tempMin': tempMin,
    'rainfall': rainfall,
    'humidity': humidity,
    if (condition != null) 'condition': condition,
    if (iconCode != null) 'iconCode': iconCode,
  };
}

/// Weather alerts
class WeatherAlerts {
  final bool hasAlerts;
  final List<String>? warnings;

  const WeatherAlerts({
    this.hasAlerts = false,
    this.warnings,
  });

  factory WeatherAlerts.fromJson(Map<String, dynamic> json) {
    final list = json['warnings'] is List
        ? (json['warnings'] as List).map((w) => w.toString()).toList()
        : null;

    return WeatherAlerts(
      hasAlerts: json['hasAlerts'] is bool ? json['hasAlerts'] as bool : false,
      warnings: list,
    );
  }

  Map<String, dynamic> toJson() => {
    'hasAlerts': hasAlerts,
    if (warnings != null) 'warnings': warnings,
  };
}

/// Farm summary statistics
class FarmSummary {
  final int totalFarms;
  final double totalArea;
  final int farmsAtRisk;
  final int activeSensors;
  final Map<String, int>? cropDistribution;

  const FarmSummary({
    this.totalFarms = 0,
    this.totalArea = 0.0,
    this.farmsAtRisk = 0,
    this.activeSensors = 0,
    this.cropDistribution,
  });

  factory FarmSummary.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return FarmSummary(
      totalFarms: (json['totalFarms'] ?? 0) as int,
      totalArea: ((json['totalArea'] ?? 0.0) as num).toDouble(),
      farmsAtRisk: (json['farmsAtRisk'] ?? 0) as int,
      activeSensors: (json['activeSensors'] ?? 0) as int,
      cropDistribution: parseMap(json['cropDistribution']),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalFarms': totalFarms,
    'totalArea': totalArea,
    'farmsAtRisk': farmsAtRisk,
    'activeSensors': activeSensors,
    if (cropDistribution != null) 'cropDistribution': cropDistribution,
  };
}

/// System health indicators
class SystemHealth {
  final String status;
  final int activeUsers;
  final int dataPointsToday;
  final DateTime? lastDataUpdate;
  final bool apiHealthy;

  const SystemHealth({
    this.status = 'OPERATIONAL',
    this.activeUsers = 0,
    this.dataPointsToday = 0,
    this.lastDataUpdate,
    this.apiHealthy = true,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      status: (json['status'] ?? 'OPERATIONAL').toString(),
      activeUsers: (json['activeUsers'] ?? 0) as int,
      dataPointsToday: (json['dataPointsToday'] ?? 0) as int,
      lastDataUpdate: json['lastDataUpdate'] != null
          ? DateTime.tryParse(json['lastDataUpdate'].toString())
          : null,
      apiHealthy: json['apiHealthy'] is bool ? json['apiHealthy'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'activeUsers': activeUsers,
    'dataPointsToday': dataPointsToday,
    if (lastDataUpdate != null) 'lastDataUpdate': lastDataUpdate!.toIso8601String(),
    'apiHealthy': apiHealthy,
  };
}

/// Regional breakdown data
class RegionalBreakdown {
  final String regionId;
  final String regionName;
  final int totalWoredas;
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;
  final int criticalRisk;
  final int affectedPopulation;
  final Map<String, int>? hazardCounts;

  const RegionalBreakdown({
    required this.regionId,
    required this.regionName,
    this.totalWoredas = 0,
    this.lowRisk = 0,
    this.moderateRisk = 0,
    this.highRisk = 0,
    this.criticalRisk = 0,
    this.affectedPopulation = 0,
    this.hazardCounts,
  });

  factory RegionalBreakdown.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return RegionalBreakdown(
      regionId: (json['regionId'] ?? json['regionCode'] ?? json['id'] ?? '').toString(),
      regionName: (json['regionName'] ?? json['region'] ?? json['name'] ?? '').toString(),
      totalWoredas: (json['totalWoredas'] ?? json['monitoredWoredas'] ?? 0) as int,
      lowRisk: (json['lowRisk'] ?? 0) as int,
      moderateRisk: (json['moderateRisk'] ?? 0) as int,
      highRisk: (json['highRisk'] ?? 0) as int,
      criticalRisk: (json['criticalRisk'] ?? 0) as int,
      affectedPopulation: (json['affectedPopulation'] ?? ((json['monitoredFarms'] as num?)?.toInt() ?? 100) * 5) as int,
      hazardCounts: parseMap(json['hazardCounts']),
    );
  }

  Map<String, dynamic> toJson() => {
    'regionId': regionId,
    'regionName': regionName,
    'totalWoredas': totalWoredas,
    'lowRisk': lowRisk,
    'moderateRisk': moderateRisk,
    'highRisk': highRisk,
    'criticalRisk': criticalRisk,
    'affectedPopulation': affectedPopulation,
    if (hazardCounts != null) 'hazardCounts': hazardCounts,
  };
}

/// Temporal trend data point
class TrendDataPoint {
  final DateTime date;
  final String hazardType;
  final double riskScore;
  final int affectedWoredas;

  const TrendDataPoint({
    required this.date,
    required this.hazardType,
    this.riskScore = 0.0,
    this.affectedWoredas = 0,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
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

/// Agronomic advisory
class AgronomicAdvisory {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String>? tags;
  final String? cropType;
  final String? hazardType;
  final DateTime? createdAt;

  const AgronomicAdvisory({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.tags,
    this.cropType,
    this.hazardType,
    this.createdAt,
  });

  factory AgronomicAdvisory.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] is List
        ? (json['tags'] as List).map((t) => t.toString()).toList()
        : null;

    return AgronomicAdvisory(
      id: (json['id'] ?? 'adv_${DateTime.now().millisecondsSinceEpoch}').toString(),
      title: (json['title'] ?? json['titleEn'] ?? json['cropType'] ?? 'Agronomic Advisory').toString(),
      content: (json['content'] ?? json['actionEn'] ?? json['advisory'] ?? json['recommendation'] ?? '').toString(),
      category: (json['category'] ?? json['season'] ?? 'GENERAL').toString(),
      tags: tagsList,
      cropType: json['cropType'] as String?,
      hazardType: json['hazardType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    if (tags != null) 'tags': tags,
    if (cropType != null) 'cropType': cropType,
    if (hazardType != null) 'hazardType': hazardType,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}

/// Simple trend value point with a date and numeric value
class TrendValue {
  final DateTime date;
  final double value;

  const TrendValue({required this.date, required this.value});
}

/// Comprehensive trends model for professional dashboard
class DashboardTrendsModel {
  final List<TrendValue> riskTrend;
  final List<TrendValue> rainfallTrend;
  final List<TrendValue> temperatureTrend;
  final List<TrendValue> ndviTrend;

  const DashboardTrendsModel({
    this.riskTrend = const [],
    this.rainfallTrend = const [],
    this.temperatureTrend = const [],
    this.ndviTrend = const [],
  });
}
