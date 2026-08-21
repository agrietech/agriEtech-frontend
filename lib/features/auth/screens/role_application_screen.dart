import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../admin/models/role_application_model.dart';
import '../../admin/repositories/admin_repository.dart';
import '../../boundaries/providers/boundary_provider.dart';
import '../providers/auth_provider.dart';

class RoleApplicationScreen extends ConsumerStatefulWidget {
  const RoleApplicationScreen({super.key});

  @override
  ConsumerState<RoleApplicationScreen> createState() => _RoleApplicationScreenState();
}

class _RoleApplicationScreenState extends ConsumerState<RoleApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _staffIdController = TextEditingController();
  final _organizationController = TextEditingController();
  final _kebeleController = TextEditingController();

  UserRole _selectedRole = UserRole.developmentAgent;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(boundaryHierarchyProvider.notifier).loadRegions();
    });
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _organizationController.dispose();
    _kebeleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final hierarchy = ref.read(boundaryHierarchyProvider);
    if (hierarchy.selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your assigned Region')),
      );
      return;
    }
    if (hierarchy.selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your assigned Zone')),
      );
      return;
    }
    if (hierarchy.selectedWoreda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your assigned Woreda')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final currentUser = ref.read(currentUserProvider);
        final application = RoleApplicationModel(
          id: 'req_${DateTime.now().millisecondsSinceEpoch}',
          userId: currentUser?.id ?? 'usr_current',
          userName: currentUser?.fullName ?? 'Agricultural Expert',
          userPhone: currentUser?.phone ?? '+251911000000',
          userEmail: currentUser?.email,
          currentRole: currentUser?.role ?? UserRole.farmer,
          requestedRole: _selectedRole,
          regionId: hierarchy.selectedRegion!.id,
          regionName: hierarchy.selectedRegion!.name,
          zoneId: hierarchy.selectedZone!.id,
          zoneName: hierarchy.selectedZone!.name,
          woredaId: hierarchy.selectedWoreda!.id,
          woredaName: hierarchy.selectedWoreda!.name,
          kebeleName: _kebeleController.text.trim().isNotEmpty ? _kebeleController.text.trim() : null,
          staffIdNumber: _staffIdController.text.trim(),
          organizationName: _organizationController.text.trim(),
          createdAt: DateTime.now(),
        );

        await ref.read(adminRepositoryProvider).submitRoleApplication(application);

        if (mounted) {
          setState(() => _isSubmitting = false);
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 28),
                  SizedBox(width: 10),
                  Text('Application Submitted'),
                ],
              ),
              content: Text(
                'Your request to be verified as a ${RoleUtils.getRoleDisplayName(_selectedRole)} for ${hierarchy.selectedWoreda!.name} has been submitted for hierarchical supervisor approval.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit application: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hierarchy = ref.watch(boundaryHierarchyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Agricultural Role'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF0D2818)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: Color(0xFFF59E0B), size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professional Verification',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Development Agents & Agricultural Officers are verified by their Woreda/Regional supervisor.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step 1: Select Desired Role
              const Text('1. Desired Agricultural Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50,
                ),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.developmentAgent,
                    child: Text('Development Agent (Kebele Extension Worker)'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.woredaOfficer,
                    child: Text('Woreda Agricultural Expert / Officer'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.researcher,
                    child: Text('Agricultural Researcher / Agronomist'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 24),

              // Step 2: Assigned Jurisdiction (Cascading Hierarchy)
              const Text('2. Assigned Location & Jurisdiction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              // Region
              DropdownButtonFormField<String>(
                value: hierarchy.selectedRegion?.id,
                decoration: InputDecoration(
                  labelText: 'Region',
                  prefixIcon: const Icon(Icons.map_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50,
                ),
                items: hierarchy.regions.map((reg) {
                  return DropdownMenuItem(value: reg.id, child: Text(reg.name));
                }).toList(),
                onChanged: (regId) {
                  if (regId != null) {
                    final r = hierarchy.regions.firstWhere((e) => e.id == regId);
                    ref.read(boundaryHierarchyProvider.notifier).selectRegion(r);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Zone
              DropdownButtonFormField<String>(
                value: hierarchy.selectedZone?.id,
                decoration: InputDecoration(
                  labelText: 'Zone',
                  hintText: hierarchy.selectedRegion == null ? 'Select Region first' : 'Select Zone',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: hierarchy.selectedRegion == null
                      ? Colors.grey.shade200
                      : (isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50),
                ),
                items: hierarchy.zones.map((zone) {
                  return DropdownMenuItem(value: zone.id, child: Text(zone.name));
                }).toList(),
                onChanged: hierarchy.selectedRegion == null
                    ? null
                    : (zoneId) {
                        if (zoneId != null) {
                          final z = hierarchy.zones.firstWhere((e) => e.id == zoneId);
                          ref.read(boundaryHierarchyProvider.notifier).selectZone(z);
                        }
                      },
              ),
              const SizedBox(height: 12),

              // Woreda
              DropdownButtonFormField<String>(
                value: hierarchy.selectedWoreda?.id,
                decoration: InputDecoration(
                  labelText: 'Woreda',
                  hintText: hierarchy.selectedZone == null ? 'Select Zone first' : 'Select Woreda',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: hierarchy.selectedZone == null
                      ? Colors.grey.shade200
                      : (isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50),
                ),
                items: hierarchy.woredas.map((woreda) {
                  return DropdownMenuItem(value: woreda.id, child: Text(woreda.name));
                }).toList(),
                onChanged: hierarchy.selectedZone == null
                    ? null
                    : (woredaId) {
                        if (woredaId != null) {
                          final w = hierarchy.woredas.firstWhere((e) => e.id == woredaId);
                          ref.read(boundaryHierarchyProvider.notifier).selectWoreda(w);
                        }
                      },
              ),
              const SizedBox(height: 12),

              // Kebele (Optional / Text)
              TextFormField(
                controller: _kebeleController,
                decoration: InputDecoration(
                  labelText: 'Kebele Name (Optional)',
                  hintText: 'e.g. Wonji Gefersa Kebele 02',
                  prefixIcon: const Icon(Icons.holiday_village_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),

              // Step 3: Professional Credentials
              const Text('3. Employee Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              TextFormField(
                controller: _staffIdController,
                decoration: InputDecoration(
                  labelText: 'Staff ID / Employee Number',
                  hintText: 'e.g. DA-ETH-2026-8812',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your Staff ID number' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(
                  labelText: 'Office / Institution Name',
                  hintText: 'e.g. Adama Woreda Office of Agriculture',
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your organization name' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Verification Application',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
