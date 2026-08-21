import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/role_application_model.dart';
import '../providers/admin_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(adminUsersProvider.notifier).loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleBadgeColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFDC2626);
      case UserRole.woredaOfficer:
        return const Color(0xFF2563EB);
      case UserRole.developmentAgent:
        return const Color(0xFFD97706);
      case UserRole.researcher:
        return const Color(0xFF7C3AED);
      case UserRole.farmer:
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingCount = state.pendingApplications
        .where((app) => app.status == RoleApplicationStatus.pending)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel & Role Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(
              icon: Icon(Icons.people_alt_outlined),
              text: 'All Personnel',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                backgroundColor: AppTheme.warningColor,
                child: const Icon(Icons.verified_user_outlined),
              ),
              text: 'Role Approvals',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: All Personnel
          _buildPersonnelTab(context, state, isDark),

          // Tab 2: Role Approvals
          _buildApprovalsTab(context, state, currentUser, isDark),
        ],
      ),
    );
  }

  Widget _buildPersonnelTab(BuildContext context, AdminUsersState state, bool isDark) {
    return Column(
      children: [
        // Search & Role Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or woreda...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(adminUsersProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2E1E) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  ref.read(adminUsersProvider.notifier).setSearchQuery(val);
                },
              ),
              const SizedBox(height: 12),
              // Role Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Roles', null, state.selectedRoleFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Farmers', 'FARMER', state.selectedRoleFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dev Agents', 'DEVELOPMENT_AGENT', state.selectedRoleFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Woreda Officers', 'WOREDA_OFFICER', state.selectedRoleFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Researchers', 'RESEARCHER', state.selectedRoleFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Admins', 'ADMIN', state.selectedRoleFilter),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No users match your filter criteria'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminUsersProvider.notifier).loadData(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: state.users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          final badgeColor = _getRoleBadgeColor(user.role);

                          return Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: badgeColor.withValues(alpha: 0.15),
                                    child: Text(
                                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user.fullName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: badgeColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                                              ),
                                              child: Text(
                                                RoleUtils.getRoleDisplayName(user.role),
                                                style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              user.phone,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                            ),
                                            if (user.woreda != null) ...[
                                              const SizedBox(width: 10),
                                              Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  user.woreda!.name,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    tooltip: 'Change Role',
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        enabled: false,
                                        child: Text('Assign Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      _buildRoleMenuItem(UserRole.farmer),
                                      _buildRoleMenuItem(UserRole.developmentAgent),
                                      _buildRoleMenuItem(UserRole.woredaOfficer),
                                      _buildRoleMenuItem(UserRole.researcher),
                                      _buildRoleMenuItem(UserRole.admin),
                                    ],
                                    onSelected: (newRole) async {
                                      await ref.read(adminUsersProvider.notifier).updateUserRole(user.id, newRole);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${user.fullName} role updated to ${RoleUtils.getRoleDisplayName(UserRole.fromString(newRole))}'),
                                            backgroundColor: const Color(0xFF2E7D32),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildApprovalsTab(BuildContext context, AdminUsersState state, UserModel? currentUser, bool isDark) {
    final pending = state.pendingApplications;

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 64, color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            const Text(
              'No Pending Applications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'All agricultural extension & officer roles are up to date.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminUsersProvider.notifier).loadData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final app = pending[index];
          final reqBadgeColor = _getRoleBadgeColor(app.requestedRole);
          final isPending = app.status == RoleApplicationStatus.pending;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isPending ? AppTheme.warningColor.withValues(alpha: 0.5) : Colors.grey.shade200,
                width: isPending ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                            child: const Icon(Icons.person, color: Color(0xFF1B5E20)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                app.userPhone,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: reqBadgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: reqBadgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 4),
                            Text(
                              RoleUtils.getRoleDisplayName(app.requestedRole),
                              style: TextStyle(
                                color: reqBadgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Location & Credential Info
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF1B5E20)),
                      const SizedBox(width: 6),
                      Text(
                        '${app.regionName} > ${app.zoneName} > ${app.woredaName}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  if (app.kebeleName != null && app.kebeleName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        'Assigned Kebele: ${app.kebeleName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Text(
                        'Staff ID: ${app.staffIdNumber} • ${app.organizationName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions for Pending Requests
                  if (isPending)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final reasonController = TextEditingController();
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Decline Role Application'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Please state the reason for declining:'),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: reasonController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Unverified staff ID',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Decline'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await ref.read(adminUsersProvider.notifier).rejectApplication(
                                  app.id,
                                  reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'Declined by administrator',
                                  reviewerName: currentUser?.fullName ?? 'Supervisor',
                                );
                              }
                            },
                            icon: const Icon(Icons.close, color: AppTheme.errorColor, size: 16),
                            label: const Text('Decline', style: TextStyle(color: AppTheme.errorColor)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.errorColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              await ref.read(adminUsersProvider.notifier).approveApplication(
                                app.id,
                                reviewerName: currentUser?.fullName ?? 'Supervisor',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Approved ${app.userName} as ${RoleUtils.getRoleDisplayName(app.requestedRole)}'),
                                    backgroundColor: const Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Approve Role'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: app.status == RoleApplicationStatus.approved
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                            : AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        app.status == RoleApplicationStatus.approved
                            ? 'Approved by ${app.reviewedBy ?? 'Admin'}'
                            : 'Declined: ${app.rejectionReason ?? 'Declined'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: app.status == RoleApplicationStatus.approved ? const Color(0xFF2E7D32) : AppTheme.errorColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String? roleValue, String? currentFilter) {
    final isSelected = currentFilter == roleValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(adminUsersProvider.notifier).setRoleFilter(roleValue);
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryDark,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryDark : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  PopupMenuItem<String> _buildRoleMenuItem(UserRole role) {
    return PopupMenuItem<String>(
      value: role.value,
      child: Row(
        children: [
          Icon(Icons.circle, color: _getRoleBadgeColor(role), size: 10),
          const SizedBox(width: 8),
          Text(RoleUtils.getRoleDisplayName(role)),
        ],
      ),
    );
  }
}
