import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// State provider for offline network resilience status
final offlineStatusProvider = StateProvider<bool>((ref) => false);
final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

/// Non-intrusive field resilience HUD bar for remote agronomic operations
class OfflineTelemetryBar extends ConsumerWidget {
  final VoidCallback? onSync;

  const OfflineTelemetryBar({super.key, this.onSync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStatusProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    if (!isOffline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isOffline ? const Color(0xFF92400E) : const Color(0xFF1E3A8A),
        border: Border(
          bottom: BorderSide(
            color: isOffline ? const Color(0xFFD97706) : const Color(0xFF3B82F6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOffline
                  ? 'Offline Mode • Field Telemetry Cached • $pendingCount queued'
                  : 'Syncing $pendingCount pending items to national registry...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onSync != null) {
                onSync!();
              } else {
                ref.read(pendingSyncCountProvider.notifier).state = 0;
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SYNC NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Canonical design system alias
typedef AppOfflineTelemetryBar = OfflineTelemetryBar;
