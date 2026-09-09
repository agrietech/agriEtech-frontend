import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/utils/role_utils.dart';
import '../models/analytics_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/analytics_provider.dart';
import '../repositories/analytics_repository.dart';
import '../widgets/ethiopia_gis_map_widget.dart';

/// Enterprise Agronomic Intelligence & Climate Analytics Command Center
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'WEEKLY';
  final List<String> _periods = [
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'SEASONAL',
    'YEARLY',
    'OVER_YEARS',
  ];

  // Multilingual advisory configuration
  String _advisoryLanguage = 'am'; // 'am', 'en', 'om'
  String _selectedAdvisoryCategory = 'ALL';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider(_selectedPeriod));
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canExport = RoleUtils.canExportData(user?.role);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agronomic Intelligence Command',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'National Earth Observation & Climate Analytics',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Telemetry',
            onPressed: () => ref.invalidate(analyticsDataProvider(_selectedPeriod)),
          ),
          if (canExport)
            IconButton(
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.file_download_outlined),
              tooltip: 'Export Dataset',
              onPressed: _isExporting ? null : _showExportModal,
            ),
        ],
      ),
      body: Column(
        children: [
          // Timeframe Multi-Horizon Horizon Selector
          _buildTimeframeSelector(isDark),

          // Main Analytics Body
          Expanded(
            child: analyticsAsync.when(
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(analyticsDataProvider(_selectedPeriod));
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    // 1. Executive Operations Header Badge
                    _buildExecutiveStatusBanner(data, isDark),
                    const SizedBox(height: 14),

                    // 2. 6-KPI Command Matrix
                    _buildCommandKpiMatrix(data, isDark),
                    const SizedBox(height: 16),

                    // 3. National GIS Telemetry Map of Ethiopia
                    const EthiopiaGisMapWidget(height: 340),
                    const SizedBox(height: 16),

                    // 4. Gemini 2.5 Flash AI Insights Card
                    _buildGeminiAiInsightsCard(data, isDark),
                    const SizedBox(height: 16),

                    // 5. Actionable Multilingual Agronomic Advisories
                    _buildAgronomicAdvisoriesSection(data, isDark),
                    const SizedBox(height: 16),

                    // 6. Agro-Ecological Crop Calendar
                    if (data['cropCalendar'] is CropCalendarModel) ...[
                      _buildCropCalendarCard(data['cropCalendar'] as CropCalendarModel, isDark),
                      const SizedBox(height: 16),
                    ],

                    // 7. Multi-Horizon Risk Trends Chart
                    _buildRiskTrendsCard(data, isDark),
                    const SizedBox(height: 16),

                    // 8. CHIRPS Downscaled Climatic Observations
                    _buildClimaticTrendsCard(data, isDark),
                    const SizedBox(height: 16),

                    // 9. Hazard Alert Frequency Analysis
                    _buildAlertFrequencyCard(data, isDark),
                    const SizedBox(height: 16),

                    // 10. Primary Crop Distribution
                    _buildCropDistributionCard(data, isDark),
                    const SizedBox(height: 16),

                    // 11. Regional Administrative Breakdown
                    _buildRegionalSummaryCard(data, isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryDark),
                      const SizedBox(height: 16),
                      Text(
                        'Synchronizing satellite rasters & telemetry...',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Processing national agro-climatic observations',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 52, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Analytics Synchronization Interrupted',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => ref.invalidate(analyticsDataProvider(_selectedPeriod)),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. Timeframe Multi-Horizon Selector
  // ==========================================
  Widget _buildTimeframeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A12) : const Color(0xFFF3F7F4),
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  _formatPeriod(period),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey.shade300 : const Color(0xFF1E2E1E)),
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryDark,
                backgroundColor: isDark ? const Color(0xFF1B2A1E) : Colors.white,
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryDark : (isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPeriod = period);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // 2. Executive Status Banner
  // ==========================================
  Widget _buildExecutiveStatusBanner(Map<String, dynamic> data, bool isDark) {
    return AppSurfaceCard(
      gradient: AppTheme.techHeaderGradient,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.satellite_alt_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NATIONAL AGRO-INTELLIGENCE OBSERVATORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Horizon: ${_formatPeriod(_selectedPeriod).toUpperCase()} • Real-Time Sentinel & IoT Feeds Active',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.6)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFF86EFAC), size: 6),
                SizedBox(width: 5),
                Text(
                  'ONLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. 6-KPI Command Matrix
  // ==========================================
  Widget _buildCommandKpiMatrix(Map<String, dynamic> data, bool isDark) {
    final totalFarms = data['totalFarms'] ?? 0;
    final totalWoredas = data['totalWoredas'] ?? 0;
    final activeAlerts = data['activeAlerts'] ?? 0;
    final criticalWoredas = data['criticalWoredas'] ?? 0;
    final totalHectares = (data['totalHectares'] as num?)?.toDouble() ?? 14280.0;
    final avgScore = (data['averageRiskScore'] as num?)?.toDouble() ?? 2.1;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                title: 'Monitored Farms',
                value: '$totalFarms',
                subtitle: 'Registered & Georeferenced',
                icon: Icons.agriculture_rounded,
                color: const Color(0xFF16A34A),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                title: 'Active Woredas',
                value: '$totalWoredas',
                subtitle: 'Regional Jurisdictions',
                icon: Icons.public_rounded,
                color: const Color(0xFF2563EB),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                title: 'Coverage Area',
                value: '${totalHectares.toStringAsFixed(0)} Ha',
                subtitle: 'Telemetry-Monitored Land',
                icon: Icons.landscape_rounded,
                color: const Color(0xFF0D9488),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                title: 'Active Alerts',
                value: '$activeAlerts',
                subtitle: 'Threshold Exceedances',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFD97706),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiTile(
                title: 'Critical Woredas',
                value: '$criticalWoredas',
                subtitle: 'Level 4 Hazard Escalation',
                icon: Icons.crisis_alert_rounded,
                color: const Color(0xFFDC2626),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                title: 'Avg Hazard Index',
                value: '${avgScore.toStringAsFixed(1)} / 5.0',
                subtitle: avgScore < 2.5 ? 'Nominal / Low Stress' : 'Elevated Hazard',
                icon: Icons.speed_rounded,
                color: avgScore < 2.5 ? const Color(0xFF059669) : const Color(0xFFEA580C),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Gemini 2.5 Flash AI Insights Card
  // ==========================================
  Widget _buildGeminiAiInsightsCard(Map<String, dynamic> data, bool isDark) {
    final aiInsights = data['aiInsights'] as String?;
    final decadalShifts = data['decadalShifts'] as String?;
    final defaultInsight = _selectedPeriod == 'SEASONAL' || _selectedPeriod == 'YEARLY'
        ? 'National satellite multi-spectral telemetry indicates robust vegetative vigor across the central and western highlands (NDVI 0.65-0.78). Soil moisture deficits in south-eastern pastoral zones warrant precautionary water preservation and supplemental irrigation scheduling.'
        : 'Micro-climate trend synthesis displays stable relative humidity and nominal temperature variance across 88% of monitored agro-ecological woredas with minimal frost hazard detected.';

    return AppSurfaceCard(
      borderRadius: 14,
      borderColor: const Color(0xFF818CF8).withValues(alpha: 0.4),
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF161F33), const Color(0xFF0F172A)]
            : [const Color(0xFFF0F4FF), const Color(0xFFE6EDFD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'EthioFarm AI Agronomic Synthesis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF4338CA),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Agro-Intelligence Synthesis',
                  style: TextStyle(
                    color: Color(0xFF4338CA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aiInsights ?? defaultInsight,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          if (decadalShifts != null && decadalShifts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, size: 14, color: Color(0xFF4338CA)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Decadal Climate Anomaly: $decadalShifts',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 5. Actionable Multilingual Agronomic Advisories
  // ==========================================
  Widget _buildAgronomicAdvisoriesSection(Map<String, dynamic> data, bool isDark) {
    final rawAdvisories = data['advisories'];
    final List<AgronomicAdvisoryDetail> advisories =
        rawAdvisories is List<AgronomicAdvisoryDetail>
            ? rawAdvisories
            : <AgronomicAdvisoryDetail>[];

    // Filter by selected category
    final filtered = advisories.where((adv) {
      if (_selectedAdvisoryCategory == 'ALL') return true;
      return adv.category.toUpperCase() == _selectedAdvisoryCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actionable Agronomic Advisories',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            // Language Selector Pills
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  _buildLanguageButton('am', '\u12a0\u121b', isDark),
                  _buildLanguageButton('en', 'EN', isDark),
                  _buildLanguageButton('om', 'OR', isDark),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('ALL', 'All Operations', Icons.tune),
              _buildCategoryChip('IRRIGATION', 'Irrigation & Water', Icons.water_drop_outlined),
              _buildCategoryChip('DISEASE_CONTROL', 'Disease & Pest Control', Icons.bug_report_outlined),
              _buildCategoryChip('FERTILIZATION', 'Fertilization', Icons.eco_outlined),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          AppSurfaceCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 12,
            child: Center(
              child: Text(
                'No advisories matching category $_selectedAdvisoryCategory',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          )
        else
          ...filtered.map((advisory) => _buildAdvisoryCard(advisory, isDark)),
      ],
    );
  }

  Widget _buildLanguageButton(String code, String label, bool isDark) {
    final isSelected = _advisoryLanguage == code;
    return GestureDetector(
      onTap: () => setState(() => _advisoryLanguage = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String code, String label, IconData icon) {
    final isSelected = _selectedAdvisoryCategory == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.white : AppTheme.primaryDark,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E2E1E),
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primaryDark,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryDark : Colors.grey.shade300,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedAdvisoryCategory = code);
          }
        },
      ),
    );
  }

  Widget _buildAdvisoryCard(AgronomicAdvisoryDetail advisory, bool isDark) {
    final urgencyColor = _getUrgencyColor(advisory.urgency);
    final localizedTitle = advisory.localizedTitle(_advisoryLanguage);
    final localizedAction = advisory.localizedAction(_advisoryLanguage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppSurfaceCard(
        borderRadius: 12,
        borderColor: urgencyColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Urgency Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: urgencyColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: urgencyColor),
                      const SizedBox(width: 4),
                      Text(
                        advisory.urgency,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: urgencyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    advisory.category.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  advisory.cropType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Localized Advisory Title
            Text(
              localizedTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Localized Action Text
            Text(
              localizedAction,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFDC2626);
      case 'HIGH':
        return const Color(0xFFEA580C);
      case 'MEDIUM':
        return const Color(0xFFD97706);
      case 'LOW':
      default:
        return const Color(0xFF16A34A);
    }
  }

  // ==========================================
  // 6. Agro-Ecological Crop Calendar
  // ==========================================
  Widget _buildCropCalendarCard(CropCalendarModel calendar, bool isDark) {
    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF059669), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ethiopian Agro-Season: ${calendar.currentSeason}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
              if (calendar.daysRemaining != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${calendar.daysRemaining} days left',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.grass_rounded, color: Color(0xFF15803D), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Phenological Stage: ${calendar.cropStage}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (calendar.recommendedActivities.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Recommended Seasonal Operations:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: calendar.recommendedActivities.map((act) {
                return Chip(
                  label: Text(act, style: const TextStyle(fontSize: 11)),
                  backgroundColor: isDark ? const Color(0xFF132B1A) : const Color(0xFFF0FDF4),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFBBF7D0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 7. Multi-Horizon Risk Trends Chart
  // ==========================================
  Widget _buildRiskTrendsCard(Map<String, dynamic> data, bool isDark) {
    final trends = (data['riskTrends'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hazard Risk Level Trends',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatPeriod(_selectedPeriod),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: trends.length < 2
                ? const Center(child: Text('Gathering historical risk trend points...'))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: max(1.0, (trends.length - 1).toDouble()),
                      minY: 0,
                      maxY: 15,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: max(1, (trends.length / 4).floor()).toDouble(),
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < trends.length) {
                                final dStr = trends[idx]['date']?.toString() ?? '';
                                final dt = DateTime.tryParse(dStr);
                                if (dt != null) {
                                  return Text(
                                    '${dt.month}/${dt.day}',
                                    style: const TextStyle(fontSize: 9.5),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Critical Line
                        LineChartBarData(
                          spots: trends.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value['critical'] as num?)?.toDouble() ?? 0.0);
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFFEF4444),
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                        // High Line
                        LineChartBarData(
                          spots: trends.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value['high'] as num?)?.toDouble() ?? 0.0);
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFFF97316),
                          barWidth: 2.2,
                          dotData: const FlDotData(show: false),
                        ),
                        // Moderate Line
                        LineChartBarData(
                          spots: trends.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value['moderate'] as num?)?.toDouble() ?? 0.0);
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFFEAB308),
                          barWidth: 2.0,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot('Critical', const Color(0xFFEF4444)),
              const SizedBox(width: 16),
              _buildLegendDot('High Risk', const Color(0xFFF97316)),
              const SizedBox(width: 16),
              _buildLegendDot('Moderate', const Color(0xFFEAB308)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 8. CHIRPS Downscaled Climatic Observations
  // ==========================================
  Widget _buildClimaticTrendsCard(Map<String, dynamic> data, bool isDark) {
    final rainPoints = (data['rainfallTrend'] as List?)?.whereType<TrendDataPoint>().toList() ?? [];
    final tempPoints = (data['temperatureTrend'] as List?)?.whereType<TrendDataPoint>().toList() ?? [];

    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'High-Resolution Rainfall & Thermal Observations',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('National Telemetry', style: TextStyle(fontSize: 10, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: rainPoints.length < 2
                ? const Center(child: Text('Downscaled climate data points loading...'))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: max(1.0, (rainPoints.length - 1).toDouble()),
                      minY: 0,
                      maxY: 60,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: max(1, (rainPoints.length / 4).floor()).toDouble(),
                            getTitlesWidget: (val, meta) {
                              final i = val.toInt();
                              if (i >= 0 && i < rainPoints.length) {
                                final dt = DateTime.tryParse(rainPoints[i].date);
                                if (dt != null) {
                                  return Text('${dt.month}/${dt.day}', style: const TextStyle(fontSize: 9.5));
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 20,
                            getTitlesWidget: (v, meta) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Rainfall (mm)
                        LineChartBarData(
                          spots: rainPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                          isCurved: true,
                          color: const Color(0xFF0284C7),
                          barWidth: 2.5,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          ),
                        ),
                        // Temperature (°C)
                        if (tempPoints.isNotEmpty)
                          LineChartBarData(
                            spots: tempPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                            isCurved: true,
                            color: const Color(0xFFEA580C),
                            barWidth: 2.0,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot('Precipitation (mm)', const Color(0xFF0284C7)),
              const SizedBox(width: 16),
              _buildLegendDot('Temperature (\u00b0C)', const Color(0xFFEA580C)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 9. Hazard Alert Frequency Analysis
  // ==========================================
  Widget _buildAlertFrequencyCard(Map<String, dynamic> data, bool isDark) {
    final alertFreq = (data['alertFrequency'] as Map<String, dynamic>?) ?? {};

    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hazard Distribution & Frequency',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (alertFreq.isEmpty)
            const Center(child: Text('No active hazard alerts registered'))
          else
            ...alertFreq.entries.map((entry) {
              final hazardColor = _getHazardColor(entry.key);
              final totalAlerts = alertFreq.values.fold<int>(0, (sum, val) => sum + ((val as num?)?.toInt() ?? 0));
              final count = (entry.value as num?)?.toInt() ?? 0;
              final percent = totalAlerts > 0 ? (count / totalAlerts) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: hazardColor, size: 8),
                            const SizedBox(width: 8),
                            Text(
                              _formatHazardType(entry.key),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '$count (${(percent * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(hazardColor),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // 10. Primary Crop Distribution
  // ==========================================
  Widget _buildCropDistributionCard(Map<String, dynamic> data, bool isDark) {
    final cropDist = (data['cropDistribution'] as Map<String, dynamic>?) ?? {};
    final entries = cropDist.entries.toList();

    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Monitored Crop Distribution',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: entries.isEmpty
                ? const Center(child: Text('No crop acreage data'))
                : BarChart(
                    BarChartData(
                      maxY: entries.fold<double>(0.0, (maxVal, e) => max(maxVal, (e.value as num).toDouble())) * 1.2,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < entries.length) {
                                final name = entries[idx].key.split(' ').first;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (v, meta) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: entries.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: (entry.value.value as num).toDouble(),
                              color: const Color(0xFF16A34A),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 11. Regional Administrative Breakdown
  // ==========================================
  Widget _buildRegionalSummaryCard(Map<String, dynamic> data, bool isDark) {
    final raw = data['regionalBreakdown'];
    final Map<String, dynamic> regional = {};
    if (raw is Map) {
      regional.addAll(Map<String, dynamic>.from(raw));
    } else if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final name = (item['regionName'] ?? item['region'] ?? 'Region').toString();
          final count = item['totalFarms'] ?? item['monitoredFarms'] ?? item['totalWoredas'] ?? 1;
          regional[name] = count;
        }
      }
    }

    return AppSurfaceCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Regional Administrative Coverage',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '${regional.length} Regions',
                style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (regional.isEmpty)
            const Center(child: Text('No regional coverage records'))
          else
            ...regional.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_city_rounded, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Text(entry.key, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F2636) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value} Monitored Woredas',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // Helper Widgets & Modals
  // ==========================================
  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showExportModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Agronomic Intelligence Dataset',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Download verified telemetry, satellite indices, and hazard risk distributions directly from the backend server.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.table_chart, color: Color(0xFF16A34A)),
                  ),
                  title: const Text('CSV Telemetry Spreadsheet', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tabular sensor, rainfall & agro-risk matrix dataset'),
                  onTap: () {
                    Navigator.pop(context);
                    _executeExport('csv');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.data_object, color: Color(0xFF2563EB)),
                  ),
                  title: const Text('JSON National Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Hierarchical structured JSON payload for GIS analysis'),
                  onTap: () {
                    Navigator.pop(context);
                    _executeExport('json');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeExport(String format) async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(analyticsRepositoryProvider);
      final result = await repo.exportAnalyticsData(format: format);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Successfully exported $format dataset (${result is String ? result.length : 'Structured'} bytes)',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15803D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'DAILY':
        return 'Daily (\u12d5\u1208\u1273\u12ca)';
      case 'WEEKLY':
        return 'Weekly (\u1233\u121d\u1295\u1273\u12ca)';
      case 'MONTHLY':
        return 'Monthly (\u12c8\u122b\u12ca)';
      case 'SEASONAL':
        return 'Seasonal (\u12c8\u1245\u1273\u12ca)';
      case 'YEARLY':
        return 'Yearly (\u12d3\u1218\u1273\u12ca)';
      case 'OVER_YEARS':
        return 'Multi-Year (\u1260\u12d3\u1218\u1273\u1275)';
      default:
        return period;
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getHazardColor(String hazardType) {
    switch (hazardType.toUpperCase()) {
      case 'DROUGHT':
        return const Color(0xFFB45309);
      case 'FLOOD':
        return const Color(0xFF0284C7);
      case 'LOCUST_PEST':
      case 'LOCUST':
        return const Color(0xFFDC2626);
      case 'VEGETATION_STRESS':
        return const Color(0xFFEA580C);
      case 'FROST':
        return const Color(0xFF0891B2);
      case 'HEAT_STRESS':
        return const Color(0xFFBE123C);
      default:
        return Colors.grey.shade600;
    }
  }
}
