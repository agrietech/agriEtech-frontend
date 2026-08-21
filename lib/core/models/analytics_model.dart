/// Analytics data models (pure Dart without Freezed)
library analytics_model;

class DashboardAnalyticsModel {
  final RiskOverviewModel riskOverview;
  final List<RegionalRiskModel> regionalBreakdown;
  final WeatherSummaryModel weatherSummary;
  final List<AlertSummaryModel> recentAlerts;
  final CropCalendarModel cropCalendar;
  final int? totalFarms;
  final int? totalWoredas;
  final double? averageRiskScore;

  const DashboardAnalyticsModel({
    required this.riskOverview,
    required this.regionalBreakdown,
    required this.weatherSummary,
    required this.recentAlerts,
    required this.cropCalendar,
    this.totalFarms,
    this.totalWoredas,
    this.averageRiskScore,
  });

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    RiskOverviewModel riskOverview;
    if (map['riskOverview'] is Map<String, dynamic>) {
      riskOverview = RiskOverviewModel.fromJson(map['riskOverview'] as Map<String, dynamic>);
    } else {
      final compRisk = map['compositeRiskDistribution'] as Map<String, dynamic>? ?? {};
      final low = (compRisk['greenCount'] as num?)?.toInt() ?? 12;
      final mod = (compRisk['yellowCount'] as num?)?.toInt() ?? 8;
      final high = (compRisk['orangeCount'] as num?)?.toInt() ?? 4;
      final crit = (compRisk['redCount'] as num?)?.toInt() ?? 1;
      riskOverview = RiskOverviewModel(
        lowRisk: low,
        moderateRisk: mod,
        highRisk: high,
        criticalRisk: crit,
        total: low + mod + high + crit,
        avgScore: 2.1,
        dominantHazard: 'DROUGHT',
      );
    }

    final regional = map['regionalBreakdown'] is List
        ? (map['regionalBreakdown'] as List)
            .map((r) => RegionalRiskModel.fromJson(r as Map<String, dynamic>))
            .toList()
        : <RegionalRiskModel>[];

    WeatherSummaryModel weather;
    if (map['weatherSummary'] is Map<String, dynamic>) {
      weather = WeatherSummaryModel.fromJson(map['weatherSummary'] as Map<String, dynamic>);
    } else {
      weather = const WeatherSummaryModel(
        avgTemperature: 22.0,
        minTemperature: 15.0,
        maxTemperature: 28.0,
        totalRainfall: 15.5,
        avgHumidity: 60.0,
        avgWindSpeed: 10.0,
        weatherCondition: 'Partly Cloudy',
      );
    }

    final alerts = map['recentAlerts'] is List
        ? (map['recentAlerts'] as List)
            .map((a) => AlertSummaryModel.fromJson(a as Map<String, dynamic>))
            .toList()
        : <AlertSummaryModel>[];

    CropCalendarModel cropCalendar;
    if (map['cropCalendar'] is Map<String, dynamic>) {
      cropCalendar = CropCalendarModel.fromJson(map['cropCalendar'] as Map<String, dynamic>);
    } else {
      cropCalendar = CropCalendarModel(
        currentSeason: 'Meher',
        cropStage: 'Vegetative',
        recommendedActivities: const ['Weeding', 'Fertilizer application'],
        seasonStart: DateTime(2026, 6, 1),
        seasonEnd: DateTime(2026, 11, 30),
        daysRemaining: 75,
      );
    }

    return DashboardAnalyticsModel(
      riskOverview: riskOverview,
      regionalBreakdown: regional,
      weatherSummary: weather,
      recentAlerts: alerts,
      cropCalendar: cropCalendar,
      totalFarms: map['totalFarms'] != null
          ? (map['totalFarms'] as num?)?.toInt()
          : (map['totalFarmsRegistered'] as num?)?.toInt(),
      totalWoredas: map['totalWoredas'] != null
          ? (map['totalWoredas'] as num?)?.toInt()
          : (map['monitoredWoredas'] as num?)?.toInt(),
      averageRiskScore: map['averageRiskScore'] != null
          ? ((map['averageRiskScore'] as num).toDouble())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'riskOverview': riskOverview.toJson(),
    'regionalBreakdown': regionalBreakdown.map((r) => r.toJson()).toList(),
    'weatherSummary': weatherSummary.toJson(),
    'recentAlerts': recentAlerts.map((a) => a.toJson()).toList(),
    'cropCalendar': cropCalendar.toJson(),
    if (totalFarms != null) 'totalFarms': totalFarms,
    if (totalWoredas != null) 'totalWoredas': totalWoredas,
    if (averageRiskScore != null) 'averageRiskScore': averageRiskScore,
  };
}

class RiskOverviewModel {
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;
  final int criticalRisk;
  final int total;
  final double avgScore;
  final String? dominantHazard;
  final Map<String, int>? hazardBreakdown;

  const RiskOverviewModel({
    required this.lowRisk,
    required this.moderateRisk,
    required this.highRisk,
    required this.criticalRisk,
    required this.total,
    required this.avgScore,
    this.dominantHazard,
    this.hazardBreakdown,
  });

  factory RiskOverviewModel.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return RiskOverviewModel(
      lowRisk: (json['lowRisk'] ?? 0) as int,
      moderateRisk: (json['moderateRisk'] ?? 0) as int,
      highRisk: (json['highRisk'] ?? 0) as int,
      criticalRisk: (json['criticalRisk'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
      avgScore: ((json['avgScore'] ?? 0.0) as num).toDouble(),
      dominantHazard: json['dominantHazard'] as String?,
      hazardBreakdown: parseMap(json['hazardBreakdown']),
    );
  }

  Map<String, dynamic> toJson() => {
    'lowRisk': lowRisk,
    'moderateRisk': moderateRisk,
    'highRisk': highRisk,
    'criticalRisk': criticalRisk,
    'total': total,
    'avgScore': avgScore,
    if (dominantHazard != null) 'dominantHazard': dominantHazard,
    if (hazardBreakdown != null) 'hazardBreakdown': hazardBreakdown,
  };
}

class RegionalRiskModel {
  final String regionId;
  final String regionName;
  final int totalWoredas;
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;
  final int criticalRisk;
  final double avgRiskScore;
  final String? dominantHazard;

  const RegionalRiskModel({
    required this.regionId,
    required this.regionName,
    this.totalWoredas = 0,
    this.lowRisk = 0,
    this.moderateRisk = 0,
    this.highRisk = 0,
    this.criticalRisk = 0,
    this.avgRiskScore = 1.5,
    this.dominantHazard,
  });

  factory RegionalRiskModel.fromJson(Map<String, dynamic> json) {
    return RegionalRiskModel(
      regionId: (json['regionId'] ?? json['regionCode'] ?? json['id'] ?? '').toString(),
      regionName: (json['regionName'] ?? json['region'] ?? json['name'] ?? '').toString(),
      totalWoredas: (json['totalWoredas'] ?? json['monitoredWoredas'] ?? 0) as int,
      lowRisk: (json['lowRisk'] ?? 0) as int,
      moderateRisk: (json['moderateRisk'] ?? 0) as int,
      highRisk: (json['highRisk'] ?? 0) as int,
      criticalRisk: (json['criticalRisk'] ?? 0) as int,
      avgRiskScore: ((json['avgRiskScore'] ?? (json['alertStatus'] == 'CRITICAL' ? 4.0 : json['alertStatus'] == 'HIGH' ? 3.0 : json['alertStatus'] == 'MODERATE' ? 2.0 : 1.5)) as num).toDouble(),
      dominantHazard: (json['dominantHazard'] ?? json['alertStatus'] ?? 'DROUGHT') as String?,
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
    'avgRiskScore': avgRiskScore,
    if (dominantHazard != null) 'dominantHazard': dominantHazard,
  };
}

class WeatherSummaryModel {
  final double avgTemperature;
  final double minTemperature;
  final double maxTemperature;
  final double totalRainfall;
  final double avgHumidity;
  final double avgWindSpeed;
  final String? weatherCondition;
  final List<DailyForecastModel>? forecast;

  const WeatherSummaryModel({
    required this.avgTemperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.totalRainfall,
    required this.avgHumidity,
    required this.avgWindSpeed,
    this.weatherCondition,
    this.forecast,
  });

  factory WeatherSummaryModel.fromJson(Map<String, dynamic> json) {
    final forecastList = json['forecast'] is List
        ? (json['forecast'] as List)
            .map((f) => DailyForecastModel.fromJson(f as Map<String, dynamic>))
            .toList()
        : null;

    return WeatherSummaryModel(
      avgTemperature: ((json['avgTemperature'] ?? 22.0) as num).toDouble(),
      minTemperature: ((json['minTemperature'] ?? 15.0) as num).toDouble(),
      maxTemperature: ((json['maxTemperature'] ?? 28.0) as num).toDouble(),
      totalRainfall: ((json['totalRainfall'] ?? 15.5) as num).toDouble(),
      avgHumidity: ((json['avgHumidity'] ?? 60.0) as num).toDouble(),
      avgWindSpeed: ((json['avgWindSpeed'] ?? 10.0) as num).toDouble(),
      weatherCondition: json['weatherCondition'] as String?,
      forecast: forecastList,
    );
  }

  Map<String, dynamic> toJson() => {
    'avgTemperature': avgTemperature,
    'minTemperature': minTemperature,
    'maxTemperature': maxTemperature,
    'totalRainfall': totalRainfall,
    'avgHumidity': avgHumidity,
    'avgWindSpeed': avgWindSpeed,
    if (weatherCondition != null) 'weatherCondition': weatherCondition,
    if (forecast != null) 'forecast': forecast!.map((f) => f.toJson()).toList(),
  };
}

class DailyForecastModel {
  final String date;
  final double tempMax;
  final double tempMin;
  final double precipitation;
  final double humidity;
  final String? condition;

  const DailyForecastModel({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.humidity,
    this.condition,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: (json['date'] ?? '').toString(),
      tempMax: ((json['tempMax'] ?? 28.0) as num).toDouble(),
      tempMin: ((json['tempMin'] ?? 15.0) as num).toDouble(),
      precipitation: ((json['precipitation'] ?? 0.0) as num).toDouble(),
      humidity: ((json['humidity'] ?? 60.0) as num).toDouble(),
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'tempMax': tempMax,
    'tempMin': tempMin,
    'precipitation': precipitation,
    'humidity': humidity,
    if (condition != null) 'condition': condition,
  };
}

class AlertSummaryModel {
  final String severity;
  final String hazardType;
  final int count;
  final int affected;

  const AlertSummaryModel({
    required this.severity,
    required this.hazardType,
    required this.count,
    required this.affected,
  });

  factory AlertSummaryModel.fromJson(Map<String, dynamic> json) {
    return AlertSummaryModel(
      severity: (json['severity'] ?? 'MODERATE').toString(),
      hazardType: (json['hazardType'] ?? 'DROUGHT').toString(),
      count: (json['count'] ?? 0) as int,
      affected: (json['affected'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'severity': severity,
    'hazardType': hazardType,
    'count': count,
    'affected': affected,
  };
}

class CropCalendarModel {
  final String currentSeason;
  final String cropStage;
  final List<String> recommendedActivities;
  final DateTime seasonStart;
  final DateTime seasonEnd;
  final int? daysRemaining;

  const CropCalendarModel({
    required this.currentSeason,
    required this.cropStage,
    required this.recommendedActivities,
    required this.seasonStart,
    required this.seasonEnd,
    this.daysRemaining,
  });

  factory CropCalendarModel.fromJson(Map<String, dynamic> json) {
    final activities = json['recommendedActivities'] is List
        ? (json['recommendedActivities'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    return CropCalendarModel(
      currentSeason: (json['currentSeason'] ?? 'Meher').toString(),
      cropStage: (json['cropStage'] ?? 'Vegetative').toString(),
      recommendedActivities: activities,
      seasonStart: json['seasonStart'] != null
          ? (DateTime.tryParse(json['seasonStart'].toString()) ?? DateTime.now())
          : DateTime.now(),
      seasonEnd: json['seasonEnd'] != null
          ? (DateTime.tryParse(json['seasonEnd'].toString()) ?? DateTime.now().add(const Duration(days: 90)))
          : DateTime.now().add(const Duration(days: 90)),
      daysRemaining: json['daysRemaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentSeason': currentSeason,
    'cropStage': cropStage,
    'recommendedActivities': recommendedActivities,
    'seasonStart': seasonStart.toIso8601String(),
    'seasonEnd': seasonEnd.toIso8601String(),
    if (daysRemaining != null) 'daysRemaining': daysRemaining,
  };
}

class TemporalTrendModel {
  final String period;
  final List<TrendDataPoint> riskTrend;
  final List<TrendDataPoint> rainfallTrend;
  final List<TrendDataPoint> temperatureTrend;
  final List<TrendDataPoint> ndviTrend;

  const TemporalTrendModel({
    required this.period,
    required this.riskTrend,
    required this.rainfallTrend,
    required this.temperatureTrend,
    required this.ndviTrend,
  });

  factory TemporalTrendModel.fromJson(Map<String, dynamic> json) {
    final period = (json['period'] ?? json['timeframe'] ?? 'DAILY').toString();

    List<TrendDataPoint> parseTrend(dynamic list) {
      if (list is List) {
        return list.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    }

    if (json['metrics'] is List) {
      final metrics = json['metrics'] as List;
      final riskTrend = metrics.map((m) {
        final d = (m['date'] ?? m['month'] ?? m['year'] ?? '').toString();
        final v = ((m['spiValue'] ?? m['soilMoisturePercent'] ?? 1.5) as num).toDouble();
        return TrendDataPoint(date: d, value: v);
      }).toList();

      final rainfallTrend = metrics.map((m) {
        final d = (m['date'] ?? m['month'] ?? m['year'] ?? '').toString();
        final v = ((m['rainfallMm'] ?? m['annualRainfallMm'] ?? 0.0) as num).toDouble();
        return TrendDataPoint(date: d, value: v);
      }).toList();

      final temperatureTrend = metrics.map((m) {
        final d = (m['date'] ?? m['month'] ?? m['year'] ?? '').toString();
        final v = ((m['tempMaxC'] ?? m['meanTempC'] ?? 24.0) as num).toDouble();
        return TrendDataPoint(date: d, value: v);
      }).toList();

      final ndviTrend = metrics.map((m) {
        final d = (m['date'] ?? m['month'] ?? m['year'] ?? '').toString();
        final v = ((m['ndvi'] ?? m['avgNdvi'] ?? 0.5) as num).toDouble();
        return TrendDataPoint(date: d, value: v);
      }).toList();

      return TemporalTrendModel(
        period: period,
        riskTrend: riskTrend,
        rainfallTrend: rainfallTrend,
        temperatureTrend: temperatureTrend,
        ndviTrend: ndviTrend,
      );
    }

    return TemporalTrendModel(
      period: period,
      riskTrend: parseTrend(json['riskTrend']),
      rainfallTrend: parseTrend(json['rainfallTrend']),
      temperatureTrend: parseTrend(json['temperatureTrend']),
      ndviTrend: parseTrend(json['ndviTrend']),
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'riskTrend': riskTrend.map((t) => t.toJson()).toList(),
    'rainfallTrend': rainfallTrend.map((t) => t.toJson()).toList(),
    'temperatureTrend': temperatureTrend.map((t) => t.toJson()).toList(),
    'ndviTrend': ndviTrend.map((t) => t.toJson()).toList(),
  };
}

class TrendDataPoint {
  final String date;
  final double value;
  final String? label;

  const TrendDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: (json['date'] ?? '').toString(),
      value: ((json['value'] ?? 0.0) as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'value': value,
    if (label != null) 'label': label,
  };
}
