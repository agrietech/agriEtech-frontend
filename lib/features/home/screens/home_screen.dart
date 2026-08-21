import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../auth/providers/auth_provider.dart';
import '../../ai_voice/presentation/widgets/ai_assistant_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.fullName ?? 'Agricultural Leader';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const AgriEtechLogo.horizontal(
          size: 32,
          showTagline: false,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Alerts',
            onPressed: () => context.push('/alerts'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      userRole,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 20),
                    SizedBox(width: 10),
                    Text('Security & Password'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.errorColor, size: 20),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } else if (value == 'profile') {
                context.push('/change-password');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High-Tech Hero Banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.techHeaderGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Icon(
                      Icons.satellite_alt,
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Satellite Status Pill
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.telemetryNdvi.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.telemetryNdvi,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'SENTINEL-2 • LIVE TELEMETRY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              userRole.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Agro-Intelligence Quick Telemetry Ribbon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickTelemetryItem(
                                icon: Icons.radar,
                                label: 'Early Warning',
                                status: 'Active',
                                statusColor: AppTheme.telemetryNdvi,
                              ),
                              Container(height: 28, width: 1, color: Colors.white24),
                              _buildQuickTelemetryItem(
                                icon: Icons.sensors,
                                label: 'IoT Sensors',
                                status: 'Online',
                                statusColor: const Color(0xFF38BDF8),
                              ),
                              Container(height: 28, width: 1, color: Colors.white24),
                              _buildQuickTelemetryItem(
                                icon: Icons.eco,
                                label: 'Crop Health',
                                status: 'Optimal',
                                statusColor: AppTheme.telemetryNdvi,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Features Grid Section
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agro-Intelligence Modules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E2E1E),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/dashboard'),
                        icon: const Icon(Icons.speed, size: 16),
                        label: const Text('Open Hub', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: [
                      _buildTechMenuCard(
                        context,
                        title: 'Operations Hub',
                        subtitle: 'Live analytics & telemetry',
                        badgeText: 'Live',
                        badgeColor: AppTheme.primaryColor,
                        icon: Icons.dashboard_outlined,
                        route: '/dashboard',
                        accentColor: AppTheme.primaryColor,
                      ),
                      if (RoleUtils.canManageFarms(user?.role))
                        _buildTechMenuCard(
                          context,
                          title: 'My Farms',
                          subtitle: 'Geofencing & Parcels',
                          badgeText: 'GIS',
                          badgeColor: AppTheme.primaryDark,
                          icon: Icons.agriculture_outlined,
                          route: '/farms',
                          accentColor: AppTheme.primaryDark,
                        ),
                      _buildTechMenuCard(
                        context,
                        title: 'Risk Command',
                        subtitle: 'Multi-hazard spatial map',
                        badgeText: 'Alerts',
                        badgeColor: AppTheme.warningColor,
                        icon: Icons.map_outlined,
                        route: '/risk-map',
                        accentColor: AppTheme.highRiskColor,
                      ),
                      _buildTechMenuCard(
                        context,
                        title: 'AI Crop Vision',
                        subtitle: 'Leaf disease scanner',
                        badgeText: 'AI Model',
                        badgeColor: AppTheme.secondaryColor,
                        icon: Icons.biotech_outlined,
                        route: '/diagnosis',
                        accentColor: AppTheme.secondaryColor,
                      ),
                      _buildTechMenuCard(
                        context,
                        title: 'Early Warnings',
                        subtitle: 'Drought & locust alerts',
                        badgeText: 'Realtime',
                        badgeColor: AppTheme.tertiaryColor,
                        icon: Icons.notifications_active_outlined,
                        route: '/alerts',
                        accentColor: AppTheme.tertiaryColor,
                      ),
                      _buildTechMenuCard(
                        context,
                        title: 'IoT Telemetry',
                        subtitle: 'Soil NPK & moisture',
                        badgeText: 'LoRaWAN',
                        badgeColor: AppTheme.telemetrySensor,
                        icon: Icons.sensors_outlined,
                        route: '/sensors',
                        accentColor: AppTheme.telemetrySensor,
                      ),
                      _buildTechMenuCard(
                        context,
                        title: 'Boundaries & GIS',
                        subtitle: 'Woreda parcel mapping',
                        badgeText: 'Centroids',
                        badgeColor: const Color(0xFF059669),
                        icon: Icons.public_outlined,
                        route: '/boundaries',
                        accentColor: const Color(0xFF059669),
                      ),
                      if (RoleUtils.canViewAnalytics(user?.role))
                        _buildTechMenuCard(
                          context,
                          title: 'Agro-Analytics',
                          subtitle: 'Trends & harvest reports',
                          badgeText: 'Insights',
                          badgeColor: const Color(0xFF4338CA),
                          icon: Icons.insights_outlined,
                          route: '/analytics',
                          accentColor: const Color(0xFF4338CA),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AiAssistantSheet.show(context),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.psychology, color: Color(0xFFF59E0B)),
        label: const Text(
          'Agri-AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget _buildQuickTelemetryItem({
    required IconData icon,
    required String label,
    required String status,
    required Color statusColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required String route,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: accentColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
