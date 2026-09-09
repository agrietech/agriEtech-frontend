import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
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

  List<Map<String, dynamic>> _myRequests = [];
  bool _loadingRequests = true;

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
      _loadExistingRequests();
    });
  }

  Future<void> _loadExistingRequests() async {
    try {
      final reqs = await ref.read(authProvider.notifier).getMyRoleRequests();
      if (mounted) {
        setState(() {
          _myRequests = reqs;
          _loadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRequests = false);
    }
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
      await ref.read(authProvider.notifier).submitRoleRequest(
            requestedRole: _selectedRole,
            reason: _justificationController.text.trim(),
            organizationName: _organizationController.text.trim(),
            staffIdNumber: _staffIdController.text.trim(),
            jurisdictionRegion: hierarchy.selectedRegion?.name,
            jurisdictionZone: hierarchy.selectedZone?.name,
            jurisdictionWoreda: hierarchy.selectedWoreda?.name,
          );

      await _loadExistingRequests();

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
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

    final hasPendingRequest = _myRequests.any((r) => r['status'] == 'PENDING');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B130E) : const Color(0xFFF7F9F7),
      drawer: const EthioFarmAppDrawer(),
      appBar: AppBar(
        title: const Text('Role & Governance Elevation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Role Guide',
            onPressed: () => _showRoleInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isSubmitted
            ? _buildSuccessView(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Active Role Status Header Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.naturalHeroGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Authenticated User',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Active Role: ${RoleUtils.getRoleDisplayName(currentRole)}',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                                  ),
                                  if (user?.region?.name != null)
                                    Text(
                                      'Jurisdiction: ${user?.region?.name ?? ""}${user?.woreda?.name != null ? " • ${user?.woreda?.name}" : ""}',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Pending Request Alert (if any)
                      if (hasPendingRequest) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 22),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Application Under Review',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'You have an active role upgrade application pending approval by the woreda/regional administrator.',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Governance Hierarchy Matrix
                      _buildGovernanceHierarchy(currentRole, isDark),
                      const SizedBox(height: 22),

                      // Section 1: Choose Target Role
                      const Text(
                        '1. Select Desired Institutional Role',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
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
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? opt.color.withValues(alpha: isDark ? 0.15 : 0.06)
                                    : (isDark ? const Color(0xFF132116) : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? opt.color : (isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: opt.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
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
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                  color: isSelected ? opt.color : null,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle, color: opt.color, size: 18),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          opt.subtitle,
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: opt.color.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Granted Capabilities:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                                const SizedBox(height: 4),
                                                ...opt.permissions.map((p) => Row(
                                                      children: [
                                                        Icon(Icons.check_circle_outline, size: 12, color: opt.color),
                                                        const SizedBox(width: 6),
                                                        Expanded(child: Text(p, style: const TextStyle(fontSize: 11))),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),

                      // Section 2: Target Jurisdiction
                      const Text(
                        '2. Target Operational Jurisdiction',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            // Region
                            DropdownButtonFormField<String>(
                              initialValue: hierarchy.selectedRegion?.id,
                              isExpanded: true,
                              decoration: _inputDecoration('Target Region', Icons.public_rounded, isDark),
                              items: hierarchy.regions.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final match = hierarchy.regions.where((r) => r.id == val).firstOrNull;
                                  hierarchyNotifier.selectRegion(match);
                                }
                              },
                              validator: (v) => v == null ? 'Please select target Region' : null,
                            ),
                            const SizedBox(height: 12),

                            // Zone
                            DropdownButtonFormField<String>(
                              initialValue: hierarchy.selectedZone?.id,
                              isExpanded: true,
                              decoration: _inputDecoration('Target Zone', Icons.domain_rounded, isDark),
                              items: hierarchy.zones.map((z) => DropdownMenuItem(value: z.id, child: Text(z.name))).toList(),
                              onChanged: hierarchy.selectedRegion == null
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        final match = hierarchy.zones.where((z) => z.id == val).firstOrNull;
                                        hierarchyNotifier.selectZone(match);
                                      }
                                    },
                            ),
                            const SizedBox(height: 12),

                            // Woreda
                            DropdownButtonFormField<String>(
                              initialValue: hierarchy.selectedWoreda?.id,
                              isExpanded: true,
                              decoration: _inputDecoration('Target Woreda', Icons.location_city_rounded, isDark),
                              items: hierarchy.woredas.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                              onChanged: hierarchy.selectedZone == null
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        final match = hierarchy.woredas.where((w) => w.id == val).firstOrNull;
                                        hierarchyNotifier.selectWoreda(match);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section 3: Official Verification Credentials
                      const Text(
                        '3. Official Verification Credentials',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132116) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _organizationController,
                              decoration: _inputDecoration('Bureau / Institute / University', Icons.business_rounded, isDark),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Organization name is required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _staffIdController,
                              decoration: _inputDecoration('Government Staff ID / Badge No.', Icons.badge_rounded, isDark),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Staff ID is required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _justificationController,
                              maxLines: 3,
                              decoration: _inputDecoration('Operational mandate and justification...', Icons.description_rounded, isDark),
                              validator: (v) => (v == null || v.trim().length < 10) ? 'Provide at least 10 characters' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Submit Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitApplication,
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded),
                          label: const Text('Submit Role Elevation Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Section 4: Application History
                      if (!_loadingRequests && _myRequests.isNotEmpty) ...[
                        const Text(
                          'Application History & Status',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        ..._myRequests.map((req) {
                          final status = (req['status'] ?? 'PENDING').toString().toUpperCase();
                          Color badgeColor = Colors.orange;
                          if (status == 'APPROVED') badgeColor = Colors.green;
                          if (status == 'REJECTED') badgeColor = Colors.red;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: isDark ? const Color(0xFF132116) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              title: Text('Applied for: ${req['requestedRole'] ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              subtitle: Text(
                                'Organization: ${req['organizationName'] ?? "None"}\nSubmitted: ${req['createdAt']?.toString().split("T").first ?? "Recent"}',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGovernanceHierarchy(UserRole currentRole, bool isDark) {
    final steps = [
      {'role': UserRole.farmer, 'label': 'Farmer'},
      {'role': UserRole.developmentAgent, 'label': 'DA (Kebele)'},
      {'role': UserRole.woredaOfficer, 'label': 'Woreda'},
      {'role': UserRole.zonalOfficer, 'label': 'Zone'},
      {'role': UserRole.regionalOfficer, 'label': 'Region'},
      {'role': UserRole.researcher, 'label': 'EIAR'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132116) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('National Agricultural Governance Progression:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((s) {
              final isCurrent = s['role'] == currentRole;
              return Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? const Color(0xFF1B5E20) : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: Icon(
                        isCurrent ? Icons.check : Icons.circle,
                        size: isCurrent ? 16 : 8,
                        color: isCurrent ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? const Color(0xFF1B5E20) : Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 72),
            const SizedBox(height: 16),
            const Text(
              'Application Submitted Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your request for $_selectedRole has been registered. The administrative review board will inspect your official credentials and dispatch an SMS alert upon decision.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => _isSubmitted = false);
                context.go('/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Return to Profile'),
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
        title: const Text('Ethiopian Agricultural Governance Matrix'),
        content: const SingleChildScrollView(
          child: Text(
            'The EthioFarm platform operates under hierarchical mandate levels aligned with the Ethiopian Ministry of Agriculture:\n\n'
            '• Smallholder: Farm-level inputs, localized disease diagnosis, and micro-climate advisories.\n'
            '• Development Agent: Kebele plots registry, IoT sensor calibration, and ground scouting.\n'
            '• Woreda Officer: Woreda disaster broadcast, USSD *212# push, and spatial hazard management.\n'
            '• Zonal Lead: Multi-woreda analytics, SPI drought indexing, and resource allocation.\n'
            '• Regional Bureau: State command center, seismic hazard surveillance, and emergency relief.\n'
            '• Researcher: Direct Sentinel-2/1 access, digital soil mapping, and downscaled climate modeling.',
            style: TextStyle(fontSize: 12.5, height: 1.4),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Understood')),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
      filled: true,
      fillColor: isDark ? const Color(0xFF0E1A11) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFF26382A) : const Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    );
  }
}
