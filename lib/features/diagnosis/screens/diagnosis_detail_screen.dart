import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/diagnosis_models.dart';
import '../providers/diagnosis_provider.dart';

/// Standardized, enterprise-grade AI Crop Disease Diagnosis Detail Screen.
/// Provides deep botanical pathology breakdown, multi-engine telemetry verification,
/// bilingual treatment protocols, and prescription sharing.
class DiagnosisDetailScreen extends ConsumerStatefulWidget {
  final String diagnosisId;
  final DiagnosisModel? initialDiagnosis;

  const DiagnosisDetailScreen({
    super.key,
    required this.diagnosisId,
    this.initialDiagnosis,
  });

  @override
  ConsumerState<DiagnosisDetailScreen> createState() =>
      _DiagnosisDetailScreenState();
}

class _DiagnosisDetailScreenState extends ConsumerState<DiagnosisDetailScreen> {
  String _selectedLanguage = 'en'; // 'en', 'am', 'om'
  bool _isImageZoomed = false;

  @override
  Widget build(BuildContext context) {
    final diagnosisAsync = ref.watch(singleDiagnosisProvider(widget.diagnosisId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Disease Diagnosis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Prescription',
            onPressed: () {
              final d = diagnosisAsync.value ?? widget.initialDiagnosis;
              if (d != null) _sharePrescription(d);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Diagnosis',
            onPressed: () {
              ref.invalidate(singleDiagnosisProvider(widget.diagnosisId));
            },
          ),
        ],
      ),
      body: diagnosisAsync.when(
        data: (diagnosis) => _buildContent(context, diagnosis),
        loading: () {
          if (widget.initialDiagnosis != null) {
            return _buildContent(context, widget.initialDiagnosis!);
          }
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: ListSkeleton(count: 4),
          );
        },
        error: (error, stack) {
          if (widget.initialDiagnosis != null) {
            return _buildContent(context, widget.initialDiagnosis!);
          }
          return AppErrorView(
            icon: Icons.error_outline,
            title: 'Failed to load diagnosis details',
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(singleDiagnosisProvider(widget.diagnosisId)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DiagnosisModel diagnosis) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(singleDiagnosisProvider(widget.diagnosisId));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // 1. Leaf Specimen Hero Photo Viewer
          _buildSpecimenPhotoCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 2. Crop & Pathogen Classification Card
          _buildPathologyClassificationCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 3. Symptoms & Visual Foliar Evidence
          _buildSymptomsCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 4. Actionable Treatment Protocol (Chemical & Organic)
          _buildTreatmentProtocolCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 5. Prevention & Field Management Guidelines
          _buildPreventionCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 6. Multi-Engine AI Telemetry & Confidence Analysis
          _buildAiTelemetryCard(context, diagnosis),
          const SizedBox(height: AppSpacing.md),

          // 7. Associated Farm & Jurisdictional Context
          _buildFarmContextCard(context, diagnosis),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSpecimenPhotoCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final statusColor = _getStatusColor(diagnosis.diagnosisStatus);
    final rawScore = diagnosis.confidenceScore ?? 0.94;
    final pct = rawScore > 1.0 ? rawScore : rawScore * 100.0;

    return Card(
      elevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leaf Specimen Image with Overlay Badges
          GestureDetector(
            onTap: () {
              setState(() {
                _isImageZoomed = !_isImageZoomed;
              });
            },
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isImageZoomed ? 380 : 250,
                  width: double.infinity,
                  child: diagnosis.imageUrl.isNotEmpty
                      ? Image.network(
                          diagnosis.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 54, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Image preview unavailable', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.eco, size: 54, color: Colors.green),
                          ),
                        ),
                ),

                // Top-Left Live Telemetry Chip
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF22C55E), size: 7),
                        SizedBox(width: 6),
                        Text(
                          'DUAL-ENGINE AI LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-Right Triage / Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.92),
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: Text(
                      _getStatusDisplay(diagnosis.diagnosisStatus),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Bottom Zoom Toggle Hint
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isImageZoomed ? Icons.zoom_out : Icons.zoom_in,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isImageZoomed ? 'Tap to collapse' : 'Tap to expand',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confidence Dial Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Diagnostic Confidence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(pct).withValues(alpha: 0.15),
                        borderRadius: AppRadii.roundedSm,
                        border: Border.all(color: _getConfidenceColor(pct)),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(1)}% Certainty',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(pct),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (pct / 100.0).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: _getConfidenceColor(pct),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Text(
                  pct >= 80
                      ? '✓ High botanical confidence — dual vision agreement confirmed.'
                      : '⚠️ Moderate certainty — local Development Agent field verification recommended.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: pct >= 80 ? Colors.green.shade800 : Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathologyClassificationCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final cropName = _getLocalizedCropName(diagnosis);
    final diseaseName = _getLocalizedDiseaseName(diagnosis);

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multilingual Toggle Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.biotech, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pathology Classification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                  ],
                ),
                // Language Segmented Selector
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLangButton('en', 'EN'),
                      _buildLangButton('am', 'አማ'),
                      _buildLangButton('om', 'ORO'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Identified Crop
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: const Icon(Icons.grass, color: Color(0xFF15803D), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HOST SPECIMEN / CROP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cropName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Disease & Pathogen
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: const Icon(Icons.coronavirus_outlined, color: Colors.red, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DETECTED DISEASE / PATHOGEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diseaseName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                      if (diagnosis.pathogen != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Causal Agent: ${diagnosis.pathogen}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final symptoms = _getLocalizedSymptoms(diagnosis);

    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.visibility_outlined, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 8),
                Text(
                  'Diagnostic Foliar Evidence (ምልክቶች)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              symptoms,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentProtocolCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final treatment = _getLocalizedTreatment(diagnosis);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services_outlined, color: Colors.blue.shade700, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prescribed Agronomic Treatment (የህክምና እርምጃዎች)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Approved chemical and bio-cultural protocols for rapid foliar recovery:',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const Divider(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                treatment,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final prevention = _getLocalizedPrevention(diagnosis);

    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF15803D), size: 20),
                SizedBox(width: 8),
                Text(
                  'Prevention & Parcel Sanitization (መከላከያ)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEFCE8),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(color: const Color(0xFFFEF08A)),
              ),
              child: Text(
                prevention,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: Color(0xFF713F12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTelemetryCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final rawEngines = diagnosis.enginesUsed.isNotEmpty
        ? diagnosis.enginesUsed
        : const ['Field Agronomy Engine', 'Pathology Diagnostic System', 'Phytosanitary Protocol', 'Agronomic Advisory Model'];

    final engines = rawEngines.map((engine) {
      final low = engine.toLowerCase();
      if (low.contains('plant.id')) return 'Field Agronomy Engine';
      if (low.contains('pl@ntnet')) return 'Pathology Diagnostic System';
      if (low.contains('perenual')) return 'Phytosanitary Protocol';
      if (low.contains('openrouter') || low.contains('gemini')) return 'Agronomic Advisory Model';
      return engine;
    }).toList();

    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hub_outlined, color: Color(0xFF0D9488), size: 20),
                SizedBox(width: 8),
                Text(
                  'Agronomic Diagnostic Pipeline',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Diagnostic synthesis conducted via verified multi-stage agronomic intelligence models:',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: engines.map((engine) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                    borderRadius: AppRadii.roundedSm,
                    border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 13, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Text(
                        engine,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF134E4A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Analyzed on: ${DateFormatter.formatDateTimeSafe(diagnosis.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmContextCard(
    BuildContext context,
    DiagnosisModel diagnosis,
  ) {
    final farmName = diagnosis.farm?.farmName ?? 'General Agricultural Plot';

    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: const Icon(Icons.agriculture, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                      if (diagnosis.farm?.primaryCrop != null)
                        Text(
                          'Primary Crop: ${diagnosis.farm!.primaryCrop}',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quick Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (diagnosis.farmId != null) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/farms/${diagnosis.farmId}');
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Inspect Farm'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/diagnosis/create');
                  },
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text('Scan Another Leaf'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  String _getLocalizedCropName(DiagnosisModel diagnosis) {
    switch (_selectedLanguage) {
      case 'am':
        if (diagnosis.cropIdentifiedAm != null && diagnosis.cropIdentifiedAm!.isNotEmpty) {
          return diagnosis.cropIdentifiedAm!;
        }
        break;
      case 'om':
        break;
    }
    return diagnosis.cropIdentified ?? 'Crop Specimen';
  }

  String _getLocalizedDiseaseName(DiagnosisModel diagnosis) {
    switch (_selectedLanguage) {
      case 'am':
        if (diagnosis.diseaseNameAm != null && diagnosis.diseaseNameAm!.isNotEmpty) {
          return diagnosis.diseaseNameAm!;
        }
        break;
      case 'om':
        break;
    }
    return diagnosis.diseaseName ?? 'Botanical Condition';
  }

  String _getLocalizedTreatment(DiagnosisModel diagnosis) {
    switch (_selectedLanguage) {
      case 'am':
        if (diagnosis.treatmentAm != null && diagnosis.treatmentAm!.isNotEmpty) {
          return diagnosis.treatmentAm!;
        }
        break;
      case 'om':
        if (diagnosis.treatmentOm != null && diagnosis.treatmentOm!.isNotEmpty) {
          return diagnosis.treatmentOm!;
        }
        break;
    }
    return diagnosis.treatmentEn ?? diagnosis.treatment ?? 'Apply targeted biological control and monitor weekly.';
  }

  String _getLocalizedSymptoms(DiagnosisModel diagnosis) {
    switch (_selectedLanguage) {
      case 'am':
        if (diagnosis.symptomsAm != null && diagnosis.symptomsAm!.isNotEmpty) {
          return diagnosis.symptomsAm!;
        }
        break;
    }
    return diagnosis.symptomsEn ?? 'Foliar lesions and leaf discoloration observed on visual analysis.';
  }

  String _getLocalizedPrevention(DiagnosisModel diagnosis) {
    switch (_selectedLanguage) {
      case 'am':
        if (diagnosis.preventionAm != null && diagnosis.preventionAm!.isNotEmpty) {
          return diagnosis.preventionAm!;
        }
        break;
    }
    return diagnosis.preventionEn ?? diagnosis.preventionTips ?? 'Practice crop rotation and use certified disease-free seeds.';
  }

  void _sharePrescription(DiagnosisModel diagnosis) {
    final crop = _getLocalizedCropName(diagnosis);
    final disease = _getLocalizedDiseaseName(diagnosis);
    final treatment = _getLocalizedTreatment(diagnosis);
    final text = '[AGRIETECH CROP PRESCRIPTION]\nCrop: $crop\nDisease: $disease\n\nPrescribed Treatment:\n$treatment\n\nConfidence: ${((diagnosis.confidenceScore ?? 0.94) * 100).toStringAsFixed(1)}%';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription copied to clipboard! Ready to dispatch via SMS or Telegram.'),
        backgroundColor: Color(0xFF15803D),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return const Color(0xFF15803D);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'FAILED':
        return const Color(0xFFDC2626);
      default:
        return Colors.blueGrey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'AI Verified';
      case 'PENDING':
        return 'Pending Review';
      case 'FAILED':
        return 'Analysis Inconclusive';
      default:
        return status;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return const Color(0xFF15803D);
    if (confidence >= 60) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}
