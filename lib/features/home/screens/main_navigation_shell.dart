import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/offline_telemetry_bar.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../farms/screens/farms_list_screen.dart';
import '../../risk/screens/risk_map_screen.dart';
import '../../sensors/screens/sensors_list_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import 'home_screen.dart';

/// State provider for active bottom navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// World-Class Enterprise Navigation Shell with Expert 5-Tab Organization Including Profile
class MainNavigationShell extends ConsumerStatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  /// Role-adaptive tab keys list based on authenticated user
  static List<String> getNavTabLabels(AuthState authState) {
    if (authState.isFarmer) {
      return const ['Home', 'Farms', 'Weather', 'Risks', 'Profile'];
    } else if (authState.isDevelopmentAgent) {
      return const ['Home', 'Farms', 'Sensors', 'Risks', 'Profile'];
    } else if (authState.isResearcher) {
      return const ['Home', 'Analytics', 'Weather', 'Risks', 'Profile'];
    } else {
      return const ['Home', 'Sensors', 'Analytics', 'Risks', 'Profile'];
    }
  }

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  final Map<int, Widget> _pageCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      Future.microtask(() => ref.read(navigationIndexProvider.notifier).state = widget.initialIndex);
    }
  }

  /// Role-adaptive page list based on authenticated user
  List<_NavTabConfig> _getNavTabs(AuthState authState) {
    if (authState.isFarmer) {
      return const [
        _NavTabConfig('home', 'Home', Icons.home_outlined, Icons.home_rounded, HomeScreen()),
        _NavTabConfig('farms', 'Farms', Icons.agriculture_outlined, Icons.agriculture_rounded, FarmsListScreen()),
        _NavTabConfig('weather', 'Weather', Icons.wb_cloudy_outlined, Icons.wb_cloudy_rounded, WeatherScreen()),
        _NavTabConfig('risks', 'Risks', Icons.radar_outlined, Icons.radar_rounded, RiskMapScreen()),
        _NavTabConfig('profile', 'Profile', Icons.person_outline_rounded, Icons.person_rounded, ProfileScreen()),
      ];
    } else if (authState.isDevelopmentAgent) {
      return const [
        _NavTabConfig('home', 'Home', Icons.home_outlined, Icons.home_rounded, HomeScreen()),
        _NavTabConfig('farms', 'Farms', Icons.agriculture_outlined, Icons.agriculture_rounded, FarmsListScreen()),
        _NavTabConfig('sensors', 'Sensors', Icons.sensors_outlined, Icons.sensors_rounded, SensorsListScreen()),
        _NavTabConfig('risks', 'Risks', Icons.radar_outlined, Icons.radar_rounded, RiskMapScreen()),
        _NavTabConfig('profile', 'Profile', Icons.person_outline_rounded, Icons.person_rounded, ProfileScreen()),
      ];
    } else if (authState.isResearcher) {
      return const [
        _NavTabConfig('home', 'Home', Icons.home_outlined, Icons.home_rounded, HomeScreen()),
        _NavTabConfig('analytics', 'Analytics', Icons.insights_outlined, Icons.insights_rounded, AnalyticsScreen()),
        _NavTabConfig('weather', 'Weather', Icons.wb_cloudy_outlined, Icons.wb_cloudy_rounded, WeatherScreen()),
        _NavTabConfig('risks', 'Risks', Icons.radar_outlined, Icons.radar_rounded, RiskMapScreen()),
        _NavTabConfig('profile', 'Profile', Icons.person_outline_rounded, Icons.person_rounded, ProfileScreen()),
      ];
    } else {
      // Officers & National Administrator
      return const [
        _NavTabConfig('home', 'Home', Icons.home_outlined, Icons.home_rounded, HomeScreen()),
        _NavTabConfig('sensors', 'Sensors', Icons.sensors_outlined, Icons.sensors_rounded, SensorsListScreen()),
        _NavTabConfig('analytics', 'Analytics', Icons.insights_outlined, Icons.insights_rounded, AnalyticsScreen()),
        _NavTabConfig('risks', 'Risks', Icons.radar_outlined, Icons.radar_rounded, RiskMapScreen()),
        _NavTabConfig('profile', 'Profile', Icons.person_outline_rounded, Icons.person_rounded, ProfileScreen()),
      ];
    }
  }

  Widget _getPage(int index, List<_NavTabConfig> tabs) {
    return _pageCache.putIfAbsent(index, () {
      if (index >= 0 && index < tabs.length) {
        return tabs[index].page;
      }
      return const HomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentIndex = ref.watch(navigationIndexProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final alertsState = ref.watch(alertListProvider);
    final activeAlertsCount = alertsState.maybeWhen(
      data: (list) => list.where((a) => a.isActive && !a.isRead).length,
      orElse: () => 0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = _getNavTabs(authState);

    // Safety: clamp index to tab range
    final safeIndex = currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: Column(
        children: [
          const OfflineTelemetryBar(),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(safeIndex),
              child: _getPage(safeIndex, tabs),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final localizedLabel = AppStrings.tr(tab.labelKey, lang: currentLang);
                return _buildNavItem(
                  context,
                  index: index,
                  currentIndex: safeIndex,
                  icon: tab.icon,
                  selectedIcon: tab.selectedIcon,
                  label: localizedLabel.isNotEmpty ? localizedLabel : tab.fallbackLabel,
                  badgeCount: tab.labelKey == 'alerts' ? activeAlertsCount : 0,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$label tab',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        borderRadius: AppRadii.roundedLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E3825) : AppTheme.primaryContainer)
                : Colors.transparent,
            borderRadius: AppRadii.roundedPill,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppTheme.errorColor,
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: isSelected ? -0.2 : 0,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration for a single bottom navigation tab
class _NavTabConfig {
  final String labelKey;
  final String fallbackLabel;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  const _NavTabConfig(
    this.labelKey,
    this.fallbackLabel,
    this.icon,
    this.selectedIcon,
    this.page,
  );
}

/// Global Smart Navigation Helper to cleanly switch tabs or push routes
class NavigationHelper {
  static void navigateOrSwitchTab(BuildContext context, WidgetRef ref, String route) {
    final authState = ref.read(authProvider);
    final tabs = MainNavigationShell.getNavTabLabels(authState);

    String? targetLabel;
    if (route == '/home') targetLabel = 'Home';
    if (route == '/farms') targetLabel = 'Farms';
    if (route == '/weather') targetLabel = 'Weather';
    if (route == '/risks') targetLabel = 'Risks';
    if (route == '/sensors') targetLabel = 'Sensors';
    if (route == '/analytics') targetLabel = 'Analytics';
    if (route == '/profile') targetLabel = 'Profile';

    if (targetLabel != null && tabs.contains(targetLabel)) {
      final targetIndex = tabs.indexOf(targetLabel);
      ref.read(navigationIndexProvider.notifier).state = targetIndex;
      return;
    }

    context.push(route);
  }
}

