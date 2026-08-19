///
/// @file alert_detail_screen.dart
/// @feature alerts
/// @description Full bilingual advisory detail — Amharic & English body, timestamp, location.
/// @author UI/Feature Developer (alerts)
///
library alert_detail_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/alert_model.dart';
import '../providers/alerts_provider.dart';

class AlertDetailScreen extends ConsumerWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(alertsProvider);
    final alerts = alertsState.alerts;
    final alert = alerts
        .where((a) => a.id == alertId)
        .cast<AlertModel?>()
        .firstWhere((a) => a != null, orElse: () => null);

    if (alert == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Advisory')),
        body: const Center(
          child: Text('This advisory is no longer available offline.'),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Advisory Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _severityColor(alert.severity),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  alert.hazardType,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              alert.titleEn,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Text(alert.woredaId),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(dateFormat.format(alert.createdAt)),
              ],
            ),
            const Divider(height: 32),
            if (alert.messageEn.isNotEmpty) ...[
              Text('English', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(
                alert.messageEn,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],
            if (alert.titleAm.isNotEmpty || alert.messageAm.isNotEmpty) ...[
              Text('አማርኛ', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              if (alert.titleAm.isNotEmpty)
                Text(
                  alert.titleAm,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (alert.messageAm.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  alert.messageAm,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'HIGH':
        return const Color(0xFFF57C00);
      case 'MEDIUM':
      case 'MODERATE':
        return const Color(0xFFFBC02D);
      case 'LOW':
      default:
        return const Color(0xFF388E3C);
    }
  }
}
