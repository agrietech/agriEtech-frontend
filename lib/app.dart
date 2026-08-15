///
/// @file app.dart
/// @description Root MaterialApp Configuration with project initialization status screen.
/// @author Team Lead / Frontend Core
///
library app;

import 'package:flutter/material.dart';
import 'core/config/app_theme.dart';

class AgriEtechApp extends StatelessWidget {
  const AgriEtechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriEtech Early Warning Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ProjectCreatedScreen(),
    );
  }
}

class ProjectCreatedScreen extends StatelessWidget {
  const ProjectCreatedScreen({super.key});

  final List<Map<String, dynamic>> modules = const [
    {'name': 'Authentication (Auth)', 'icon': Icons.lock_outline, 'status': 'Ready for Assignment'},
    {'name': 'HDX Boundaries (Region/Zone/Woreda)', 'icon': Icons.map_outlined, 'status': 'Ready for Assignment'},
    {'name': 'Farm Geofencing & Mapping', 'icon': Icons.agriculture_outlined, 'status': 'Ready for Assignment'},
    {'name': '16-Day Weather & Meteogram', 'icon': Icons.cloud_outlined, 'status': 'Ready for Assignment'},
    {'name': 'SPI Drought Risk Engine', 'icon': Icons.water_drop_outlined, 'status': 'Ready for Assignment'},
    {'name': 'GloFAS Flood Inundation', 'icon': Icons.flood_outlined, 'status': 'Ready for Assignment'},
    {'name': 'MODIS/Sentinel NDVI Vegetation', 'icon': Icons.eco_outlined, 'status': 'Ready for Assignment'},
    {'name': 'FAO Desert Locust Tracking', 'icon': Icons.pest_control_outlined, 'status': 'Ready for Assignment'},
    {'name': 'SoilGrids 250m Chemistry', 'icon': Icons.terrain_outlined, 'status': 'Ready for Assignment'},
    {'name': 'AI Crop Pathology & Leaf Diagnosis', 'icon': Icons.document_scanner_outlined, 'status': 'Ready for Assignment'},
    {'name': 'Multi-Hazard Risk Dashboard', 'icon': Icons.dashboard_outlined, 'status': 'Ready for Assignment'},
    {'name': 'Bilingual Alerts Inbox (Amharic/English)', 'icon': Icons.notifications_active_outlined, 'status': 'Ready for Assignment'},
    {'name': 'Belg/Kiremt Seasonal Analytics', 'icon': Icons.analytics_outlined, 'status': 'Ready for Assignment'},
    {'name': 'Workmanager Offline Background Sync', 'icon': Icons.sync_outlined, 'status': 'Ready for Assignment'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.spa, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'AgriEtech Early Warning Platform',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PROJECT INITIALIZED SUCCESSFULLY',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AgriEtech Mobile Client Architecture Ready',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Clean Architecture with Feature-First structure, Riverpod 2.x, Offline Hive NoSQL caching, and bilingual support (Amharic & English) configured.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scaffolded Feature Modules (Ready for Assignment):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final mod = modules[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(mod['icon'] as IconData, color: const Color(0xFF2E7D32), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          mod['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mod['status'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
