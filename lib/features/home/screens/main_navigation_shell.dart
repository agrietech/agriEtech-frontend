import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../ai_voice/presentation/widgets/ai_assistant_sheet.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../alerts/screens/alerts_list_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../farms/screens/farms_list_screen.dart';
import 'home_screen.dart';

/// State provider for active bottom navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// World-class modern Navigation Shell & Taskbar for AgriEtech
class MainNavigationShell extends ConsumerStatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      Future.microtask(() => ref.read(navigationIndexProvider.notifier).state = widget.initialIndex);
    }
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    FarmsListScreen(),
    AlertsListScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final activeAlertsCount = alertsState.maybeWhen(
      data: (list) => list.where((a) => a.isActive).length,
      orElse: () => 0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132213) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                _buildNavItem(
                  context,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                ),

                // 2. Farms & GIS
                _buildNavItem(
                  context,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.agriculture_outlined,
                  selectedIcon: Icons.agriculture_rounded,
                  label: 'My Farms',
                ),

                // 3. Center Highlight Action: Agri-AI Voice & Text Assistant
                _buildCenterAiAction(context, isDark),

                // 4. Early Warnings & Alerts
                _buildNavItem(
                  context,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.notifications_active_outlined,
                  selectedIcon: Icons.notifications_active_rounded,
                  label: 'Alerts',
                  badgeCount: activeAlertsCount,
                ),

                // 5. Operations Hub / Analytics
                _buildNavItem(
                  context,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.speed_outlined,
                  selectedIcon: Icons.speed_rounded,
                  label: 'Hub',
                ),
              ],
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
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).state = index;
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A20) : const Color(0xFFE8F5E9))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.errorColor,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAiAction(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => AiAssistantSheet.show(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0F3E14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.psychology,
          color: Color(0xFFF59E0B),
          size: 26,
        ),
      ),
    );
  }
}
