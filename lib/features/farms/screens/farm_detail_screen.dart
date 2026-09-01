import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/farms_provider.dart';

class FarmDetailScreen extends ConsumerWidget {
  final String farmId;

  const FarmDetailScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmAsync = ref.watch(farmProvider(farmId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Farm Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Farm details feature'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: farmAsync.when(
        data: (farm) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map
                SizedBox(
                  height: 250,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(farm.latitude, farm.longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.agrietech.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(farm.latitude, farm.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppTheme.errorColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.farmName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.neutralDark,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _DetailRow(
                        icon: Icons.grass,
                        label: 'Crop Type',
                        value: farm.primaryCrop,
                      ),
                      const SizedBox(height: AppSpacing.itemGap),

                      _DetailRow(
                        icon: Icons.crop_square,
                        label: 'Farm Size',
                        value: '${farm.areaHectares.toStringAsFixed(2)} hectares',
                      ),
                      const SizedBox(height: AppSpacing.itemGap),

                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Coordinates',
                        value:
                            '${farm.latitude.toStringAsFixed(6)}, ${farm.longitude.toStringAsFixed(6)}',
                      ),
                      const SizedBox(height: AppSpacing.itemGap),

                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Registration Date',
                        value: farm.createdAt != null
                            ? '${farm.createdAt!.day}/${farm.createdAt!.month}/${farm.createdAt!.year}'
                            : 'Active Plot',
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Google Earth Engine & Planetary Telemetry Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF162A1D) : Colors.white,
                          borderRadius: AppRadii.roundedLg,
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                          boxShadow: AppShadows.soft(isDark: isDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.satellite_alt, size: 18, color: AppTheme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Planetary Telemetry (GEE)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark ? Colors.white : AppTheme.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryContainer,
                                    borderRadius: AppRadii.roundedPill,
                                  ),
                                  child: const Text(
                                    '10m High-Res',
                                    style: TextStyle(color: AppTheme.primaryDark, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.itemGap),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTelemetryStat(
                                    label: 'Sentinel-2 NDVI',
                                    value: '0.78',
                                    subtitle: 'Healthy Vigor',
                                    color: AppTheme.telemetryNdvi,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTelemetryStat(
                                    label: 'SAR Soil Moisture',
                                    value: '72.6%',
                                    subtitle: 'Optimal Saturation',
                                    color: AppTheme.telemetrySoil,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // EthioSIS Digital Soil Health Prescription Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF231F14) : const Color(0xFFFFFBEB),
                          borderRadius: AppRadii.roundedLg,
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.3 : 0.4),
                          ),
                          boxShadow: AppShadows.soft(isDark: isDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.science_outlined, size: 18, color: Color(0xFFB45309)),
                                const SizedBox(width: 8),
                                Text(
                                  'EthioSIS Soil & Fertilizer Prescription',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Soil Type: Deep Nitisol / Vertisol (pH 6.5)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade300 : const Color(0xFF78350F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prescription: NPSB (100 kg/ha) at basal + Urea (100 kg/ha split-applied at tillering)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                              ),
                              onPressed: () {
                                context.push('/create-diagnosis');
                              },
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Scan Leaf Disease', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                              ),
                              onPressed: () {
                                context.push('/analytics');
                              },
                              icon: const Icon(Icons.insights_outlined),
                              label: const Text('Plot Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading farm: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(farmProvider(farmId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryStat({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppTheme.neutralDark,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
