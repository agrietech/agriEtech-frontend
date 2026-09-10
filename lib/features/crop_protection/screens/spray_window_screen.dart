import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class SprayWindowScreen extends ConsumerStatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? farmId;

  const SprayWindowScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.farmId,
  });

  @override
  ConsumerState<SprayWindowScreen> createState() => _SprayWindowScreenState();
}

class _SprayWindowScreenState extends ConsumerState<SprayWindowScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sprayAsync = ref.watch(
      sprayWindowFutureProvider((lat: widget.latitude, lng: widget.longitude, farmId: widget.farmId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spray Window Weather Advisory'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Telemetry',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(sprayWindowFutureProvider);
            },
          ),
        ],
      ),
      body: sprayAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                'Analyzing Microclimate & Wind Drift...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Weather advisory unavailable: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(sprayWindowFutureProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(sprayWindowFutureProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Suitability Banner
                _buildCurrentStatusBanner(data.currentConditions, isDark),

                const SizedBox(height: 16),

                // 2. Telemetry Metric Gauges
                _buildTelemetryGauges(data.currentConditions, isDark),

                const SizedBox(height: 16),

                // 3. Best Window Recommendation
                _buildBestWindowCard(data, isDark),

                const SizedBox(height: 16),

                // 4. Rainfastness & Drift Advisory
                _buildRainfastnessCard(data, isDark),

                const SizedBox(height: 20),

                // 5. Next 12 Hours Spray Timeline
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Next 12 Hours Spray Suitability Timeline',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.next12HoursAdvisory.map((h) => _buildHourlyTimelineItem(h, isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusBanner(CurrentSprayConditions current, bool isDark) {
    Color statusColor;
    String statusTitle;
    String statusAmharic;
    IconData statusIcon;

    switch (current.status) {
      case 'OPTIMAL_TO_SPRAY':
        statusColor = const Color(0xFF16A34A);
        statusTitle = 'OPTIMAL TO SPRAY';
        statusAmharic = 'አሁን ለርጭት በጣም ተስማሚ ነው';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'SPRAY_WITH_CAUTION':
        statusColor = const Color(0xFFF59E0B);
        statusTitle = 'SPRAY WITH CAUTION';
        statusAmharic = 'በከፍተኛ ጥንቃቄ ይርጩ';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'DO_NOT_SPRAY':
      default:
        statusColor = const Color(0xFFDC2626);
        statusTitle = 'DO NOT SPRAY NOW';
        statusAmharic = 'አሁን በፍጹም አይርጩ (አደገኛ)';
        statusIcon = Icons.cancel_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      statusAmharic,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...current.riskFactorsEn.map((risk) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        risk,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTelemetryGauges(CurrentSprayConditions current, bool isDark) {
    return Row(
      children: [
        _buildGaugeCard(
          title: 'Wind Speed',
          value: '${current.windSpeedKmh.toStringAsFixed(1)} km/h',
          target: 'Target: 3 - 12 km/h',
          isWarning: current.windSpeedKmh > 12.0 || current.windSpeedKmh < 3.0,
          icon: Icons.air_rounded,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildGaugeCard(
          title: 'Temperature',
          value: '${current.temperatureC.toStringAsFixed(1)} °C',
          target: 'Max Safe: 28 °C',
          isWarning: current.temperatureC > 28.0,
          icon: Icons.thermostat_rounded,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildGaugeCard(
          title: 'Humidity',
          value: '${current.relativeHumidity.toStringAsFixed(0)} %',
          target: 'Optimal: 50-80%',
          isWarning: current.relativeHumidity < 40.0,
          icon: Icons.water_drop_rounded,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required String value,
    required String target,
    required bool isWarning,
    required IconData icon,
    required bool isDark,
  }) {
    final color = isWarning ? const Color(0xFFF59E0B) : const Color(0xFF16A34A);

    return Expanded(
      child: AppSurfaceCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isWarning ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              target,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestWindowCard(SprayWindowData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
        ),
        borderRadius: AppRadii.roundedMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Spray Window',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  data.bestWindowRecommendation,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainfastnessCard(SprayWindowData data, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.umbrella_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Rainfastness & Drift Precautions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.rainfastnessAdvisoryEn,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 4),
          Text(
            data.rainfastnessAdvisoryAm,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyTimelineItem(HourlySprayAdvisory hour, bool isDark) {
    Color badgeColor;
    switch (hour.suitability) {
      case 'OPTIMAL':
        badgeColor = const Color(0xFF16A34A);
        break;
      case 'CAUTION':
        badgeColor = const Color(0xFFF59E0B);
        break;
      case 'UNSUITABLE':
      default:
        badgeColor = const Color(0xFFDC2626);
    }

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              hour.hourLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              hour.suitability,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour.reasonEn,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
                Text(
                  hour.reasonAm,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${hour.windSpeedKmh} km/h',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              Text(
                '${hour.temperatureC}°C',
                style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
