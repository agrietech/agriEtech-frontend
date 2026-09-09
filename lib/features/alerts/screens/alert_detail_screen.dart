import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/alert_models.dart';
import '../providers/alert_provider.dart';

/// Standardized, enterprise-grade screen for individual alert inspection,
/// hazard containment protocol tracking, and ground-truth validation.
class AlertDetailScreen extends ConsumerStatefulWidget {
  final String alertId;
  final AlertModel? initialAlert;

  const AlertDetailScreen({
    super.key,
    required this.alertId,
    this.initialAlert,
  });

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  String _selectedLanguage = 'en'; // 'en', 'am', 'om'
  final Set<int> _completedActionIndices = {};
  bool? _feedbackAccurate;
  final TextEditingController _feedbackNotesController = TextEditingController();
  bool _isSubmittingFeedback = false;
  bool _feedbackSubmitted = false;
  String? _feedbackSuccessMessage;

  @override
  void initState() {
    super.initState();
    // Auto mark as read on visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertListProvider.notifier).markAsRead(widget.alertId);
    });
  }

  @override
  void dispose() {
    _feedbackNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(singleAlertProvider(widget.alertId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert & Hazard Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Alert Details',
            onPressed: () => _shareAlert(alertAsync.value ?? widget.initialAlert),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Alert Data',
            onPressed: () {
              ref.invalidate(singleAlertProvider(widget.alertId));
            },
          ),
        ],
      ),
      body: alertAsync.when(
        data: (alert) => _buildContent(context, alert),
        loading: () {
          if (widget.initialAlert != null) {
            return _buildContent(context, widget.initialAlert!);
          }
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: ListSkeleton(count: 4),
          );
        },
        error: (error, stack) {
          if (widget.initialAlert != null) {
            return _buildContent(context, widget.initialAlert!);
          }
          return AppErrorView(
            icon: Icons.error_outline,
            title: 'Failed to load alert details',
            message: error.toString(),
            onRetry: () => ref.invalidate(singleAlertProvider(widget.alertId)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AlertModel alert) {
    final visuals = _getHazardVisuals(alert.hazardType, alert.severity);
    final actions = alert.actionItems.isNotEmpty
        ? alert.actionItems
        : visuals.defaultChecklist;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(singleAlertProvider(widget.alertId));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // 1. Hero Hazard Banner
          _buildHeroHeader(context, alert, visuals),
          const SizedBox(height: AppSpacing.md),

          // 2. Multilingual Language Selector & Message Card
          _buildMessageCard(context, alert, visuals),
          const SizedBox(height: AppSpacing.md),

          // 3. Woreda & Jurisdictional Action Center
          _buildJurisdictionCard(context, alert, visuals),
          const SizedBox(height: AppSpacing.md),

          // 4. Interactive Containment & Agronomic Action Protocol
          _buildChecklistSection(context, actions, visuals),
          const SizedBox(height: AppSpacing.md),

          // 5. Linked Agronomic Advisories (if any)
          if (alert.advisories.isNotEmpty) ...[
            _buildAdvisoriesSection(context, alert.advisories, visuals),
            const SizedBox(height: AppSpacing.md),
          ],

          // 6. Multi-Channel Transmission & Delivery Telemetry
          _buildDeliveryTelemetryCard(context, alert, visuals),
          const SizedBox(height: AppSpacing.md),

          // 7. Ground-Truth Field Validation Widget
          _buildGroundTruthFeedbackWidget(context, alert, visuals),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    AlertModel alert,
    _HazardVisuals visuals,
  ) {
    final isCritical = alert.severity.toUpperCase() == 'CRITICAL';

    return Container(
      decoration: BoxDecoration(
        gradient: visuals.gradient,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.soft(),
      ),
      child: Stack(
        children: [
          // Decorative background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              visuals.icon,
              size: 150,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Hazard Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(visuals.icon, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            visuals.badgeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Severity Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCritical ? Colors.red.shade900 : Colors.black.withValues(alpha: 0.35),
                        borderRadius: AppRadii.roundedSm,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        alert.severity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    // Live Backend Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900.withValues(alpha: 0.6),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                          SizedBox(width: 5),
                          Text(
                            'LIVE BACKEND',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Title
                Text(
                  alert.getTitle(_selectedLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),

                // Meta row: Sent date, Priority, Active
                Row(
                  children: [
                    Icon(Icons.access_time_filled, size: 14, color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(width: 5),
                    Text(
                      DateFormatter.formatRelativeSafe(alert.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: AppRadii.roundedXs,
                      ),
                      child: Text(
                        'Priority ${alert.priority}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (alert.affectedAreaKm2 != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Text(
                          '${alert.affectedAreaKm2!.toStringAsFixed(1)} km²',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    AlertModel alert,
    _HazardVisuals visuals,
  ) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multilingual Toggle Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.translate, size: 18, color: AppTheme.primaryColor),
                    SizedBox(width: 6),
                    Text(
                      'Emergency Transmission',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                  ],
                ),
                // Language Segmented Selector
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLangButton('en', 'EN'),
                      _buildLangButton('am', 'አማ'),
                      _buildLangButton('om', 'ORO'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Message Body
            Text(
              alert.getMessage(_selectedLanguage),
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            if (alert.validUntil != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event_available, size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Valid until: ${DateFormatter.formatDateTimeSafe(alert.validUntil)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildJurisdictionCard(
    BuildContext context,
    AlertModel alert,
    _HazardVisuals visuals,
  ) {
    final woredaName = alert.woreda?.name ?? 'Federal Coverage / National Extent';
    final region = alert.woreda?.region ?? 'Ethiopian Agro-Ecological Basin';
    final zone = alert.woreda?.zone;

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        woredaName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                      Text(
                        zone != null ? '$zone, $region' : region,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Direct Navigation Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/farms');
                  },
                  icon: const Icon(Icons.agriculture, size: 16),
                  label: const Text('Inspect Farms'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/risks');
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View Risk Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: visuals.color,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/disasters');
                  },
                  icon: const Icon(Icons.satellite_alt, size: 16),
                  label: const Text('Satellite Telemetry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey.shade800,
                    side: BorderSide(color: Colors.blueGrey.shade300),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection(
    BuildContext context,
    List<String> actions,
    _HazardVisuals visuals,
  ) {
    final completedCount = _completedActionIndices.length;
    final totalCount = actions.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: visuals.color.withValues(alpha: 0.3)),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, color: visuals.color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    visuals.protocolHeader,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: visuals.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Development agents and farm managers must verify containment actions below:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: visuals.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(visuals.color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount of $totalCount actions confirmed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: visuals.color,
                  ),
                ),
                if (completedCount == totalCount && totalCount > 0)
                  const Text(
                    '✓ All protocols completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20),

            // Checklist Items
            ...actions.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final isChecked = _completedActionIndices.contains(idx);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _completedActionIndices.remove(idx);
                    } else {
                      _completedActionIndices.add(idx);
                    }
                  });
                },
                borderRadius: AppRadii.roundedSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: visuals.color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _completedActionIndices.add(idx);
                            } else {
                              _completedActionIndices.remove(idx);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: isChecked ? Colors.grey.shade500 : Colors.black87,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisoriesSection(
    BuildContext context,
    List<AlertAdvisory> advisories,
    _HazardVisuals visuals,
  ) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.science, color: Color(0xFF0D9488), size: 22),
                SizedBox(width: 8),
                Text(
                  'Scientific Agronomy Advisories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...advisories.map((adv) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.06),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (adv.title != null)
                      Text(
                        adv.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF134E4A),
                        ),
                      ),
                    if (adv.cropType != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Target Crop: ${adv.cropType}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF115E59),
                          ),
                        ),
                      ),
                    ],
                    if (adv.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        adv.description!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ],
                    if (adv.recommendation != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF0D9488)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              adv.recommendation!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF115E59),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTelemetryCard(
    BuildContext context,
    AlertModel alert,
    _HazardVisuals visuals,
  ) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(color: AppTheme.borderLight),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cell_tower, color: AppTheme.primaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  'Multi-Channel Dispatch Telemetry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Synchronized across redundant rural broadcast gateways:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),

            // Channels Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChannelBadge(
                  icon: Icons.sms_outlined,
                  channel: 'SMS Gateway',
                  status: 'Active (Ethio Telecom)',
                  color: Colors.blue.shade700,
                ),
                _buildChannelBadge(
                  icon: Icons.notifications_active_outlined,
                  channel: 'FCM Push',
                  status: 'Delivered',
                  color: Colors.orange.shade700,
                ),
                _buildChannelBadge(
                  icon: Icons.dialpad,
                  channel: 'USSD *884#',
                  status: 'Broadcast Ready',
                  color: Colors.teal.shade700,
                ),
                _buildChannelBadge(
                  icon: Icons.wifi_tethering,
                  channel: 'WebSocket',
                  status: 'Live Stream Active',
                  color: Colors.green.shade700,
                ),
              ],
            ),

            if (alert.targetPhones.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.contacts, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Direct target recipients: ${alert.targetPhones.length} registered farmers',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChannelBadge({
    required IconData icon,
    required String channel,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadii.roundedSm,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroundTruthFeedbackWidget(
    BuildContext context,
    AlertModel alert,
    _HazardVisuals visuals,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: BorderSide(
          color: _feedbackSubmitted
              ? const Color(0xFF15803D)
              : Colors.amber.shade700.withValues(alpha: 0.4),
        ),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: _feedbackSubmitted ? const Color(0xFF15803D) : Colors.amber.shade800,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Farmer Ground-Truth Validation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Your ground observations calibrate our satellite anomaly models and assist disaster relief teams:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),

            if (_feedbackSubmitted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D).withValues(alpha: 0.1),
                  borderRadius: AppRadii.roundedSm,
                  border: Border.all(color: const Color(0xFF15803D)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _feedbackSuccessMessage ?? 'Ground-truth feedback recorded and synced with backend.',
                        style: const TextStyle(
                          color: Color(0xFF14532D),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Is this hazard actively occurring in your field or locality?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _feedbackAccurate = true;
                        });
                      },
                      icon: Icon(
                        Icons.check_circle,
                        color: _feedbackAccurate == true ? Colors.white : const Color(0xFF15803D),
                        size: 18,
                      ),
                      label: Text(
                        'Yes, Accurate',
                        style: TextStyle(
                          color: _feedbackAccurate == true ? Colors.white : const Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _feedbackAccurate == true ? const Color(0xFF15803D) : Colors.transparent,
                        side: const BorderSide(color: Color(0xFF15803D)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _feedbackAccurate = false;
                        });
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: _feedbackAccurate == false ? Colors.white : Colors.red.shade700,
                        size: 18,
                      ),
                      label: Text(
                        'No / False Alarm',
                        style: TextStyle(
                          color: _feedbackAccurate == false ? Colors.white : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _feedbackAccurate == false ? Colors.red.shade700 : Colors.transparent,
                        side: BorderSide(color: Colors.red.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Notes field
              TextField(
                controller: _feedbackNotesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Field notes or specific damage observations (optional)...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.roundedSm,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Submit Feedback Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_feedbackAccurate == null || _isSubmittingFeedback)
                      ? null
                      : () => _submitFeedback(alert),
                  icon: _isSubmittingFeedback
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSubmittingFeedback ? 'Syncing with Server...' : 'Submit Ground-Truth Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedSm),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(AlertModel alert) async {
    if (_feedbackAccurate == null) return;
    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final repo = ref.read(alertRepositoryProvider);
      final response = await repo.submitFeedback(
        alert.id,
        accurate: _feedbackAccurate!,
        notes: _feedbackNotesController.text.trim(),
      );

      setState(() {
        _isSubmittingFeedback = false;
        _feedbackSubmitted = true;
        _feedbackSuccessMessage = 'Ground-truth verified at ${DateFormatter.formatDateTimeSafe(response.submittedAt)}! Thank you for contributing to national food security telemetry.';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback synchronized with Agricultural Command Center.'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmittingFeedback = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording feedback: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _shareAlert(AlertModel? alert) {
    if (alert == null) return;
    final title = alert.getTitle(_selectedLanguage);
    final message = alert.getMessage(_selectedLanguage);
    final woreda = alert.woreda?.name ?? 'National';
    final shareContent = '[AGRIETECH EMERGENCY ALERT]\n$title\nHazard: ${alert.hazardType} (${alert.severity})\nJurisdiction: $woreda\n\n$message';

    Clipboard.setData(ClipboardData(text: shareContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert text copied to clipboard! Ready to share via SMS or Telegram.'),
        backgroundColor: Color(0xFF15803D),
      ),
    );
  }

  _HazardVisuals _getHazardVisuals(String hazardType, String severity) {
    final sevUpper = severity.toUpperCase();
    final isCritical = sevUpper == 'CRITICAL';

    switch (hazardType.toUpperCase()) {
      case 'DROUGHT':
        return _HazardVisuals(
          color: const Color(0xFFEA580C),
          secondaryColor: const Color(0xFFC2410C),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFF9A3412), const Color(0xFFEA580C)]
                : [const Color(0xFFC2410C), const Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.water_drop_outlined,
          badgeLabel: 'DROUGHT HAZARD',
          protocolHeader: 'Drought Defense & Moisture Preservation Protocol',
          defaultChecklist: [
            'Initiate emergency deficit drip irrigation during cool evening hours (18:00–21:00).',
            'Apply thick organic biomass mulch (straw/crop residues, 7–10 cm) to stop evaporation.',
            'Reserve community retention ponds strictly for high-value staple survival parcels.',
            'Inspect shallow-rooted crops (maize, teff) for permanent wilting point stress.',
          ],
        );

      case 'FLOOD':
        return _HazardVisuals(
          color: const Color(0xFF0284C7),
          secondaryColor: const Color(0xFF0369A1),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFF075985), const Color(0xFF0284C7)]
                : [const Color(0xFF0369A1), const Color(0xFF38BDF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.flood,
          badgeLabel: 'FLASH FLOOD EMERGENCY',
          protocolHeader: 'Flood Diversion & Drainage Containment Protocol',
          defaultChecklist: [
            'Clear farm drainage channels and excavate contour trenches to divert runoff.',
            'Elevate harvested grain bags at least 1 meter above floor level in dry granaries.',
            'Relocate cattle, sheep, and machinery to higher elevation communal hillsides.',
            'Prepare post-flood prophylactic copper spray to prevent phytophthora root rot.',
          ],
        );

      case 'LOCUST_PEST':
      case 'LOCUST':
        return _HazardVisuals(
          color: const Color(0xFFDC2626),
          secondaryColor: const Color(0xFFB91C1C),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFF991B1B), const Color(0xFFDC2626)]
                : [const Color(0xFFB91C1C), const Color(0xFFEF4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.pest_control,
          badgeLabel: 'DESERT LOCUST SWARM',
          protocolHeader: 'Desert Locust Swarm Interception Protocol',
          defaultChecklist: [
            'Report hopper band coordinates to Woreda Emergency Agriculture Desk immediately.',
            'Conduct early morning scouting (06:00–08:00) when swarms are roosted and sluggish.',
            'Deploy targeted biopesticide spray barriers (Metarhizium acridum) along crop margins.',
            'Cover community open water wells and secure apiaries prior to aerial pesticide runs.',
          ],
        );

      case 'FROST':
        return _HazardVisuals(
          color: const Color(0xFF4F46E5),
          secondaryColor: const Color(0xFF3730A3),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFF312E81), const Color(0xFF4F46E5)]
                : [const Color(0xFF3730A3), const Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.ac_unit,
          badgeLabel: 'HIGHLAND FROST EVENT',
          protocolHeader: 'Highland Frost Mitigation Protocol',
          defaultChecklist: [
            'Smolder damp organic matter (straw/leaves) along upwind parcel borders before dawn.',
            'Cover tender seedlings and horticultural beds with polypropylene agro-textiles.',
            'Provide light evening sprinkler misting to release latent thermal energy during freezing.',
            'Delay nitrogen top-dressing until ground frost risk has completely passed.',
          ],
        );

      case 'HEAT_STRESS':
        return _HazardVisuals(
          color: const Color(0xFFD97706),
          secondaryColor: const Color(0xFFB45309),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFF92400E), const Color(0xFFD97706)]
                : [const Color(0xFFB45309), const Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.wb_sunny,
          badgeLabel: 'EXTREME HEAT STRESS',
          protocolHeader: 'Thermal Protection & Crop Shading Protocol',
          defaultChecklist: [
            'Install 35% shade netting or sorghum thatch hurdles over sensitive horticulture.',
            'Triple livestock hydration frequency with shaded water troughs in resting paddocks.',
            'Apply foliar potassium silicate spray to reinforce leaf cuticular wax against scorch.',
            'Halt plowing and manual herbicide applications between 11:30 and 15:30 peak heat.',
          ],
        );

      case 'VEGETATION_STRESS':
        return const _HazardVisuals(
          color: Color(0xFF65A30D),
          secondaryColor: Color(0xFF4D7C0F),
          gradient: LinearGradient(
            colors: [Color(0xFF3F6212), Color(0xFF65A30D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.grass,
          badgeLabel: 'VEGETATION VIGOR STRESS',
          protocolHeader: 'Canopy Recovery & Soil Nutrient Balancing Protocol',
          defaultChecklist: [
            'Cross-reference Sentinel-2 NDVI anomalies with ground leaf chlorosis patterns.',
            'Perform rapid soil test to identify active potassium or nitrogen leaching.',
            'Apply micro-dosed foliar zinc and urea solution to stimulate chlorophyll recovery.',
            'Inspect canopy underside for secondary spider mite or aphid colonies.',
          ],
        );

      case 'VOLCANIC_HAZARD':
      case 'VOLCANO':
        return const _HazardVisuals(
          color: Color(0xFF7C3AED),
          secondaryColor: Color(0xFF6D28D9),
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.volcano,
          badgeLabel: 'VOLCANIC ASH HAZARD',
          protocolHeader: 'Volcanic Ash Fallout Containment Protocol',
          defaultChecklist: [
            'Confine livestock under covered shelters to prevent ash ingestion and respiratory distress.',
            'Wash accumulated tephra and ash gently off crop leaves with low-pressure water.',
            'Cover rural water harvesting reservoirs to prevent fluoride contamination.',
            'Equip farm field personnel with protective dust masks during urgent field containment.',
          ],
        );

      default:
        return _HazardVisuals(
          color: const Color(0xFF15803D),
          secondaryColor: const Color(0xFF166534),
          gradient: LinearGradient(
            colors: isCritical
                ? [const Color(0xFFB91C1C), const Color(0xFFDC2626)]
                : [const Color(0xFF14532D), const Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.warning_amber_rounded,
          badgeLabel: 'SMART ALERT ADVISORY',
          protocolHeader: 'Standard Agricultural Precautionary Protocol',
          defaultChecklist: [
            'Confirm alert parameters with local Kebele Development Agent.',
            'Conduct daily perimeter inspections across vulnerable crop parcels.',
            'Maintain updated emergency contact numbers for regional agriculture desks.',
            'Submit local ground observations using the feedback form below.',
          ],
        );
    }
  }
}

class _HazardVisuals {
  final Color color;
  final Color secondaryColor;
  final LinearGradient gradient;
  final IconData icon;
  final String badgeLabel;
  final String protocolHeader;
  final List<String> defaultChecklist;

  const _HazardVisuals({
    required this.color,
    required this.secondaryColor,
    required this.gradient,
    required this.icon,
    required this.badgeLabel,
    required this.protocolHeader,
    required this.defaultChecklist,
  });
}
