import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/error/app_error.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../providers/auth_provider.dart';
import '../../boundaries/providers/boundary_provider.dart';

class RoleProfileOption {
  final String roleKey;
  final String title;
  final String amharicTitle;
  final String subtitle;
  final String fullDescription;
  final IconData icon;
  final Color color;
  final List<String> permissions;

  const RoleProfileOption({
    required this.roleKey,
    required this.title,
    required this.amharicTitle,
    required this.subtitle,
    required this.fullDescription,
    required this.icon,
    required this.color,
    required this.permissions,
  });
}

class RoleApplicationScreen extends ConsumerStatefulWidget {
  const RoleApplicationScreen({super.key});

  @override
  ConsumerState<RoleApplicationScreen> createState() => _RoleApplicationScreenState();
}

class _RoleApplicationScreenState extends ConsumerState<RoleApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _justificationController = TextEditingController();
  final _kebeleController = TextEditingController();

  String _selectedRole = 'DEVELOPMENT_AGENT';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  static const List<RoleProfileOption> _availableRoles = [
    RoleProfileOption(
      roleKey: 'DEVELOPMENT_AGENT',
      title: 'Development Agent (DA)',
      amharicTitle: 'የልማት ጣቢያ ባለሙያ',
      subtitle: 'Kebele farmer registries, field sensor deployment, and pest reports',
      fullDescription: 'Authorizes field agents to register local smallholders, calibrate LoRaWAN IoT telemetry sensors, and submit pest reports.',
      icon: Icons.support_agent_rounded,
      color: Color(0xFF0284C7),
      permissions: [
        'Manage Kebele farmer plot registries',
        'Deploy & monitor IoT soil sensors',
        'Submit field pest & locust sightings',
        'Broadcast kebele-level agronomic advisories',
      ],
    ),
    RoleProfileOption(
      roleKey: 'WOREDA_OFFICER',
      title: 'Woreda Agronomy Officer',
      amharicTitle: 'የወረዳ ግብርና መኮንን',
      subtitle: 'Woreda disaster alerts broadcast, USSD delivery, and GIS tracking',
      fullDescription: 'Grants administrative authority across the entire woreda jurisdiction, enabling USSD *212# emergency broadcast and RUSLE soil loss monitoring.',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFFD97706),
      permissions: [
        'Issue authoritative emergency smart alerts',
        'Trigger USSD *212# mass farmer broadcast',
        'Access woreda integrated spatial choropleth',
        'Manage woreda staff and field sensor networks',
      ],
    ),
    RoleProfileOption(
      roleKey: 'ZONAL_OFFICER',
      title: 'Zonal Agricultural Lead',
      amharicTitle: 'የዞን ግብርና መምሪያ',
      subtitle: 'Multi-woreda strategic analytics, drought index, and resource planning',
      fullDescription: 'Provides cross-woreda analytical oversight, SPI-3 drought indexing, river basin flood telemetry, and fertilizer allocation tools.',
      icon: Icons.domain_rounded,
      color: Color(0xFF7C3AED),
      permissions: [
        'Zonal aggregation & cross-woreda analytics',
        'Flood inundation threshold telemetry',
        'Strategic input & lime distribution planning',
        'Export official agricultural intelligence reports',
      ],
    ),
    RoleProfileOption(
      roleKey: 'REGIONAL_OFFICER',
      title: 'Regional Bureau Director',
      amharicTitle: 'የክልል ግብርና ቢሮ',
      subtitle: 'Regional food security dashboard, seismic risk, and telemetry',
      fullDescription: 'Comprehensive regional command access across all agricultural zones, seismic rift fault surveillance, and emergency mobilization.',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFDC2626),
      permissions: [
        'Regional integrated risk command center',
        'USGS earthquake & volcano hazard monitoring',
        'Food security & yield prediction intelligence',
        'Authorize regional emergency relief protocols',
      ],
    ),
    RoleProfileOption(
      roleKey: 'RESEARCHER',
      title: 'Agricultural Scientist / Researcher',
      amharicTitle: 'ተመራማሪ / ሳይንቲስት',
      subtitle: 'Satellite datasets, RUSLE soil erosion, and downscaled forecast exports',
      fullDescription: 'Designed for EIAR, universities, and research institutes to access raw Sentinel-2 MSI, Sentinel-1 SAR, DEM topography, and CSV exports.',
      icon: Icons.biotech_rounded,
      color: Color(0xFF0D9488),
      permissions: [
        'Export raw satellite observation time-series',
        'Run hyper-local digital soil profile queries',
        'Downscaled micro-climate climate simulations',
        'Train & validate crop disease vision models',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _staffIdController.dispose();
    _justificationController.dispose();
    _kebeleController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final hierarchy = ref.read(boundaryHierarchyProvider);
    if (hierarchy.selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your target Administrative Region'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(dioClientProvider);
      // Region, zone and woreda are all required by the form validators above
      // and are NOT NULL on the server, which also scopes reviewers by them.
      // Sending them unconditionally means a missing one surfaces as a clear
      // validation error instead of a silent omission.
      final payload = {
        'requestedRole': _selectedRole,
        'regionId': hierarchy.selectedRegion?.id,
        'regionName': hierarchy.selectedRegion?.name,
        'zoneId': hierarchy.selectedZone?.id,
        'zoneName': hierarchy.selectedZone?.name,
        'woredaId': hierarchy.selectedWoreda?.id,
        'woredaName': hierarchy.selectedWoreda?.name,
        if (_kebeleController.text.trim().isNotEmpty) 'kebeleName': _kebeleController.text.trim(),
        'organizationName': _organizationController.text.trim(),
        'staffIdNumber': _staffIdController.text.trim(),
        'justification': _justificationController.text.trim(),
      };

      await client.post(ApiConstants.roleRequests, data: payload);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        // DioClient does not normalize errors, so map here to surface the
        // server's own message (e.g. which boundary is missing) instead of a
        // raw DioException dump.
        final String message = e is DioException
            ? NetworkError.fromDioException(e).message
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $message'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currentRole = user?.role ?? UserRole.farmer;
    final hierarchy = ref.watch(boundaryHierarchyProvider);
    final hierarchyNotifier = ref.read(boundaryHierarchyProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const EthioFarmAppDrawer(),
      appBar: AppBar(
        title: const Text('Apply for Role', style: AppTypography.titleMedium),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Role Permissions & Access Guide',
            onPressed: () => _showRoleInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isSubmitted
            ? _buildSuccessView(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current User Status Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: AppTheme.naturalHeroGradient,
                          borderRadius: AppRadii.roundedLg,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Authenticated User',
                                    style: AppTypography.titleMedium.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Current Role: ${RoleUtils.getRoleDisplayName(currentRole)}',
                                    style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
                              decoration: const BoxDecoration(
                                color: AppTheme.telemetryNdvi,
                                borderRadius: AppRadii.roundedSm,
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Section 1: Choose Target Professional Role
                      const Text(
                        '1. Select Desired Professional Role',
                        style: AppTypography.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableRoles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final opt = _availableRoles[index];
                          final isSelected = opt.roleKey == _selectedRole;
                          return InkWell(
                            onTap: () => setState(() => _selectedRole = opt.roleKey),
                            borderRadius: AppRadii.roundedLg,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? opt.color.withValues(alpha: 0.08)
                                    : (isDark ? const Color(0xFF162518) : Colors.white),
                                borderRadius: AppRadii.roundedLg,
                                border: Border.all(
                                  color: isSelected ? opt.color : (isDark ? const Color(0xFF243B27) : Colors.grey.shade200),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: opt.color.withValues(alpha: 0.12),
                                      borderRadius: AppRadii.roundedSm,
                                    ),
                                    child: Icon(opt.icon, color: opt.color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${opt.title} (${opt.amharicTitle})',
                                                style: AppTypography.bodySmall.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? opt.color : null,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle, color: opt.color, size: 18),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          opt.subtitle,
                                          style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.screenPadding),

                      // Section 2: Administrative Jurisdiction Scope
                      const Text(
                        '2. Target Administrative Jurisdiction Scope',
                        style: AppTypography.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF162518) : Colors.white,
                          borderRadius: AppRadii.roundedLg,
                          border: Border.all(
                            color: isDark ? const Color(0xFF243B27) : Colors.grey.shade200,
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            final uniqueRegions = {for (final r in hierarchy.regions) r.id: r}.values.toList();
                            final uniqueZones = {for (final z in hierarchy.zones) z.id: z}.values.toList();
                            final uniqueWoredas = {for (final w in hierarchy.woredas) w.id: w}.values.toList();

                            return Column(
                              children: [
                                // Region
                                DropdownButtonFormField<String>(
                                  key: ValueKey('region_${hierarchy.selectedRegion?.id}'),
                                  isExpanded: true,
                                  initialValue: uniqueRegions.any((r) => r.id == hierarchy.selectedRegion?.id)
                                      ? hierarchy.selectedRegion?.id
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Region / ክልል *',
                                    prefixIcon: const Icon(Icons.public),
                                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                                  ),
                                  items: uniqueRegions.map((region) {
                                    return DropdownMenuItem<String>(
                                      value: region.id,
                                      child: Text(
                                        region.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList(),
                                  validator: (v) => v == null || v.isEmpty ? 'Please select target Region' : null,
                                  onChanged: (regionId) {
                                    if (regionId != null) {
                                      final region = uniqueRegions.firstWhere((r) => r.id == regionId);
                                      hierarchyNotifier.selectRegion(region);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Zone
                                DropdownButtonFormField<String>(
                                  key: ValueKey('zone_${hierarchy.selectedRegion?.id}_${hierarchy.selectedZone?.id}'),
                                  isExpanded: true,
                                  initialValue: uniqueZones.any((z) => z.id == hierarchy.selectedZone?.id)
                                      ? hierarchy.selectedZone?.id
                                      : null,
                                  hint: Text(
                                    hierarchy.selectedRegion == null ? 'Select Region first' : 'Select Zone',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Zone / ዞን',
                                    prefixIcon: const Icon(Icons.map_outlined),
                                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                                  ),
                                  items: uniqueZones.map((zone) {
                                    return DropdownMenuItem<String>(
                                      value: zone.id,
                                      child: Text(
                                        zone.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: hierarchy.selectedRegion == null
                                      ? null
                                      : (zoneId) {
                                          if (zoneId != null) {
                                            final zone = uniqueZones.firstWhere((z) => z.id == zoneId);
                                            hierarchyNotifier.selectZone(zone);
                                          }
                                        },
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Please select target Zone' : null,
                                ),
                                const SizedBox(height: 12),

                                // Woreda
                                DropdownButtonFormField<String>(
                                  key: ValueKey('woreda_${hierarchy.selectedZone?.id}_${hierarchy.selectedWoreda?.id}'),
                                  isExpanded: true,
                                  initialValue: uniqueWoredas.any((w) => w.id == hierarchy.selectedWoreda?.id)
                                      ? hierarchy.selectedWoreda?.id
                                      : null,
                                  hint: Text(
                                    hierarchy.selectedZone == null ? 'Select Zone first' : 'Select Woreda',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Woreda / ወረዳ',
                                    prefixIcon: const Icon(Icons.holiday_village_outlined),
                                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                                  ),
                                  items: uniqueWoredas.map((woreda) {
                                    return DropdownMenuItem<String>(
                                      value: woreda.id,
                                      child: Text(
                                        woreda.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: hierarchy.selectedZone == null
                                      ? null
                                      : (woredaId) {
                                          if (woredaId != null) {
                                            final woreda = uniqueWoredas.firstWhere((w) => w.id == woredaId);
                                            hierarchyNotifier.selectWoreda(woreda);
                                          }
                                        },
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Please select target Woreda' : null,
                                ),
                                const SizedBox(height: 12),

                                // Kebele
                                TextFormField(
                                  controller: _kebeleController,
                                  decoration: InputDecoration(
                                    labelText: 'Kebele/ቀበሌ',
                                    prefixIcon: const Icon(Icons.signpost_outlined),
                                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                    filled: true,
                                    fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.screenPadding),

                      // Section 3: Professional Affiliation & Verification
                      const Text(
                        '3. Professional Credentials',
                        style: AppTypography.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: AppRadii.roundedLg,
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _organizationController,
                              decoration: InputDecoration(
                                label: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Bureau / Institute'),
                                    Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                prefixIcon: const Icon(Icons.business_outlined),
                                border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                filled: true,
                                fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your organization name' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _staffIdController,
                              decoration: InputDecoration(
                                labelText: 'Staff ID',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                filled: true,
                                fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                              ),
                              // The server rejects a blank staff ID, so catch it
                              // here rather than surfacing a confusing 400 that
                              // also blames the organization name.
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter your staff / badge ID'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _justificationController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                label: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Role Scope'),
                                    Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                prefixIcon: const Icon(Icons.description_outlined),
                                border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                                filled: true,
                                fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please provide a brief description' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.roundedMd,
                            ),
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: AppTypography.titleMedium,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 64),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Submitted Successfully',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your request for $_selectedRole has been registered. The administrative verification committee will review your credentials.',
              style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Return to Home'),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Role Hierarchy Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _availableRoles.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, idx) {
              final r = _availableRoles[idx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(r.icon, size: 18, color: r.color),
                      const SizedBox(width: 8),
                      Text(r.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: r.color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(r.fullDescription, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }
}
