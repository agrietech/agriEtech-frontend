/// Animal Health & Livestock Disease Surveillance Data Models
class AnimalOutbreakModel {
  final String id;
  final String woredaId;
  final String? woredaName;
  final String? kebele;
  final String diseaseName;
  final String animalType;
  final String severity;
  final int suspectedCases;
  final int confirmedCases;
  final int mortalities;
  final bool quarantineStatus;
  final String status;
  final String? reportedByName;
  final DateTime createdAt;

  const AnimalOutbreakModel({
    required this.id,
    required this.woredaId,
    this.woredaName,
    this.kebele,
    required this.diseaseName,
    required this.animalType,
    required this.severity,
    this.suspectedCases = 0,
    this.confirmedCases = 0,
    this.mortalities = 0,
    this.quarantineStatus = false,
    required this.status,
    this.reportedByName,
    required this.createdAt,
  });

  factory AnimalOutbreakModel.fromJson(Map<String, dynamic> json) {
    return AnimalOutbreakModel(
      id: json['id']?.toString() ?? '',
      woredaId: json['woredaId']?.toString() ?? '',
      woredaName: json['woreda']?['nameEn']?.toString() ?? json['woredaName']?.toString(),
      kebele: json['kebele']?.toString(),
      diseaseName: json['diseaseName']?.toString() ?? 'Unknown Disease',
      animalType: json['animalType']?.toString() ?? 'CATTLE',
      severity: json['severity']?.toString() ?? 'MODERATE',
      suspectedCases: (json['suspectedCases'] as num?)?.toInt() ?? 0,
      confirmedCases: (json['confirmedCases'] as num?)?.toInt() ?? 0,
      mortalities: (json['mortalities'] as num?)?.toInt() ?? 0,
      quarantineStatus: json['quarantineStatus'] == true,
      status: json['status']?.toString() ?? 'ACTIVE',
      reportedByName: json['reportedBy']?['fullName']?.toString() ?? json['reportedByName']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'woredaId': woredaId,
        'woredaName': woredaName,
        'kebele': kebele,
        'diseaseName': diseaseName,
        'animalType': animalType,
        'severity': severity,
        'suspectedCases': suspectedCases,
        'confirmedCases': confirmedCases,
        'mortalities': mortalities,
        'quarantineStatus': quarantineStatus,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}

class VaccinationCampaignModel {
  final String id;
  final String title;
  final String woredaId;
  final List<String> targetSpecies;
  final String diseaseTarget;
  final int targetCount;
  final int vaccinatedCount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const VaccinationCampaignModel({
    required this.id,
    required this.title,
    required this.woredaId,
    required this.targetSpecies,
    required this.diseaseTarget,
    this.targetCount = 0,
    this.vaccinatedCount = 0,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory VaccinationCampaignModel.fromJson(Map<String, dynamic> json) {
    return VaccinationCampaignModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Vaccination Campaign',
      woredaId: json['woredaId']?.toString() ?? '',
      targetSpecies: (json['targetSpecies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Cattle'],
      diseaseTarget: json['diseaseTarget']?.toString() ?? 'Foot & Mouth Disease',
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      vaccinatedCount: (json['vaccinatedCount'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
    );
  }

  double get progressPercentage => targetCount > 0 ? (vaccinatedCount / targetCount).clamp(0.0, 1.0) : 0.0;
}

class PastureConditionModel {
  final String woredaId;
  final String? woredaName;
  final double biomassIndex;
  final String vegetationCondition;
  final String waterAvailability;
  final String droughtImpact;
  final String? grazingPressure;
  final String? recommendedMove;
  final bool droughtStress;
  final DateTime updatedAt;

  const PastureConditionModel({
    required this.woredaId,
    this.woredaName,
    this.biomassIndex = 0.5,
    required this.vegetationCondition,
    required this.waterAvailability,
    required this.droughtImpact,
    this.grazingPressure,
    this.recommendedMove,
    this.droughtStress = false,
    required this.updatedAt,
  });

  factory PastureConditionModel.fromJson(Map<String, dynamic> json) {
    return PastureConditionModel(
      woredaId: json['woredaId']?.toString() ?? '',
      woredaName: json['woredaName']?.toString(),
      biomassIndex: (json['biomassIndex'] as num?)?.toDouble() ?? 0.65,
      vegetationCondition: json['vegetationCondition']?.toString() ?? 'GOOD',
      waterAvailability: json['waterAvailability']?.toString() ?? 'MODERATE',
      droughtImpact: json['droughtImpact']?.toString() ?? 'Favorable pasture biomass across pastoral grazing routes',
      grazingPressure: json['grazingPressure']?.toString() ?? 'MODERATE',
      recommendedMove: json['recommendedMove']?.toString() ?? 'Normal rotational rangeland schedule',
      droughtStress: json['droughtStress'] == true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
