import 'package:flutter/material.dart';
import '../../data/models/soil_profile_model.dart';

/// Soil Nutrient and Moisture Progress Bar Widget
class SoilNutrientBar extends StatelessWidget {
  final SoilProfileModel? profile;
  final double? moisture;
  final double? tempC;
  final double? ph;
  final double? ec;

  const SoilNutrientBar({
    super.key,
    this.profile,
    this.moisture,
    this.tempC,
    this.ph,
    this.ec,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mVal = profile?.soilMoisturePercent ?? moisture ?? 42.0;
    final tVal = profile?.soilTempC ?? tempC ?? 22.5;
    final phVal = profile?.phLevel ?? ph ?? 6.8;
    final ecVal = profile?.electricalConductivity ?? ec ?? 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soil Profile & Health',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'IoT Telemetry',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricBar(
            context: context,
            label: 'Volumetric Soil Moisture',
            valueText: '${mVal.toStringAsFixed(1)}%',
            progress: (mVal / 100.0).clamp(0.0, 1.0),
            color: mVal < 20
                ? const Color(0xFFEF4444)
                : (mVal > 80 ? const Color(0xFF3B82F6) : const Color(0xFF10B981)),
            status: mVal < 20 ? 'Low (Deficit)' : (mVal > 80 ? 'Saturated' : 'Optimal'),
            icon: Icons.water_drop_outlined,
          ),
          const SizedBox(height: 14),
          _buildMetricBar(
            context: context,
            label: 'Soil Temperature',
            valueText: '${tVal.toStringAsFixed(1)} °C',
            progress: (tVal / 45.0).clamp(0.0, 1.0),
            color: const Color(0xFFF59E0B),
            status: tVal > 35 ? 'High Stress' : 'Normal',
            icon: Icons.thermostat_outlined,
          ),
          const SizedBox(height: 14),
          _buildMetricBar(
            context: context,
            label: 'Soil pH Level',
            valueText: phVal.toStringAsFixed(1),
            progress: (phVal / 14.0).clamp(0.0, 1.0),
            color: (phVal >= 6.0 && phVal <= 7.5)
                ? const Color(0xFF10B981)
                : const Color(0xFF8B5CF6),
            status: phVal < 6.0 ? 'Acidic' : (phVal > 7.5 ? 'Alkaline' : 'Neutral (Ideal)'),
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 14),
          _buildMetricBar(
            context: context,
            label: 'Electrical Conductivity (EC)',
            valueText: '${ecVal.toStringAsFixed(1)} dS/m',
            progress: (ecVal / 4.0).clamp(0.0, 1.0),
            color: ecVal > 2.5 ? const Color(0xFFEF4444) : const Color(0xFF06B6D4),
            status: ecVal > 2.5 ? 'Saline Warning' : 'Non-Saline',
            icon: Icons.electric_bolt_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar({
    required BuildContext context,
    required String label,
    required String valueText,
    required double progress,
    required Color color,
    required String status,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
