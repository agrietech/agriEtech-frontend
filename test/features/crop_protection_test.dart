import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/features/crop_protection/models/crop_protection_models.dart';

void main() {
  group('Crop Protection & Field Suite Unit Tests', () {
    test('KnapsackPlanModel parses and computes 16L sprayer tanks accurately', () {
      final json = {
        'areaHectares': 2.0,
        'sprayVolumeHa': 200,
        'knapsackVolumeLiters': 16,
        'totalKnapsacksNeeded': 25,
        'totalChemicalNeeded': 2.4,
        'chemicalPerKnapsack': 0.096,
        'unit': 'Liters',
        'dosagePer16LTank': '96 mL per 16L knapsack',
      };

      final plan = KnapsackPlanModel.fromJson(json);

      expect(plan.areaHectares, 2.0);
      expect(plan.totalKnapsacksNeeded, 25);
      expect(plan.totalChemicalNeeded, 2.4);
      expect(plan.dosagePer16LTank, contains('96 mL'));
    });

    test('WeedDetectionResult deserializes Ethiopian weed registry data', () {
      final json = {
        'success': true,
        'detectionType': 'AI_MULTIMODAL_VISION',
        'aiConfidence': 0.95,
        'weed': {
          'id': 'parthenium_hysterophorus',
          'scientificName': 'Parthenium hysterophorus',
          'commonNameEn': 'Parthenium / Famine Weed',
          'commonNameAm': 'ኮንግን',
          'weedType': 'Broadleaf',
          'lifecycle': 'Annual',
          'invasiveSeverity': 'CRITICAL',
          'descriptionEn': 'Invasive weed',
          'descriptionAm': 'አደገኛ አረም',
          'identificationKeys': ['Dissected leaves'],
        },
        'infestingCrop': 'Wheat',
        'fieldAreaHectares': 1.5,
        'recommendedHerbicides': [
          {
            'tradeName': '2,4-D Amine 720 SL',
            'activeIngredient': '2,4-D Dimethylamine salt 720 g/L',
            'chemicalFamily': 'Synthetic Auxin',
            'selectiveFor': ['Wheat', 'Teff'],
            'ratePerHectare': '1.2 L/ha',
            'ratePer16LKnapsack': '75 mL',
            'timing': 'Apply at tillering',
            'phiDays': 14,
            'rainfastnessHours': 3,
            'ppeRequired': ['Gloves', 'Mask'],
          }
        ],
        'calibratedKnapsackSprayerPlan': {
          'areaHectares': 1.5,
          'totalKnapsacksNeeded': 19,
          'totalChemicalNeeded': 1.8,
          'dosagePer16LTank': '75 mL per 16L knapsack',
        },
        'culturalControls': [
          {
            'method': 'Stale Seedbed',
            'instructionsEn': 'Plow early',
            'instructionsAm': 'በጊዜ ማረስ',
          }
        ],
        'safetyAdvisoryEn': 'Wear gloves',
        'safetyAdvisoryAm': 'ጓንት ያድርጉ',
      };

      final result = WeedDetectionResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.weed.scientificName, 'Parthenium hysterophorus');
      expect(result.weed.commonNameAm, 'ኮንግን');
      expect(result.recommendedHerbicides.first.tradeName, '2,4-D Amine 720 SL');
      expect(result.calibratedKnapsackSprayerPlan.totalKnapsacksNeeded, 19);
    });

    test('SprayWindowData parses hourly advisory and flags drift risks', () {
      final json = {
        'currentConditions': {
          'temperatureC': 21.5,
          'windSpeedKmh': 8.5,
          'relativeHumidity': 58.0,
          'precipitationMm': 0.0,
          'status': 'OPTIMAL_TO_SPRAY',
          'riskFactorsEn': ['Safe conditions'],
          'riskFactorsAm': ['ምቹ ሁኔታ'],
        },
        'bestWindowRecommendation': 'Best window: 06:00 to 09:00',
        'rainfastnessAdvisoryEn': 'Allow 2 to 4 hours rain-free',
        'rainfastnessAdvisoryAm': 'ከ2-4 ሰዓት ዝናብ አለመኖሩን ያረጋግጡ',
        'next12HoursAdvisory': [
          {
            'time': '2026-09-10T06:00',
            'hourLabel': '06:00',
            'windSpeedKmh': 7.2,
            'temperatureC': 18.0,
            'relativeHumidity': 65.0,
            'rainProbabilityPercent': 5,
            'suitability': 'OPTIMAL',
            'reasonEn': 'Gentle breeze and cool temperature',
            'reasonAm': 'ተስማሚ ሰዓት',
          },
          {
            'time': '2026-09-10T12:00',
            'hourLabel': '12:00',
            'windSpeedKmh': 16.5,
            'temperatureC': 29.0,
            'relativeHumidity': 35.0,
            'rainProbabilityPercent': 10,
            'suitability': 'UNSUITABLE',
            'reasonEn': 'Excessive wind (16.5 km/h) & thermal scorch',
            'reasonAm': 'ከፍተኛ ንፋስና ሙቀት',
          }
        ],
      };

      final sprayData = SprayWindowData.fromJson(json);

      expect(sprayData.currentConditions.status, 'OPTIMAL_TO_SPRAY');
      expect(sprayData.next12HoursAdvisory.length, 2);
      expect(sprayData.next12HoursAdvisory.first.suitability, 'OPTIMAL');
      expect(sprayData.next12HoursAdvisory.last.suitability, 'UNSUITABLE');
      expect(sprayData.next12HoursAdvisory.last.windSpeedKmh, 16.5);
    });

    test('NutrientDeficiencyResult parses chlorosis and top-dressing dosage', () {
      final json = {
        'success': true,
        'scanType': 'AI_MULTIMODAL_LEAF_SCAN',
        'confidenceScore': 0.93,
        'cropType': 'Maize',
        'diagnosedDeficiency': {
          'id': 'nitrogen_deficiency',
          'nutrient': 'Nitrogen (N)',
          'nutrientNameAm': 'ናይትሮጅን (N)',
          'affectedLeaves': 'Older / Lower Leaves first',
          'symptomPattern': 'V-shaped chlorosis',
          'visualDescriptionEn': 'V-shaped yellowing along midrib',
          'visualDescriptionAm': 'በመሃል አጥንት በኩል ቢጫ መሆን',
          'causesEn': 'Waterlogging, leaching',
          'causesAm': 'የውሃ መተኛት',
        },
        'correctiveAction': {
          'fertilizerName': 'Urea (46% N)',
          'fertilizerNameAm': 'ዩሪያ',
          'applicationType': 'Top-dressing',
          'ratePerHectare': '50 - 100 kg/ha',
          'knapsackFoliarRescue': '250 g Urea per 16L knapsack',
          'timingEn': 'At tillering/knee-high',
          'timingAm': 'በልምላሜ ወቅት',
        },
        'applicationSummaryEn': 'Apply Urea top-dressing',
        'applicationSummaryAm': 'የዩሪያ ማዳበሪያ ይስጡ',
      };

      final nutResult = NutrientDeficiencyResult.fromJson(json);

      expect(nutResult.diagnosedDeficiency.nutrient, 'Nitrogen (N)');
      expect(nutResult.diagnosedDeficiency.nutrientNameAm, 'ናይትሮጅን (N)');
      expect(nutResult.correctiveAction.knapsackFoliarRescue, contains('250 g Urea'));
    });

    test('PestScoutResult parses Economic Threshold Level (ETL) evaluations', () {
      final json = {
        'success': true,
        'scoutMethod': 'MANUAL_FIELD_SCOUT_ETL',
        'aiConfidence': 0.94,
        'cropType': 'Maize',
        'economicThresholdEvaluation': {
          'pestId': 'fall_armyworm',
          'scientificName': 'Spodoptera frugiperda',
          'commonNameEn': 'Fall Armyworm',
          'commonNameAm': 'ተምች',
          'cropStage': 'seedling',
          'observedDamagePercent': 28.0,
          'thresholdPercent': 20.0,
          'severityLevel': 'ECONOMIC_THRESHOLD_EXCEEDED',
          'isAboveETL': true,
          'recommendation': {
            'action': 'TREAT_NOW',
            'urgency': 'HIGH_PRIORITY_SPRAY',
            'en': 'Damage is above 20% ETL threshold. Chemical treatment is justified.',
            'am': 'ጉዳቱ ከ20% ወሰን በላይ ስለሆነ ርጭት ያስፈልጋል።',
          },
          'firstLinePesticides': [
            {
              'tradeName': 'Ampligo 150 ZC',
              'activeIngredient': 'Chlorantraniliprole + Lambda-cyhalothrin',
              'type': 'Dual-Action Insecticide',
              'ratePerHa': '0.2 - 0.3 L/ha',
              'ratePer16LKnapsack': '15 - 20 mL',
              'timing': 'Direct into funnel',
              'phiDays': 7,
              'rainfastnessHours': 2,
              'ppeRequired': ['Gloves', 'Mask'],
            }
          ],
          'culturalControls': [
            {
              'method': 'Ash and sand in whorl',
              'descriptionEn': 'Add pinch of ash',
              'descriptionAm': 'አመድና አሸዋ መጨመር',
            }
          ]
        }
      };

      final pestResult = PestScoutResult.fromJson(json);

      expect(pestResult.economicThresholdEvaluation.isAboveETL, isTrue);
      expect(pestResult.economicThresholdEvaluation.recommendation.action, 'TREAT_NOW');
      expect(pestResult.economicThresholdEvaluation.firstLinePesticides.first.tradeName, 'Ampligo 150 ZC');
    });

    test('TankMixValidationResult parses W-A-L-E-S sequence & detects chemical curdling', () {
      final json = {
        'isValid': false,
        'riskLevel': 'INCOMPATIBLE',
        'hasConflicts': true,
        'conflicts': [
          {
            'productA': '2,4-D Amine 720 SL',
            'productB': 'Copper Hydroxide WP',
            'riskLevel': 'INCOMPATIBLE',
            'issueEn': 'Precipitates into curdled sludge, blocking nozzles',
            'issueAm': 'የረጋ ፈሳሽ ይፈጥራል',
            'actionEn': 'Do not mix',
            'actionAm:': 'አይቀላቅሉ',
          }
        ],
        'mixingSequence': [
          {
            'stepNumber': 1,
            'code': 'START',
            'titleEn': 'Fill tank half full with clean water',
            'titleAm': 'ታንኩን በግማሽ ውሃ ይሙሉ',
            'detailEn': 'Add 8 Liters of clean water',
            'detailAm': '8 ሊትር ንጹህ ውሃ ይጨምሩ',
          },
          {
            'stepNumber': 2,
            'code': 'WP',
            'titleEn': 'Add Copper Hydroxide (Wettable Powder)',
            'titleAm': 'ዱቄቱን ይጨምሩ',
            'detailEn': 'Premix and add first',
            'detailAm': 'በደንብ ያማስሉ',
          }
        ],
        'jarTestProcedure': {
          'titleEn': '500 mL Jar Test Protocol',
          'titleAm': 'የጠርሙስ ቅድመ-ሙከራ',
          'instructionsEn': ['Fill jar with 250mL water', 'Check for curdling'],
          'instructionsAm': ['250 ሚሊ ውሃ በጠርሙስ ያድርጉ', 'የመርጋት ምልክት ይዩ'],
        }
      };

      final tankRes = TankMixValidationResult.fromJson(json);

      expect(tankRes.isValid, isFalse);
      expect(tankRes.riskLevel, 'INCOMPATIBLE');
      expect(tankRes.hasConflicts, isTrue);
      expect(tankRes.conflicts.first.productA, contains('2,4-D Amine'));
      expect(tankRes.mixingSequence.length, 2);
    });

    test('SeedCalculationResult converts Timad to Hectares and calculates seed kg', () {
      final json = {
        'crop': {
          'cropId': 'teff',
          'cropNameEn': 'Teff',
          'cropNameAm': 'ጤፍ',
          'recommendedVarieties': ['Quncho', 'Kora'],
        },
        'inputArea': {
          'value': 2.0,
          'unit': 'TIMAD',
          'hectaresEquivalent': 0.5,
          'timadEquivalent': 2.0,
        },
        'plantingMethod': 'ROW_PLANTING',
        'seedPlan': {
          'ratePerHaKg': 5.0,
          'totalSeedRequiredKg': 2.5,
          'bags50kg': '0.1',
          'plantingDepth': '0.5 - 1.0 cm',
          'geometry': {
            'rowSpacingCm': 20,
            'plantSpacingCm': 5,
            'estimatedTotalPlants': 600000,
          }
        },
        'fertilizerPlan': {
          'basalNpsb': {
            'product': 'NPSB',
            'ratePerHaKg': 100.0,
            'totalRequiredKg': 50.0,
            'bags50kg': '1.0',
            'timingEn': 'At planting',
            'timingAm': 'በመዝሪያ ወቅት',
          },
          'topDressUrea': {
            'product': 'Urea',
            'ratePerHaKg': 50.0,
            'totalRequiredKg': 25.0,
            'bags50kg': '0.5',
            'timingEn': 'At tillering',
            'timingAm': 'በልምላሜ ወቅት',
          }
        },
        'agronomicAdvice': {
          'plantingWindowEn': 'July Meher season',
          'plantingWindowAm': 'ሐምሌ',
          'specialInstructionsEn': 'Firm seedbed required',
          'specialInstructionsAm': 'የደቀቀ አፈር ያስፈልጋል',
        }
      };

      final seedRes = SeedCalculationResult.fromJson(json);

      expect(seedRes.crop.cropNameEn, 'Teff');
      expect(seedRes.hectaresEquivalent, 0.5);
      expect(seedRes.seedPlan.totalSeedRequiredKg, 2.5);
      expect(seedRes.seedPlan.rowSpacingCm, 20);
      expect(seedRes.fertilizerPlan.basalNpsb.totalRequiredKg, 50.0);
    });
  });
}
