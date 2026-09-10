
/// 1. Weed Models
class KnapsackPlanModel {
  final double areaHectares;
  final int sprayVolumeHa;
  final int knapsackVolumeLiters;
  final int totalKnapsacksNeeded;
  final double totalChemicalNeeded;
  final double chemicalPerKnapsack;
  final String unit;
  final String dosagePer16LTank;

  const KnapsackPlanModel({
    required this.areaHectares,
    required this.sprayVolumeHa,
    required this.knapsackVolumeLiters,
    required this.totalKnapsacksNeeded,
    required this.totalChemicalNeeded,
    required this.chemicalPerKnapsack,
    required this.unit,
    required this.dosagePer16LTank,
  });

  factory KnapsackPlanModel.fromJson(Map<String, dynamic> json) {
    return KnapsackPlanModel(
      areaHectares: (json['areaHectares'] as num?)?.toDouble() ?? 1.0,
      sprayVolumeHa: (json['sprayVolumeHa'] as num?)?.toInt() ?? 200,
      knapsackVolumeLiters: (json['knapsackVolumeLiters'] as num?)?.toInt() ?? 16,
      totalKnapsacksNeeded: (json['totalKnapsacksNeeded'] as num?)?.toInt() ?? 13,
      totalChemicalNeeded: (json['totalChemicalNeeded'] as num?)?.toDouble() ?? 1.0,
      chemicalPerKnapsack: (json['chemicalPerKnapsack'] as num?)?.toDouble() ?? 0.08,
      unit: json['unit'] as String? ?? 'Liters',
      dosagePer16LTank: json['dosagePer16LTank'] as String? ?? '80 mL per 16L knapsack',
    );
  }
}

class HerbicideModel {
  final String tradeName;
  final String activeIngredient;
  final String chemicalFamily;
  final List<String> selectiveFor;
  final String ratePerHectare;
  final String ratePer16LKnapsack;
  final String timing;
  final int phiDays;
  final int rainfastnessHours;
  final List<String> ppeRequired;
  final String? notesEn;
  final String? notesAm;

  const HerbicideModel({
    required this.tradeName,
    required this.activeIngredient,
    required this.chemicalFamily,
    required this.selectiveFor,
    required this.ratePerHectare,
    required this.ratePer16LKnapsack,
    required this.timing,
    required this.phiDays,
    required this.rainfastnessHours,
    required this.ppeRequired,
    this.notesEn,
    this.notesAm,
  });

  factory HerbicideModel.fromJson(Map<String, dynamic> json) {
    return HerbicideModel(
      tradeName: json['tradeName'] as String? ?? '',
      activeIngredient: json['activeIngredient'] as String? ?? '',
      chemicalFamily: json['chemicalFamily'] as String? ?? '',
      selectiveFor: (json['selectiveFor'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ratePerHectare: json['ratePerHectare'] as String? ?? '',
      ratePer16LKnapsack: json['ratePer16LKnapsack'] as String? ?? '',
      timing: json['timing'] as String? ?? '',
      phiDays: (json['phiDays'] as num?)?.toInt() ?? 14,
      rainfastnessHours: (json['rainfastnessHours'] as num?)?.toInt() ?? 3,
      ppeRequired: (json['ppeRequired'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notesEn: json['notesEn'] as String?,
      notesAm: json['notesAm'] as String?,
    );
  }
}

class CulturalControlModel {
  final String method;
  final String instructionsEn;
  final String instructionsAm;

  const CulturalControlModel({
    required this.method,
    required this.instructionsEn,
    required this.instructionsAm,
  });

  factory CulturalControlModel.fromJson(Map<String, dynamic> json) {
    return CulturalControlModel(
      method: json['method'] as String? ?? '',
      instructionsEn: json['instructionsEn'] as String? ?? '',
      instructionsAm: json['instructionsAm'] as String? ?? '',
    );
  }
}

class WeedModel {
  final String id;
  final String scientificName;
  final String commonNameEn;
  final String commonNameAm;
  final String? commonNameOm;
  final String weedType;
  final String lifecycle;
  final String invasiveSeverity;
  final String descriptionEn;
  final String descriptionAm;
  final List<String> identificationKeys;
  final List<HerbicideModel> herbicides;
  final List<CulturalControlModel> culturalControls;

  const WeedModel({
    required this.id,
    required this.scientificName,
    required this.commonNameEn,
    required this.commonNameAm,
    this.commonNameOm,
    required this.weedType,
    required this.lifecycle,
    required this.invasiveSeverity,
    required this.descriptionEn,
    required this.descriptionAm,
    required this.identificationKeys,
    this.herbicides = const [],
    this.culturalControls = const [],
  });

  factory WeedModel.fromJson(Map<String, dynamic> json) {
    return WeedModel(
      id: json['id'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      commonNameEn: json['commonNameEn'] as String? ?? '',
      commonNameAm: json['commonNameAm'] as String? ?? '',
      commonNameOm: json['commonNameOm'] as String?,
      weedType: json['weedType'] as String? ?? 'Broadleaf',
      lifecycle: json['lifecycle'] as String? ?? 'Annual',
      invasiveSeverity: json['invasiveSeverity'] as String? ?? 'MODERATE',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionAm: json['descriptionAm'] as String? ?? '',
      identificationKeys: (json['identificationKeys'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      herbicides: (json['herbicides'] as List<dynamic>?)?.map((e) => HerbicideModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      culturalControls: (json['culturalControls'] as List<dynamic>?)?.map((e) => CulturalControlModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class WeedDetectionResult {
  final bool success;
  final String detectionType;
  final double aiConfidence;
  final WeedModel weed;
  final String infestingCrop;
  final double fieldAreaHectares;
  final List<HerbicideModel> recommendedHerbicides;
  final KnapsackPlanModel calibratedKnapsackSprayerPlan;
  final List<CulturalControlModel> culturalControls;
  final String safetyAdvisoryEn;
  final String safetyAdvisoryAm;

  const WeedDetectionResult({
    required this.success,
    required this.detectionType,
    required this.aiConfidence,
    required this.weed,
    required this.infestingCrop,
    required this.fieldAreaHectares,
    required this.recommendedHerbicides,
    required this.calibratedKnapsackSprayerPlan,
    required this.culturalControls,
    required this.safetyAdvisoryEn,
    required this.safetyAdvisoryAm,
  });

  factory WeedDetectionResult.fromJson(Map<String, dynamic> json) {
    return WeedDetectionResult(
      success: json['success'] as bool? ?? false,
      detectionType: json['detectionType'] as String? ?? 'AGRONOMIC_REGISTRY_MATCH',
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble() ?? 0.9,
      weed: WeedModel.fromJson(json['weed'] as Map<String, dynamic>? ?? {}),
      infestingCrop: json['infestingCrop'] as String? ?? 'Wheat',
      fieldAreaHectares: (json['fieldAreaHectares'] as num?)?.toDouble() ?? 1.0,
      recommendedHerbicides: (json['recommendedHerbicides'] as List<dynamic>?)
              ?.map((e) => HerbicideModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      calibratedKnapsackSprayerPlan: KnapsackPlanModel.fromJson(
          json['calibratedKnapsackSprayerPlan'] as Map<String, dynamic>? ?? {}),
      culturalControls: (json['culturalControls'] as List<dynamic>?)
              ?.map((e) => CulturalControlModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      safetyAdvisoryEn: json['safetyAdvisoryEn'] as String? ?? '',
      safetyAdvisoryAm: json['safetyAdvisoryAm'] as String? ?? '',
    );
  }
}

/// 2. Spray Window Models
class HourlySprayAdvisory {
  final String time;
  final String hourLabel;
  final double windSpeedKmh;
  final double temperatureC;
  final double relativeHumidity;
  final int rainProbabilityPercent;
  final String suitability; // OPTIMAL, CAUTION, UNSUITABLE
  final String reasonEn;
  final String reasonAm;

  const HourlySprayAdvisory({
    required this.time,
    required this.hourLabel,
    required this.windSpeedKmh,
    required this.temperatureC,
    required this.relativeHumidity,
    required this.rainProbabilityPercent,
    required this.suitability,
    required this.reasonEn,
    required this.reasonAm,
  });

  factory HourlySprayAdvisory.fromJson(Map<String, dynamic> json) {
    return HourlySprayAdvisory(
      time: json['time'] as String? ?? '',
      hourLabel: json['hourLabel'] as String? ?? '',
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 10.0,
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 20.0,
      relativeHumidity: (json['relativeHumidity'] as num?)?.toDouble() ?? 50.0,
      rainProbabilityPercent: (json['rainProbabilityPercent'] as num?)?.toInt() ?? 0,
      suitability: json['suitability'] as String? ?? 'OPTIMAL',
      reasonEn: json['reasonEn'] as String? ?? '',
      reasonAm: json['reasonAm'] as String? ?? '',
    );
  }
}

class CurrentSprayConditions {
  final double temperatureC;
  final double windSpeedKmh;
  final double relativeHumidity;
  final double precipitationMm;
  final String status; // OPTIMAL_TO_SPRAY, SPRAY_WITH_CAUTION, DO_NOT_SPRAY
  final List<String> riskFactorsEn;
  final List<String> riskFactorsAm;

  const CurrentSprayConditions({
    required this.temperatureC,
    required this.windSpeedKmh,
    required this.relativeHumidity,
    required this.precipitationMm,
    required this.status,
    required this.riskFactorsEn,
    required this.riskFactorsAm,
  });

  factory CurrentSprayConditions.fromJson(Map<String, dynamic> json) {
    return CurrentSprayConditions(
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 20.0,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 10.0,
      relativeHumidity: (json['relativeHumidity'] as num?)?.toDouble() ?? 60.0,
      precipitationMm: (json['precipitationMm'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'OPTIMAL_TO_SPRAY',
      riskFactorsEn: (json['riskFactorsEn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      riskFactorsAm: (json['riskFactorsAm'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class SprayWindowData {
  final CurrentSprayConditions currentConditions;
  final String bestWindowRecommendation;
  final String rainfastnessAdvisoryEn;
  final String rainfastnessAdvisoryAm;
  final List<HourlySprayAdvisory> next12HoursAdvisory;

  const SprayWindowData({
    required this.currentConditions,
    required this.bestWindowRecommendation,
    required this.rainfastnessAdvisoryEn,
    required this.rainfastnessAdvisoryAm,
    required this.next12HoursAdvisory,
  });

  factory SprayWindowData.fromJson(Map<String, dynamic> json) {
    return SprayWindowData(
      currentConditions: CurrentSprayConditions.fromJson(
          json['currentConditions'] as Map<String, dynamic>? ?? {}),
      bestWindowRecommendation: json['bestWindowRecommendation'] as String? ?? '',
      rainfastnessAdvisoryEn: json['rainfastnessAdvisoryEn'] as String? ?? '',
      rainfastnessAdvisoryAm: json['rainfastnessAdvisoryAm'] as String? ?? '',
      next12HoursAdvisory: (json['next12HoursAdvisory'] as List<dynamic>?)
              ?.map((e) => HourlySprayAdvisory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 3. Nutrient Models
class DeficiencyCorrectionModel {
  final String fertilizerName;
  final String fertilizerNameAm;
  final String applicationType;
  final String ratePerHectare;
  final String knapsackFoliarRescue;
  final String timingEn;
  final String timingAm;

  const DeficiencyCorrectionModel({
    required this.fertilizerName,
    required this.fertilizerNameAm,
    required this.applicationType,
    required this.ratePerHectare,
    required this.knapsackFoliarRescue,
    required this.timingEn,
    required this.timingAm,
  });

  factory DeficiencyCorrectionModel.fromJson(Map<String, dynamic> json) {
    return DeficiencyCorrectionModel(
      fertilizerName: json['fertilizerName'] as String? ?? '',
      fertilizerNameAm: json['fertilizerNameAm'] as String? ?? '',
      applicationType: json['applicationType'] as String? ?? '',
      ratePerHectare: json['ratePerHectare'] as String? ?? '',
      knapsackFoliarRescue: json['knapsackFoliarRescue'] as String? ?? '',
      timingEn: json['timingEn'] as String? ?? '',
      timingAm: json['timingAm'] as String? ?? '',
    );
  }
}

class NutrientDeficiencyModel {
  final String id;
  final String nutrient;
  final String nutrientNameAm;
  final String affectedLeaves;
  final String symptomPattern;
  final String visualDescriptionEn;
  final String visualDescriptionAm;
  final String causesEn;
  final String causesAm;
  final DeficiencyCorrectionModel? correction;

  const NutrientDeficiencyModel({
    required this.id,
    required this.nutrient,
    required this.nutrientNameAm,
    required this.affectedLeaves,
    required this.symptomPattern,
    required this.visualDescriptionEn,
    required this.visualDescriptionAm,
    required this.causesEn,
    required this.causesAm,
    this.correction,
  });

  factory NutrientDeficiencyModel.fromJson(Map<String, dynamic> json) {
    return NutrientDeficiencyModel(
      id: json['id'] as String? ?? '',
      nutrient: json['nutrient'] as String? ?? '',
      nutrientNameAm: json['nutrientNameAm'] as String? ?? '',
      affectedLeaves: json['affectedLeaves'] as String? ?? '',
      symptomPattern: json['symptomPattern'] as String? ?? '',
      visualDescriptionEn: json['visualDescriptionEn'] as String? ?? '',
      visualDescriptionAm: json['visualDescriptionAm'] as String? ?? '',
      causesEn: json['causesEn'] as String? ?? '',
      causesAm: json['causesAm'] as String? ?? '',
      correction: json['correction'] != null
          ? DeficiencyCorrectionModel.fromJson(json['correction'] as Map<String, dynamic>)
          : null,
    );
  }
}

class NutrientDeficiencyResult {
  final bool success;
  final String scanType;
  final double confidenceScore;
  final String cropType;
  final NutrientDeficiencyModel diagnosedDeficiency;
  final DeficiencyCorrectionModel correctiveAction;
  final String applicationSummaryEn;
  final String applicationSummaryAm;

  const NutrientDeficiencyResult({
    required this.success,
    required this.scanType,
    required this.confidenceScore,
    required this.cropType,
    required this.diagnosedDeficiency,
    required this.correctiveAction,
    required this.applicationSummaryEn,
    required this.applicationSummaryAm,
  });

  factory NutrientDeficiencyResult.fromJson(Map<String, dynamic> json) {
    return NutrientDeficiencyResult(
      success: json['success'] as bool? ?? false,
      scanType: json['scanType'] as String? ?? 'AGRONOMIC_LEAF_SYMPTOM_ANALYSIS',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.9,
      cropType: json['cropType'] as String? ?? 'Maize',
      diagnosedDeficiency: NutrientDeficiencyModel.fromJson(
          json['diagnosedDeficiency'] as Map<String, dynamic>? ?? {}),
      correctiveAction: DeficiencyCorrectionModel.fromJson(
          json['correctiveAction'] as Map<String, dynamic>? ?? {}),
      applicationSummaryEn: json['applicationSummaryEn'] as String? ?? '',
      applicationSummaryAm: json['applicationSummaryAm'] as String? ?? '',
    );
  }
}

/// 4. Pest Models
class PesticideModel {
  final String tradeName;
  final String activeIngredient;
  final String type;
  final String ratePerHa;
  final String ratePer16LKnapsack;
  final String timing;
  final int phiDays;
  final int rainfastnessHours;
  final List<String> ppeRequired;

  const PesticideModel({
    required this.tradeName,
    required this.activeIngredient,
    required this.type,
    required this.ratePerHa,
    required this.ratePer16LKnapsack,
    required this.timing,
    required this.phiDays,
    required this.rainfastnessHours,
    required this.ppeRequired,
  });

  factory PesticideModel.fromJson(Map<String, dynamic> json) {
    return PesticideModel(
      tradeName: json['tradeName'] as String? ?? '',
      activeIngredient: json['activeIngredient'] as String? ?? '',
      type: json['type'] as String? ?? '',
      ratePerHa: json['ratePerHa'] as String? ?? '',
      ratePer16LKnapsack: json['ratePer16LKnapsack'] as String? ?? '',
      timing: json['timing'] as String? ?? '',
      phiDays: (json['phiDays'] as num?)?.toInt() ?? 14,
      rainfastnessHours: (json['rainfastnessHours'] as num?)?.toInt() ?? 2,
      ppeRequired: (json['ppeRequired'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class BiocontrolModel {
  final String method;
  final String descriptionEn;
  final String descriptionAm;

  const BiocontrolModel({
    required this.method,
    required this.descriptionEn,
    required this.descriptionAm,
  });

  factory BiocontrolModel.fromJson(Map<String, dynamic> json) {
    return BiocontrolModel(
      method: json['method'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionAm: json['descriptionAm'] as String? ?? '',
    );
  }
}

class PestModel {
  final String id;
  final String scientificName;
  final String commonNameEn;
  final String commonNameAm;
  final String? commonNameOm;
  final String pestType;
  final List<String> targetCrops;
  final List<String> identificationKeys;
  final List<PesticideModel> pesticides;
  final List<BiocontrolModel> culturalAndBiocontrol;

  const PestModel({
    required this.id,
    required this.scientificName,
    required this.commonNameEn,
    required this.commonNameAm,
    this.commonNameOm,
    required this.pestType,
    required this.targetCrops,
    required this.identificationKeys,
    this.pesticides = const [],
    this.culturalAndBiocontrol = const [],
  });

  factory PestModel.fromJson(Map<String, dynamic> json) {
    return PestModel(
      id: json['id'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      commonNameEn: json['commonNameEn'] as String? ?? '',
      commonNameAm: json['commonNameAm'] as String? ?? '',
      commonNameOm: json['commonNameOm'] as String?,
      pestType: json['pestType'] as String? ?? '',
      targetCrops: (json['targetCrops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      identificationKeys: (json['identificationKeys'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pesticides: (json['pesticides'] as List<dynamic>?)
              ?.map((e) => PesticideModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      culturalAndBiocontrol: (json['culturalAndBiocontrol'] as List<dynamic>?)
              ?.map((e) => BiocontrolModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EtlRecommendationModel {
  final String action; // TREAT_NOW, MONITOR_CLOSELY, NO_ACTION
  final String urgency;
  final String en;
  final String am;

  const EtlRecommendationModel({
    required this.action,
    required this.urgency,
    required this.en,
    required this.am,
  });

  factory EtlRecommendationModel.fromJson(Map<String, dynamic> json) {
    return EtlRecommendationModel(
      action: json['action'] as String? ?? 'MONITOR_CLOSELY',
      urgency: json['urgency'] as String? ?? 'ROUTINE',
      en: json['en'] as String? ?? '',
      am: json['am'] as String? ?? '',
    );
  }
}

class EtlEvaluationModel {
  final String pestId;
  final String scientificName;
  final String commonNameEn;
  final String commonNameAm;
  final String cropStage;
  final double observedDamagePercent;
  final double thresholdPercent;
  final String severityLevel;
  final bool isAboveETL;
  final EtlRecommendationModel recommendation;
  final List<PesticideModel> firstLinePesticides;
  final List<BiocontrolModel> culturalControls;

  const EtlEvaluationModel({
    required this.pestId,
    required this.scientificName,
    required this.commonNameEn,
    required this.commonNameAm,
    required this.cropStage,
    required this.observedDamagePercent,
    required this.thresholdPercent,
    required this.severityLevel,
    required this.isAboveETL,
    required this.recommendation,
    required this.firstLinePesticides,
    required this.culturalControls,
  });

  factory EtlEvaluationModel.fromJson(Map<String, dynamic> json) {
    return EtlEvaluationModel(
      pestId: json['pestId'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      commonNameEn: json['commonNameEn'] as String? ?? '',
      commonNameAm: json['commonNameAm'] as String? ?? '',
      cropStage: json['cropStage'] as String? ?? '',
      observedDamagePercent: (json['observedDamagePercent'] as num?)?.toDouble() ?? 0.0,
      thresholdPercent: (json['thresholdPercent'] as num?)?.toDouble() ?? 20.0,
      severityLevel: json['severityLevel'] as String? ?? 'NORMAL',
      isAboveETL: json['isAboveETL'] as bool? ?? false,
      recommendation: EtlRecommendationModel.fromJson(
          json['recommendation'] as Map<String, dynamic>? ?? {}),
      firstLinePesticides: (json['firstLinePesticides'] as List<dynamic>?)
              ?.map((e) => PesticideModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      culturalControls: (json['culturalControls'] as List<dynamic>?)
              ?.map((e) => BiocontrolModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PestScoutResult {
  final bool success;
  final String scoutMethod;
  final double aiConfidence;
  final String cropType;
  final EtlEvaluationModel economicThresholdEvaluation;

  const PestScoutResult({
    required this.success,
    required this.scoutMethod,
    required this.aiConfidence,
    required this.cropType,
    required this.economicThresholdEvaluation,
  });

  factory PestScoutResult.fromJson(Map<String, dynamic> json) {
    return PestScoutResult(
      success: json['success'] as bool? ?? false,
      scoutMethod: json['scoutMethod'] as String? ?? 'MANUAL_FIELD_SCOUT_ETL',
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble() ?? 0.9,
      cropType: json['cropType'] as String? ?? 'Maize',
      economicThresholdEvaluation: EtlEvaluationModel.fromJson(
          json['economicThresholdEvaluation'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// 5. Tank Mix Models
class AgrochemicalModel {
  final String id;
  final String name;
  final String type;
  final String formulation;
  final String family;
  final String phRange;

  const AgrochemicalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.formulation,
    required this.family,
    required this.phRange,
  });

  factory AgrochemicalModel.fromJson(Map<String, dynamic> json) {
    return AgrochemicalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      formulation: json['formulation'] as String? ?? '',
      family: json['family'] as String? ?? '',
      phRange: json['phRange'] as String? ?? '',
    );
  }
}

class MixingStepModel {
  final int stepNumber;
  final String code;
  final String titleEn;
  final String titleAm;
  final String detailEn;
  final String detailAm;

  const MixingStepModel({
    required this.stepNumber,
    required this.code,
    required this.titleEn,
    required this.titleAm,
    required this.detailEn,
    required this.detailAm,
  });

  factory MixingStepModel.fromJson(Map<String, dynamic> json) {
    return MixingStepModel(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      code: json['code'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      titleAm: json['titleAm'] as String? ?? '',
      detailEn: json['detailEn'] as String? ?? '',
      detailAm: json['detailAm'] as String? ?? '',
    );
  }
}

class JarTestModel {
  final String titleEn;
  final String titleAm;
  final List<String> instructionsEn;
  final List<String> instructionsAm;

  const JarTestModel({
    required this.titleEn,
    required this.titleAm,
    required this.instructionsEn,
    required this.instructionsAm,
  });

  factory JarTestModel.fromJson(Map<String, dynamic> json) {
    return JarTestModel(
      titleEn: json['titleEn'] as String? ?? '',
      titleAm: json['titleAm'] as String? ?? '',
      instructionsEn: (json['instructionsEn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      instructionsAm: (json['instructionsAm'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class ConflictModel {
  final String productA;
  final String productB;
  final String riskLevel;
  final String issueEn;
  final String issueAm;
  final String actionEn;
  final String actionAm;

  const ConflictModel({
    required this.productA,
    required this.productB,
    required this.riskLevel,
    required this.issueEn,
    required this.issueAm,
    required this.actionEn,
    required this.actionAm,
  });

  factory ConflictModel.fromJson(Map<String, dynamic> json) {
    return ConflictModel(
      productA: json['productA'] as String? ?? '',
      productB: json['productB'] as String? ?? '',
      riskLevel: json['riskLevel'] as String? ?? 'CAUTION',
      issueEn: json['issueEn'] as String? ?? '',
      issueAm: json['issueAm'] as String? ?? '',
      actionEn: json['actionEn'] as String? ?? '',
      actionAm: json['actionAm'] as String? ?? '',
    );
  }
}

class TankMixValidationResult {
  final bool isValid;
  final String riskLevel; // SAFE, CAUTION, INCOMPATIBLE
  final bool hasConflicts;
  final List<ConflictModel> conflicts;
  final List<MixingStepModel> mixingSequence;
  final JarTestModel? jarTestProcedure;

  const TankMixValidationResult({
    required this.isValid,
    required this.riskLevel,
    required this.hasConflicts,
    required this.conflicts,
    required this.mixingSequence,
    this.jarTestProcedure,
  });

  factory TankMixValidationResult.fromJson(Map<String, dynamic> json) {
    return TankMixValidationResult(
      isValid: json['isValid'] as bool? ?? true,
      riskLevel: json['riskLevel'] as String? ?? 'SAFE',
      hasConflicts: json['hasConflicts'] as bool? ?? false,
      conflicts: (json['conflicts'] as List<dynamic>?)
              ?.map((e) => ConflictModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mixingSequence: (json['mixingSequence'] as List<dynamic>?)
              ?.map((e) => MixingStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jarTestProcedure: json['jarTestProcedure'] != null
          ? JarTestModel.fromJson(json['jarTestProcedure'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 6. Seed Calculator Models
class CropAgronomyModel {
  final String cropId;
  final String cropNameEn;
  final String cropNameAm;
  final List<String> recommendedVarieties;

  const CropAgronomyModel({
    required this.cropId,
    required this.cropNameEn,
    required this.cropNameAm,
    required this.recommendedVarieties,
  });

  factory CropAgronomyModel.fromJson(Map<String, dynamic> json) {
    return CropAgronomyModel(
      cropId: json['cropId'] as String? ?? '',
      cropNameEn: json['cropNameEn'] as String? ?? '',
      cropNameAm: json['cropNameAm'] as String? ?? '',
      recommendedVarieties: (json['recommendedVarieties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class SeedPlanModel {
  final double ratePerHaKg;
  final double totalSeedRequiredKg;
  final String bags50kg;
  final String plantingDepth;
  final int? rowSpacingCm;
  final int? plantSpacingCm;
  final int? estimatedTotalPlants;

  const SeedPlanModel({
    required this.ratePerHaKg,
    required this.totalSeedRequiredKg,
    required this.bags50kg,
    required this.plantingDepth,
    this.rowSpacingCm,
    this.plantSpacingCm,
    this.estimatedTotalPlants,
  });

  factory SeedPlanModel.fromJson(Map<String, dynamic> json) {
    final geom = json['geometry'] as Map<String, dynamic>?;
    return SeedPlanModel(
      ratePerHaKg: (json['ratePerHaKg'] as num?)?.toDouble() ?? 10.0,
      totalSeedRequiredKg: (json['totalSeedRequiredKg'] as num?)?.toDouble() ?? 10.0,
      bags50kg: json['bags50kg']?.toString() ?? '0.2',
      plantingDepth: json['plantingDepth'] as String? ?? '',
      rowSpacingCm: (geom?['rowSpacingCm'] as num?)?.toInt(),
      plantSpacingCm: (geom?['plantSpacingCm'] as num?)?.toInt(),
      estimatedTotalPlants: (geom?['estimatedTotalPlants'] as num?)?.toInt(),
    );
  }
}

class FertilizerDoseModel {
  final String product;
  final double ratePerHaKg;
  final double totalRequiredKg;
  final String bags50kg;
  final String timingEn;
  final String timingAm;

  const FertilizerDoseModel({
    required this.product,
    required this.ratePerHaKg,
    required this.totalRequiredKg,
    required this.bags50kg,
    required this.timingEn,
    required this.timingAm,
  });

  factory FertilizerDoseModel.fromJson(Map<String, dynamic> json) {
    return FertilizerDoseModel(
      product: json['product'] as String? ?? '',
      ratePerHaKg: (json['ratePerHaKg'] as num?)?.toDouble() ?? 100.0,
      totalRequiredKg: (json['totalRequiredKg'] as num?)?.toDouble() ?? 100.0,
      bags50kg: json['bags50kg']?.toString() ?? '2.0',
      timingEn: json['timingEn'] as String? ?? '',
      timingAm: json['timingAm'] as String? ?? '',
    );
  }
}

class FertilizerPlanModel {
  final FertilizerDoseModel basalNpsb;
  final FertilizerDoseModel topDressUrea;

  const FertilizerPlanModel({
    required this.basalNpsb,
    required this.topDressUrea,
  });

  factory FertilizerPlanModel.fromJson(Map<String, dynamic> json) {
    return FertilizerPlanModel(
      basalNpsb: FertilizerDoseModel.fromJson(json['basalNpsb'] as Map<String, dynamic>? ?? {}),
      topDressUrea: FertilizerDoseModel.fromJson(json['topDressUrea'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SeedCalculationResult {
  final CropAgronomyModel crop;
  final double hectaresEquivalent;
  final double timadEquivalent;
  final String plantingMethod;
  final SeedPlanModel seedPlan;
  final FertilizerPlanModel fertilizerPlan;
  final String plantingWindowEn;
  final String plantingWindowAm;
  final String specialInstructionsEn;
  final String specialInstructionsAm;

  const SeedCalculationResult({
    required this.crop,
    required this.hectaresEquivalent,
    required this.timadEquivalent,
    required this.plantingMethod,
    required this.seedPlan,
    required this.fertilizerPlan,
    required this.plantingWindowEn,
    required this.plantingWindowAm,
    required this.specialInstructionsEn,
    required this.specialInstructionsAm,
  });

  factory SeedCalculationResult.fromJson(Map<String, dynamic> json) {
    final inputArea = json['inputArea'] as Map<String, dynamic>? ?? {};
    final advice = json['agronomicAdvice'] as Map<String, dynamic>? ?? {};

    return SeedCalculationResult(
      crop: CropAgronomyModel.fromJson(json['crop'] as Map<String, dynamic>? ?? {}),
      hectaresEquivalent: (inputArea['hectaresEquivalent'] as num?)?.toDouble() ?? 1.0,
      timadEquivalent: (inputArea['timadEquivalent'] as num?)?.toDouble() ?? 4.0,
      plantingMethod: json['plantingMethod'] as String? ?? 'ROW_PLANTING',
      seedPlan: SeedPlanModel.fromJson(json['seedPlan'] as Map<String, dynamic>? ?? {}),
      fertilizerPlan: FertilizerPlanModel.fromJson(json['fertilizerPlan'] as Map<String, dynamic>? ?? {}),
      plantingWindowEn: advice['plantingWindowEn'] as String? ?? '',
      plantingWindowAm: advice['plantingWindowAm'] as String? ?? '',
      specialInstructionsEn: advice['specialInstructionsEn'] as String? ?? '',
      specialInstructionsAm: advice['specialInstructionsAm'] as String? ?? '',
    );
  }
}
