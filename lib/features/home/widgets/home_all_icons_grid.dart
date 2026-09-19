import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

/// Single Item Model for Home Icon Launchpad
class HomeIconItem {
  final String id;
  final IconData icon;
  final String labelEn;
  final String labelAm;
  final Color accentColor;
  final String route;
  final int badgeCount;

  const HomeIconItem({
    required this.id,
    required this.icon,
    required this.labelEn,
    required this.labelAm,
    required this.accentColor,
    required this.route,
    this.badgeCount = 0,
  });
}

/// Unified, Category-Free All-Icons Grid for EthioFarm Home
/// Displays all platform tools directly as icons without separating them into categories
/// and avoids cluttering text descriptions.
class HomeAllIconsGrid extends ConsumerWidget {
  final bool isDark;
  final int activeAlertsCount;

  const HomeAllIconsGrid({
    super.key,
    required this.isDark,
    this.activeAlertsCount = 0,
  });

  List<HomeIconItem> _getAllIcons() {
    return [
      const HomeIconItem(
        id: 'crop_doctor',
        icon: Icons.health_and_safety_rounded,
        labelEn: 'Crop Doctor',
        labelAm: 'የሰብል ሐኪም',
        accentColor: Color(0xFF10B981),
        route: '/create-diagnosis',
      ),
      const HomeIconItem(
        id: 'spray_window',
        icon: Icons.air_rounded,
        labelEn: 'Spray Window',
        labelAm: 'የመርጨት ሰዓት',
        accentColor: Color(0xFF0D9488),
        route: '/crop-protection/spray-window',
      ),
      const HomeIconItem(
        id: 'tank_mix',
        icon: Icons.science_rounded,
        labelEn: 'Tank Mix',
        labelAm: 'የኬሚካል ድብልቅ',
        accentColor: Color(0xFF6366F1),
        route: '/crop-protection/tank-mix',
      ),
      const HomeIconItem(
        id: 'seed_calc',
        icon: Icons.calculate_rounded,
        labelEn: 'Seed Calculator',
        labelAm: 'የዘር ስሌት',
        accentColor: Color(0xFFD97706),
        route: '/crop-protection/seed-calculator',
      ),
      const HomeIconItem(
        id: 'soil',
        icon: Icons.landscape_rounded,
        labelEn: 'Soil Health',
        labelAm: 'የአፈር ጤና',
        accentColor: Color(0xFF059669),
        route: '/soil-degradation',
      ),
      const HomeIconItem(
        id: 'farms',
        icon: Icons.agriculture_rounded,
        labelEn: 'My Farms',
        labelAm: 'እርሻዎቼ',
        accentColor: Color(0xFF16A34A),
        route: '/farms',
      ),
      const HomeIconItem(
        id: 'weather',
        icon: Icons.wb_sunny_rounded,
        labelEn: 'Weather',
        labelAm: 'የአየር ሁኔታ',
        accentColor: Color(0xFF0284C7),
        route: '/weather',
      ),
      HomeIconItem(
        id: 'alerts',
        icon: Icons.campaign_rounded,
        labelEn: 'Alerts',
        labelAm: 'ማስጠንቀቂያዎች',
        accentColor: const Color(0xFFDC2626),
        route: '/alerts',
        badgeCount: activeAlertsCount,
      ),
      const HomeIconItem(
        id: 'map',
        icon: Icons.map_rounded,
        labelEn: 'GIS Map',
        labelAm: 'ካርታ',
        accentColor: Color(0xFF2563EB),
        route: '/risks',
      ),
      const HomeIconItem(
        id: 'ethiofarm_ai',
        icon: Icons.auto_awesome_rounded,
        labelEn: 'EthioFarm AI',
        labelAm: 'ኢትዮፋርም AI',
        accentColor: Color(0xFF8B5CF6),
        route: '/ai-assistant',
      ),
      const HomeIconItem(
        id: 'hazards',
        icon: Icons.thunderstorm_rounded,
        labelEn: 'Hazards',
        labelAm: 'አደጋዎች',
        accentColor: Color(0xFFEA580C),
        route: '/disasters',
      ),
      const HomeIconItem(
        id: 'analytics',
        icon: Icons.analytics_rounded,
        labelEn: 'Analytics',
        labelAm: 'ትንታኔ',
        accentColor: Color(0xFF4338CA),
        route: '/analytics',
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLocaleProvider);
    final isAmharic = currentLang == 'am';
    final icons = _getAllIcons();

    final columns = context.responsive(compact: 3, medium: 4, expanded: 6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final item = icons[index];
        final label = isAmharic ? item.labelAm : item.labelEn;

        return Semantics(
          button: true,
          label: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(item.route);
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      item.accentColor.withValues(alpha: 0.28),
                                      item.accentColor.withValues(alpha: 0.12),
                                    ]
                                  : [
                                      item.accentColor.withValues(alpha: 0.16),
                                      item.accentColor.withValues(alpha: 0.08),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: item.accentColor.withValues(
                                alpha: isDark ? 0.45 : 0.35,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: item.accentColor.withValues(
                                  alpha: isDark ? 0.2 : 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            size: 28,
                            color: item.accentColor,
                          ),
                        ),
                        if (item.badgeCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade200 : const Color(0xFF1E293B),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
