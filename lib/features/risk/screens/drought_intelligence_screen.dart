import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'disaster_intelligence_screen.dart';

class DroughtIntelligenceScreen extends ConsumerStatefulWidget {
  const DroughtIntelligenceScreen({super.key});

  @override
  ConsumerState<DroughtIntelligenceScreen> createState() => _DroughtIntelligenceScreenState();
}

class _DroughtIntelligenceScreenState extends ConsumerState<DroughtIntelligenceScreen> {
  EthiopiaWoredaPreset _selectedWoreda = woredaPresets[7]; // Default Jijiga / Lowland

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Agro-meteorological drought metrics
    final isLowland = _selectedWoreda.lat < 8.0 || _selectedWoreda.lng > 40.0;
    final spi1 = isLowland ? -1.65 : 0.25;
    final spi3 = isLowland ? -1.42 : -0.15;
    final vci = isLowland ? 32.0 : 68.0; // Vegetation Condition Index %
    final cwsi = isLowland ? 0.72 : 0.28; // Crop Water Stress Index 0-1
    final soilMoisture = isLowland ? 18.0 : 48.0;

    final isSevereDrought = spi3 <= -1.5 || vci < 35.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drought & Moisture Desiccation'),
      ),
      body: Column(
        children: [
          // Woreda Selector Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162A1D) : AppTheme.surfaceLight,
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EthiopiaWoredaPreset>(
                      isExpanded: true,
                      value: _selectedWoreda,
                      items: woredaPresets.map((preset) {
                        return DropdownMenuItem<EthiopiaWoredaPreset>(
                          value: preset,
                          child: Text(
                            preset.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedWoreda = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Drought Executive Badge
                _buildDroughtHeaderBadge(spi3, isSevereDrought),
                const SizedBox(height: 16),

                // 2. Multiscale SPI Precipitation Anomaly
                _buildSpiIndexCard(spi1, spi3),
                const SizedBox(height: 16),

                // 3. Satellite VCI & Thermal Crop Water Stress (CWSI)
                _buildVegetationThermalCard(vci, cwsi, soilMoisture),
                const SizedBox(height: 16),

                // 4. Agronomic Drought Coping Strategies
                _buildAgronomicDroughtPrescriptionsCard(isSevereDrought),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDroughtHeaderBadge(double spi3, bool isSevere) {
    Color badgeColor = isSevere ? Colors.red.shade800 : (spi3 < -0.5 ? Colors.orange.shade800 : Colors.green.shade800);
    String statusText = isSevere ? 'CRITICAL DROUGHT WARNING' : (spi3 < -0.5 ? 'MODERATE MOISTURE STRESS' : 'OPTIMAL MOISTURE');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [badgeColor, badgeColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.35),
            blurRadius: 12,
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
              const Row(
                children: [
                  Icon(Icons.water_damage_outlined, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'CHIRPS & GEE CLIMATIC DROUGHT WATCH',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDroughtStat(spi3.toStringAsFixed(2), 'SPI-3 Drought Index', 'Rainfall Deficit'),
              _buildDroughtStat(_selectedWoreda.name.split(' ')[0], 'Target Woreda', _selectedWoreda.region),
              _buildDroughtStat(isSevere ? 'HIGH RISK' : 'NORMAL', 'Crop Water Stress', 'Landsat TIRS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDroughtStat(String val, String title, String sub) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 9)),
      ],
    );
  }

  Widget _buildSpiIndexCard(double spi1, double spi3) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grain, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Standardized Precipitation Index (SPI)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'SPI-1 (30-Day)',
                    value: spi1.toStringAsFixed(2),
                    subtitle: spi1 < -1.0 ? 'Meteorological Deficit' : 'Near Normal',
                    color: spi1 < -1.0 ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'SPI-3 (90-Day Season)',
                    value: spi3.toStringAsFixed(2),
                    subtitle: spi3 < -1.0 ? 'Agricultural Drought' : 'Adequate',
                    color: spi3 < -1.0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegetationThermalCard(double vci, double cwsi, double moisture) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.satellite_alt, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text(
                  'Vegetation Condition & Thermal Stress (GEE)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'VCI Canopy Vigor',
                    value: '$vci%',
                    subtitle: vci < 40 ? 'Severe Stunting' : 'Healthy Canopy',
                    color: vci < 40 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Crop Water Stress',
                    value: '${(cwsi * 100).toStringAsFixed(0)}%',
                    subtitle: cwsi > 0.6 ? 'Desiccation' : 'Hydrated',
                    color: cwsi > 0.6 ? Colors.orange.shade900 : Colors.teal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Soil Moisture',
                    value: '$moisture%',
                    subtitle: moisture < 25 ? 'Deficit' : 'Optimal',
                    color: moisture < 25 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgronomicDroughtPrescriptionsCard(bool isSevere) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco_outlined, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'የድርቅ መቋቋሚያ የግብርና ምክረ-ሀሳቦች (Prescriptions)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildPrescriptionItem('ድርቅን የሚቋቋሙ አጫጭር የሰብል ዝርያዎችን (እንደ መልካሳ-2 በቆሎ እና ቁንጮ ጤፍ) መጠቀም።'),
            _buildPrescriptionItem('የማሳ እርጥበትን ለመጠበቅ ጉዝጓዝ (Mulching) እና ማሳውን በቅጠላ ቅጠል የመሸፈን ስራ መስራት።'),
            _buildPrescriptionItem('የዝናብ ውሃ ማቆሪያ ጉድጓዶችንና የኩሬ መስኖ ዘዴዎችን በመጠቀም ተጨማሪ የመስኖ ውሃ ማቅረብ።'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.3))),
        ],
      ),
    );
  }
}
