import 'package:flutter/material.dart';

/// Multi-Hazard Composite Risk Map Widget with Layer Toggles
class MultiHazardMap extends StatefulWidget {
  final String woredaName;
  final String activeHazard;
  final ValueChanged<String>? onHazardChanged;

  const MultiHazardMap({
    super.key,
    this.woredaName = 'East Hararghe - Haramaya',
    this.activeHazard = 'Drought',
    this.onHazardChanged,
  });

  @override
  State<MultiHazardMap> createState() => _MultiHazardMapState();
}

class _MultiHazardMapState extends State<MultiHazardMap> {
  late String _selectedHazard;

  final List<Map<String, dynamic>> _hazards = const [
    {'name': 'Drought', 'icon': Icons.wb_sunny_outlined, 'color': Color(0xFFF59E0B), 'severity': 'HIGH'},
    {'name': 'Flood', 'icon': Icons.water_outlined, 'color': Color(0xFF0284C7), 'severity': 'LOW'},
    {'name': 'Locust', 'icon': Icons.radar_outlined, 'color': Color(0xFFDC2626), 'severity': 'CRITICAL'},
    {'name': 'NDVI', 'icon': Icons.eco_outlined, 'color': Color(0xFF10B981), 'severity': 'MODERATE'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedHazard = widget.activeHazard;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = _hazards.firstWhere(
      (h) => h['name'] == _selectedHazard,
      orElse: () => _hazards.first,
    );

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multi-Hazard Geographic Overlay',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 13, color: Color(0xFF6B7280)),
                      const SizedBox(width: 2),
                      Text(
                        widget.woredaName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (active['color'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${active['severity']} RISK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: active['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Layer Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _hazards.map((h) {
                final isSelected = h['name'] == _selectedHazard;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      h['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : (h['color'] as Color),
                    ),
                    label: Text(h['name'] as String),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                    checkmarkColor: Colors.white,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedHazard = h['name'] as String);
                        widget.onHazardChanged?.call(h['name'] as String);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Visual Map Preview
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(active['icon'] as IconData, size: 42, color: (active['color'] as Color).withValues(alpha: 0.7)),
                      const SizedBox(height: 8),
                      Text(
                        '${active['name']} Layer Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'OpenStreetMap Geofence Active',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '© OpenStreetMap',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
