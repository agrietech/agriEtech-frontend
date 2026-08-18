///
/// @file alerts_inbox_screen.dart
/// @feature alerts
/// @description Alerts inbox matching the Stitch design: live-feed banner,
///   bilingual heading, All/Critical filter pills, and the alert card list.
/// @author UI/Feature Developer (alerts)
///
library alerts_inbox_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/alert_model.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_tile.dart';
import 'alert_detail_screen.dart';

class _Tokens {
  static const primaryGreen = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFFE8F5E9);
  static const criticalRed = Color(0xFFD32F2F);
  static const surfaceLight = Color(0xFFF8FAF9);
}

/// True = showing Critical-only, false = showing all alerts.
final _criticalOnlyFilterProvider = StateProvider<bool>((ref) => false);

class AlertsInboxScreen extends ConsumerWidget {
  const AlertsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    final isLive = ref.watch(socketConnectionProvider).valueOrNull ?? false;
    final criticalOnly = ref.watch(_criticalOnlyFilterProvider);

    return Scaffold(
      backgroundColor: _Tokens.surfaceLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(alertsProvider.notifier).refresh(),
          child: alertsAsync.when(
            data: (alerts) =>
                _buildBody(context, ref, alerts, isLive, criticalOnly),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                _buildBody(context, ref, const [], isLive, criticalOnly),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<AlertModel> allAlerts,
    bool isLive,
    bool criticalOnly,
  ) {
    final criticalCount =
        allAlerts.where((a) => a.severity == AlertSeverity.critical).length;
    final visible = criticalOnly
        ? allAlerts.where((a) => a.severity == AlertSeverity.critical).toList()
        : allAlerts;

    return ListView(
      children: [
        _buildLiveFeedBanner(isLive),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Early Warning Alerts / የቅድመ ማስጠንቀቂያ መልዕክቶች',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildFilterPills(
              ref, allAlerts.length, criticalCount, criticalOnly),
        ),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No advisories in this view')),
          )
        else
          ...visible.map(
            (alert) => AlertTile(
              alert: alert,
              onTap: () async {
                await ref.read(alertsProvider.notifier).markAsRead(alert.id);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => AlertDetailScreen(alertId: alert.id)),
                  );
                }
              },
              onPlayAudio:
                  () {}, // TODO: wire to an audio player once audioAdvisoryUrl is populated
              onOpenMitigationGuide:
                  () {}, // TODO: open mitigationGuideUrl (in-app viewer or browser)
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLiveFeedBanner(bool isLive) {
    return Container(
      width: double.infinity,
      color: isLive ? _Tokens.primaryLight : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle,
              size: 8, color: isLive ? _Tokens.primaryGreen : Colors.grey),
          const SizedBox(width: 6),
          Icon(Icons.bolt,
              size: 14,
              color: isLive ? _Tokens.primaryGreen : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            isLive
                ? 'CONNECTED TO MINISTRY OF AGRICULTURE LIVE FEED'
                : 'OFFLINE — SHOWING CACHED ALERTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLive ? _Tokens.primaryGreen : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(
      WidgetRef ref, int allCount, int criticalCount, bool criticalOnly) {
    return Row(
      children: [
        ChoiceChip(
          label: Text('All Alerts ($allCount)'),
          selected: !criticalOnly,
          selectedColor: _Tokens.primaryGreen,
          labelStyle:
              TextStyle(color: !criticalOnly ? Colors.white : Colors.black87),
          onSelected: (_) =>
              ref.read(_criticalOnlyFilterProvider.notifier).state = false,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          avatar: Icon(Icons.circle, size: 10, color: _Tokens.criticalRed),
          label: Text('Critical ($criticalCount)'),
          selected: criticalOnly,
          onSelected: (_) =>
              ref.read(_criticalOnlyFilterProvider.notifier).state = true,
        ),
      ],
    );
  }
}
