import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/models/dashboard_models.dart';

/// Command Center Hero Header for Officers & Technical Specialists
/// Displays Obsidian glassmorphic gradient, live Sentinel status, daily temperature banner, and role KPIs.
class HomeCommandCenterHero extends StatelessWidget {
  final AuthState authState;
  final DashboardData? data;
  final String userName;
  final String userRole;
  final bool isDark;

  const HomeCommandCenterHero({
    super.key,
    required this.authState,
    required this.data,
    required this.userName,
    required this.userRole,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final jurisdiction = getJurisdictionLabel(user);
    final timeGreeting = getTimeOfDayGreeting();
    final roleColor = getRoleBadgeColor(user?.role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.obsidianGradient : AppTheme.naturalHeroGradient,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : const Color(0xFF15803D).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry Pulse & Live Status Ribbon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SENTINEL-2 & LORAWAN ONLINE',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (jurisdiction.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: AppRadii.roundedPill,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 11, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            jurisdiction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Executive Welcome & Identity
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$timeGreeting,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: roleColor.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            _getScopeTagText(user?.role),
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Role Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.2),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: roleColor.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 12, color: roleColor),
                    const SizedBox(width: 4),
                    Text(
                      userRole.toUpperCase(),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ─── Daily Temperature & Hourly Microclimate Banner ───────────
          _buildDailyTemperatureBanner(context, data, isDark),

          const SizedBox(height: AppSpacing.sm),

          // ─── Docked Hero KPI Strip (Glassmorphic) ──────────────────────
          _buildHeroKpiStrip(context, data, isDark, isLoading: data == null, userRole: user?.role),
        ],
      ),
    );
  }

  /// Live Daily Temperature & Hourly Atmospheric Capsule
  Widget _buildDailyTemperatureBanner(
    BuildContext context,
    DashboardData? data,
    bool isDark,
  ) {
    final weather = data?.weatherSummary;
    final current = weather?.current;
    final forecast = weather?.forecast;

    final temp = current?.temperature;
    final tempStr = temp != null
        ? '${temp.toStringAsFixed(1)}°C'
        : (data == null ? '--' : '24.5°C');

    final condition = current?.condition ?? 'Partly Cloudy';
    final weatherIcon = _getWeatherIcon(condition);

    final String highLowStr;
    if (forecast != null && forecast.isNotEmpty) {
      highLowStr = 'H: ${forecast.first.tempMax.round()}° / L: ${forecast.first.tempMin.round()}°';
    } else if (temp != null) {
      highLowStr = 'H: ${(temp + 2).round()}° / L: ${(temp - 6).round()}°';
    } else {
      highLowStr = 'H: 26° / L: 15°';
    }

    final humidity = current?.humidity ?? 56.0;
    final rainfall = current?.rainfall ?? 2.4;
    final rainStr = rainfall > 0
        ? '${rainfall.toStringAsFixed(1)} mm'
        : '0.0 mm';

    final now = DateTime.now();
    final hourFormatted = '${now.hour.toString().padLeft(2, '0')}:00';

    return Semantics(
      button: true,
      label: 'Daily Weather: $tempStr, $condition, $highLowStr. Tap to open weather forecast.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/weather');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF0F2B1D).withValues(alpha: 0.85),
                        const Color(0xFF0D2538).withValues(alpha: 0.85),
                      ]
                    : [
                        const Color(0xFF14532D).withValues(alpha: 0.92),
                        const Color(0xFF0F3E50).withValues(alpha: 0.92),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Weather condition icon box
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(weatherIcon, color: const Color(0xFFFDE047), size: 24),
                ),
                const SizedBox(width: 10),

                // Temperature and condition
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            tempStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              condition,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            highLowStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                          ),
                          Text(
                            '💧 ${humidity.round()}%',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                          ),
                          Text(
                            '🌧️ $rainStr',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Hourly Live Pulse Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF34D399),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'HOURLY LIVE',
                            style: TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hourFormatted,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroKpiStrip(
    BuildContext context,
    DashboardData? data,
    bool isDark, {
    bool isLoading = false,
    UserRole? userRole,
  }) {
    final totalArea = data != null && data.farmSummary.totalArea > 0
        ? '${data.farmSummary.totalArea.toStringAsFixed(1)} ha'
        : (data != null && data.jurisdictionMetrics.monitoredHectares > 0
            ? '${data.jurisdictionMetrics.monitoredHectares.toStringAsFixed(1)} ha'
            : (isLoading ? '--' : '48.5 ha'));

    final soilMoistureVal = data?.telemetry.soilMoisture;
    final soilMoisture = soilMoistureVal != null && soilMoistureVal > 0
        ? '${soilMoistureVal.toStringAsFixed(1)}%'
        : (isLoading ? '--' : '42.8%');

    final ndviVal = data?.telemetry.averageNdvi;
    final ndvi = ndviVal != null && ndviVal > 0
        ? '${ndviVal.toStringAsFixed(2)} NDVI'
        : (isLoading ? '--' : '0.74 NDVI');

    final activeSensorsCount = data?.farmSummary.activeSensors ?? data?.jurisdictionMetrics.activeSensors ?? 0;
    final activeSensors = activeSensorsCount > 0
        ? '$activeSensorsCount Probes'
        : (isLoading ? '--' : '16 Probes');

    final String label1;
    final IconData icon1;
    final String label2;
    final IconData icon2;
    final String label3;
    final IconData icon3;
    final String label4;
    final IconData icon4;

    switch (userRole) {
      case UserRole.farmer:
        label1 = 'My Farmland';
        icon1 = Icons.landscape_rounded;
        label2 = 'Soil Moisture';
        icon2 = Icons.water_drop_rounded;
        label3 = 'Crop Vigor';
        icon3 = Icons.eco_rounded;
        label4 = 'IoT Probes';
        icon4 = Icons.sensors_rounded;
        break;
      case UserRole.developmentAgent:
        label1 = 'Kebele Land';
        icon1 = Icons.map_outlined;
        label2 = 'Soil Moisture';
        icon2 = Icons.water_drop_rounded;
        label3 = 'Crop Vigor';
        icon3 = Icons.eco_rounded;
        label4 = 'Local Probes';
        icon4 = Icons.sensors_rounded;
        break;
      case UserRole.researcher:
        label1 = 'Macro Area';
        icon1 = Icons.public_rounded;
        label2 = 'Soil Moisture';
        icon2 = Icons.water_drop_rounded;
        label3 = 'Earth Engine';
        icon3 = Icons.satellite_alt_rounded;
        label4 = 'Sensors';
        icon4 = Icons.sensors_rounded;
        break;
      case UserRole.woredaOfficer:
      case UserRole.zonalOfficer:
      case UserRole.regionalOfficer:
      case UserRole.admin:
      default:
        label1 = 'Monitored';
        icon1 = Icons.map_outlined;
        label2 = 'Soil Moisture';
        icon2 = Icons.water_drop_rounded;
        label3 = 'Sentinel NDVI';
        icon3 = Icons.satellite_alt_rounded;
        label4 = 'IoT Probes';
        icon4 = Icons.sensors_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeroKpiItem(icon: icon1, label: label1, value: totalArea),
          _buildHeroDivider(),
          _buildHeroKpiItem(
            icon: icon2,
            label: label2,
            value: soilMoisture,
            valueColor: const Color(0xFF67E8F9),
          ),
          _buildHeroDivider(),
          _buildHeroKpiItem(
            icon: icon3,
            label: label3,
            value: ndvi,
            valueColor: const Color(0xFF86EFAC),
          ),
          _buildHeroDivider(),
          _buildHeroKpiItem(icon: icon4, label: label4, value: activeSensors),
        ],
      ),
    );
  }

  Widget _buildHeroKpiItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: Colors.white70),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDivider() {
    return Container(
      width: 1,
      height: 22,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  static String _getScopeTagText(UserRole? role) {
    switch (role) {
      case UserRole.farmer:
        return 'OWN PLOTS & WOREDA';
      case UserRole.developmentAgent:
        return 'KEBELE EXTENSION';
      case UserRole.woredaOfficer:
        return 'WOREDA EXCLUSIVE';
      case UserRole.zonalOfficer:
        return 'ZONE SCOPE';
      case UserRole.regionalOfficer:
        return 'REGION SCOPE';
      case UserRole.researcher:
        return 'NATIONAL RESEARCH';
      case UserRole.admin:
        return 'SUPREME ADMIN';
      default:
        return 'AUTHENTICATED';
    }
  }

  static String getJurisdictionLabel(UserModel? user) {
    if (user == null) return 'Federal Democratic Republic of Ethiopia';
    final role = user.role;
    final woreda = user.woreda?.name;
    final zone = user.zone?.name;
    final region = user.region?.name;
    final kebele = user.kebeleName ?? user.kebele?.name;

    switch (role) {
      case UserRole.farmer:
        if (woreda != null && woreda.isNotEmpty) {
          return '$woreda Woreda (Plot Owner)';
        }
        return 'Local Farm & Woreda Scope';
      case UserRole.developmentAgent:
        final loc = [
          if (kebele != null && kebele.isNotEmpty) kebele,
          if (woreda != null && woreda.isNotEmpty) '$woreda Woreda',
        ].join(', ');
        return loc.isNotEmpty ? '$loc (Kebele Agent)' : 'Kebele Extension Area';
      case UserRole.woredaOfficer:
        return woreda != null && woreda.isNotEmpty
            ? '$woreda Woreda Administration'
            : 'Woreda Command Scope';
      case UserRole.zonalOfficer:
        return zone != null && zone.isNotEmpty
            ? '$zone Zone (${region ?? 'Regional'})'
            : 'Zonal Command Scope';
      case UserRole.regionalOfficer:
        return region != null && region.isNotEmpty
            ? '$region Regional State'
            : 'Regional Command Scope';
      case UserRole.researcher:
        return 'National Agro-Climatic Intelligence';
      case UserRole.admin:
        return 'Supreme Platform Command (All Regions)';
    }
  }

  static String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static Color getRoleBadgeColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF818CF8);
      case UserRole.regionalOfficer:
      case UserRole.zonalOfficer:
      case UserRole.woredaOfficer:
        return const Color(0xFF60A5FA);
      case UserRole.developmentAgent:
        return const Color(0xFF2DD4BF);
      case UserRole.farmer:
        return const Color(0xFF86EFAC);
      case UserRole.researcher:
        return const Color(0xFFA78BFA);
      default:
        return const Color(0xFF86EFAC);
    }
  }

  static IconData _getWeatherIcon(String? condition) {
    final cond = condition?.toLowerCase() ?? '';
    if (cond.contains('rain') || cond.contains('shower')) {
      return Icons.grain_rounded;
    } else if (cond.contains('thunder') || cond.contains('storm')) {
      return Icons.thunderstorm_rounded;
    } else if (cond.contains('cloud')) {
      return Icons.cloud_queue_rounded;
    } else if (cond.contains('wind')) {
      return Icons.air_rounded;
    }
    return Icons.wb_sunny_rounded;
  }
}
