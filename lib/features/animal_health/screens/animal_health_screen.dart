import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/animal_health_models.dart';
import '../providers/animal_health_provider.dart';

class AnimalHealthScreen extends ConsumerStatefulWidget {
  const AnimalHealthScreen({super.key});

  @override
  ConsumerState<AnimalHealthScreen> createState() => _AnimalHealthScreenState();
}

class _AnimalHealthScreenState extends ConsumerState<AnimalHealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedSpecies = 'ALL';
  bool _onlyCritical = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReportOutbreakModal() {
    HapticFeedback.lightImpact();
    final user = ref.read(currentUserProvider);
    final formKey = GlobalKey<FormState>();
    final diseaseController = TextEditingController(text: 'Foot & Mouth Disease (FMD)');
    final kebeleController = TextEditingController();
    String selectedAnimal = 'CATTLE';
    String selectedSeverity = 'HIGH';
    int suspectedCases = 5;
    int mortalities = 0;
    bool quarantineStatus = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report Disease Outbreak',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Alerts Woreda Veterinary Office & Local DAs',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Disease Name field
                    TextFormField(
                      controller: diseaseController,
                      decoration: InputDecoration(
                        labelText: 'Pathogen / Disease Name *',
                        hintText: 'e.g. Foot & Mouth Disease, Anthrax, CCPP',
                        prefixIcon: const Icon(Icons.coronavirus_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter disease name' : null,
                    ),
                    const SizedBox(height: 12),

                    // Quick presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip('FMD (የአፍና እግር)', () {
                            setModalState(() {
                              diseaseController.text = 'Foot & Mouth Disease';
                              selectedAnimal = 'CATTLE';
                              selectedSeverity = 'HIGH';
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildPresetChip('Anthrax (አንትራክስ)', () {
                            setModalState(() {
                              diseaseController.text = 'Anthrax (አንትራክስ)';
                              selectedAnimal = 'CATTLE';
                              selectedSeverity = 'CRITICAL';
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildPresetChip('CCPP (የፍየል ሳንባ)', () {
                            setModalState(() {
                              diseaseController.text = 'Contagious Caprine Pleuropneumonia';
                              selectedAnimal = 'GOAT';
                              selectedSeverity = 'HIGH';
                            });
                          }),
                          const SizedBox(width: 6),
                          _buildPresetChip('Newcastle (የዶሮ ቸነፈር)', () {
                            setModalState(() {
                              diseaseController.text = 'Newcastle Disease';
                              selectedAnimal = 'POULTRY';
                              selectedSeverity = 'HIGH';
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Livestock Species & Severity Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedAnimal,
                            decoration: InputDecoration(
                              labelText: 'Species *',
                              prefixIcon: const Icon(Icons.pets_rounded, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'CATTLE', child: Text('Cattle (ላም)')),
                              DropdownMenuItem(value: 'SHEEP', child: Text('Sheep (በግ)')),
                              DropdownMenuItem(value: 'GOAT', child: Text('Goat (ፍየል)')),
                              DropdownMenuItem(value: 'CAMEL', child: Text('Camel (ግመል)')),
                              DropdownMenuItem(value: 'POULTRY', child: Text('Poultry (ዶሮ)')),
                              DropdownMenuItem(value: 'EQUINE', child: Text('Equine (ፈረስ) ')),
                            ],
                            onChanged: (val) => setModalState(() => selectedAnimal = val ?? 'CATTLE'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedSeverity,
                            decoration: InputDecoration(
                              labelText: 'Severity *',
                              prefixIcon: const Icon(Icons.warning_amber_rounded, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'LOW', child: Text('Low')),
                              DropdownMenuItem(value: 'MODERATE', child: Text('Moderate')),
                              DropdownMenuItem(value: 'HIGH', child: Text('High')),
                              DropdownMenuItem(value: 'CRITICAL', child: Text('Critical (አስቸኳይ)')),
                            ],
                            onChanged: (val) => setModalState(() => selectedSeverity = val ?? 'HIGH'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Kebele / Locality
                    TextFormField(
                      controller: kebeleController,
                      decoration: InputDecoration(
                        labelText: 'Kebele / Village (Optional)',
                        hintText: 'e.g. Kebele 02, Pastoral Station',
                        prefixIcon: const Icon(Icons.place_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Cases and Mortalities
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: suspectedCases.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Suspected Head',
                              prefixIcon: const Icon(Icons.numbers_rounded, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onChanged: (v) => suspectedCases = int.tryParse(v) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: mortalities.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Mortalities (Deaths)',
                              prefixIcon: const Icon(Icons.cancel_rounded, size: 18, color: Colors.red),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onChanged: (v) => mortalities = int.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quarantine switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fmd_bad_rounded, color: Colors.red, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Declare Quarantine Movement Ring',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Switch(
                            value: quarantineStatus,
                            activeThumbColor: Colors.red,
                            onChanged: (v) => setModalState(() => quarantineStatus = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Icon(Icons.notification_important_rounded),
                        label: Text(
                          isSubmitting ? 'Transmitting Epidemic Alert...' : 'Broadcast Outbreak Alert',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSubmitting = true);
                                try {
                                  final repo = ref.read(animalHealthRepositoryProvider);
                                  await repo.reportOutbreak({
                                    'woredaId': user?.woredaId ?? 'woreda_adama_01',
                                    'kebele': kebeleController.text.trim().isNotEmpty
                                        ? kebeleController.text.trim()
                                        : null,
                                    'diseaseName': diseaseController.text.trim(),
                                    'animalType': selectedAnimal,
                                    'severity': selectedSeverity,
                                    'suspectedCases': suspectedCases,
                                    'mortalities': mortalities,
                                    'quarantineStatus': quarantineStatus,
                                  });
                                  ref.invalidate(animalOutbreaksProvider);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text('Outbreak alert transmitted to Woreda Vet Officers & DAs'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF15803D),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                } catch (err) {
                                  setModalState(() => isSubmitting = false);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Notice: $err'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAdvisoryBottomSheet(AnimalOutbreakModel outbreak) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.red, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outbreak.diseaseName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target Species: ${outbreak.animalType} • ${outbreak.woredaName ?? "Woreda"}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Immediate Biosecurity Protocols (የአስቸኳይ ጥንቃቄ መመሪያ)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildProtocolItem(Icons.group_remove_rounded, 'Strict Herd Isolation', 'Do not mingle suspected animals with clean pastoral herds or communal watering troughs.'),
            _buildProtocolItem(Icons.no_transfer_rounded, 'Movement Restriction', 'No livestock transport, sales, or trailing permitted through designated quarantine zone.'),
            _buildProtocolItem(Icons.sanitizer_rounded, 'Sanitation & Carcass Disposal', 'Bury deceased livestock at minimum 2 meters depth with slaked lime. Do not consume infected meat.'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling Woreda Veterinary Dispatch Helpline: 8335'),
                          backgroundColor: Color(0xFF15803D),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: const Text('Vet Hotline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF059669)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Livestock & Animal Health'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Feed',
            onPressed: () {
              ref.invalidate(animalOutbreaksProvider);
              ref.invalidate(vaccinationCampaignsProvider);
              ref.invalidate(pastureConditionProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Outbreaks'),
            Tab(icon: Icon(Icons.vaccines_rounded), text: 'Vaccines'),
            Tab(icon: Icon(Icons.grass_rounded), text: 'Pasture (NDVI)'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.emergency_rounded),
        label: const Text('Report Outbreak', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showReportOutbreakModal,
      ),
      body: Column(
        children: [
          _buildHeroHeader(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOutbreaksTab(isDark),
                _buildVaccinationsTab(isDark),
                _buildPastureTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(bool isDark) {
    final outbreaksAsync = ref.watch(animalOutbreaksProvider);
    final campaignsAsync = ref.watch(vaccinationCampaignsProvider);
    final pastureAsync = ref.watch(pastureConditionProvider);

    final activeCount = outbreaksAsync.maybeWhen(
      data: (list) => list.where((o) => o.status.toUpperCase() == 'ACTIVE').length,
      orElse: () => 3,
    );
    final campaignsCount = campaignsAsync.maybeWhen(
      data: (list) => list.where((c) => c.status == 'IN_PROGRESS').length,
      orElse: () => 2,
    );
    final biomassScore = pastureAsync.maybeWhen(
      data: (p) => '${(p.biomassIndex * 100).toStringAsFixed(0)}%',
      orElse: () => '74%',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF022C22)]
              : [const Color(0xFF047857), const Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NATIONAL EPIDEMIOLOGICAL GRID',
                    style: TextStyle(
                      color: Color(0xFFBBF7D0),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Sentinel-2 Live',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniMetric('Active Outbreaks', activeCount.toString(), Icons.warning_rounded, const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _buildMiniMetric('Active Campaigns', campaignsCount.toString(), Icons.vaccines_rounded, const Color(0xFF60A5FA)),
              const SizedBox(width: 8),
              _buildMiniMetric('Biomass Index', biomassScore, Icons.eco_rounded, const Color(0xFF4ADE80)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutbreaksTab(bool isDark) {
    final outbreaksAsync = ref.watch(animalOutbreaksProvider);

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search disease, woreda...',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Critical', style: TextStyle(fontSize: 11)),
                selected: _onlyCritical,
                selectedColor: Colors.red.withValues(alpha: 0.2),
                checkmarkColor: Colors.red,
                onSelected: (val) => setState(() => _onlyCritical = val),
              ),
            ],
          ),
        ),

        // Species horizontal selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildSpeciesFilterChip('ALL', 'All Species'),
              const SizedBox(width: 6),
              _buildSpeciesFilterChip('CATTLE', 'Cattle (ላም)'),
              const SizedBox(width: 6),
              _buildSpeciesFilterChip('GOAT', 'Goat (ፍየል)'),
              const SizedBox(width: 6),
              _buildSpeciesFilterChip('SHEEP', 'Sheep (በግ)'),
              const SizedBox(width: 6),
              _buildSpeciesFilterChip('CAMEL', 'Camel (ግመል)'),
              const SizedBox(width: 6),
              _buildSpeciesFilterChip('POULTRY', 'Poultry (ዶሮ)'),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(animalOutbreaksProvider),
            child: outbreaksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Notice: $err')),
              data: (outbreaks) {
                final filtered = outbreaks.filterBy(
                  query: _searchQuery,
                  species: _selectedSpecies,
                  onlyCritical: _onlyCritical,
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety_rounded, size: 56, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Outbreaks Matching Filters',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'All pastoral herds in this selection are clear of active quarantine alerts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isCritical = item.severity.toUpperCase() == 'CRITICAL' || item.severity.toUpperCase() == 'HIGH';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCritical
                              ? Colors.red.withValues(alpha: 0.35)
                              : (isDark ? Colors.white12 : Colors.grey.shade200),
                          width: isCritical ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCritical
                                ? Colors.red.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCritical ? Icons.warning_rounded : Icons.info_rounded,
                                        size: 13,
                                        color: isCritical ? Colors.red : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.severity} • ${item.status}',
                                        style: TextStyle(
                                          color: isCritical ? Colors.red : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.animalType,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.diseaseName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.woredaName ?? "Woreda"}${item.kebele != null ? " • ${item.kebele}" : ""}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.group_rounded, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.suspectedCases} Suspected',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    if (item.mortalities > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${item.mortalities} Deaths)',
                                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ],
                                ),
                                if (item.quarantineStatus)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Quarantine Active',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAdvisoryBottomSheet(item),
                                icon: const Icon(Icons.shield_outlined, size: 16),
                                label: const Text('View Quarantine Advisory & Vet Hotline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                  side: BorderSide(
                                    color: isDark ? const Color(0xFF34D399).withValues(alpha: 0.4) : const Color(0xFF047857).withValues(alpha: 0.4),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesFilterChip(String key, String label) {
    final isSelected = _selectedSpecies == key;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
      onSelected: (_) => setState(() => _selectedSpecies = key),
    );
  }

  Widget _buildVaccinationsTab(bool isDark) {
    final campaignsAsync = ref.watch(vaccinationCampaignsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(vaccinationCampaignsProvider),
      child: campaignsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Notice: $err')),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(child: Text('No active vaccination campaigns in this sector.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final camp = campaigns[index];
              final isComplete = camp.status == 'COMPLETED';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isComplete ? Colors.green : Colors.blue).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              camp.status,
                              style: TextStyle(
                                color: isComplete ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            'Species: ${camp.targetSpecies.join(", ")}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(camp.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Target Pathogen: ${camp.diseaseTarget}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: camp.progressPercentage,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            camp.progressPercentage >= 0.8 ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${camp.vaccinatedCount.toLocaleString()} / ${camp.targetCount.toLocaleString()} Head Vaccinated',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${(camp.progressPercentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPastureTab(bool isDark) {
    final pastureAsync = ref.watch(pastureConditionProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(pastureConditionProvider),
      child: pastureAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Notice: $err')),
        data: (pasture) {
          final isDrought = pasture.droughtStress || pasture.biomassIndex < 0.40;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NDVI Biomass gauge card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sentinel-2 Rangeland NDVI',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isDrought ? Colors.red : Colors.green).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isDrought ? 'Drought Stress' : 'Favorable Rangeland',
                              style: TextStyle(
                                color: isDrought ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${(pasture.biomassIndex * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: isDrought ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        'Vegetation Health: ${pasture.vegetationCondition}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pasture.biomassIndex.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.grey.withValues(alpha: 0.18),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDrought ? Colors.red : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Carrying capacity & Water availability cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 22),
                            const SizedBox(height: 8),
                            const Text('Water Source', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              pasture.waterAvailability,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.speed_rounded, color: Colors.amber, size: 22),
                            const SizedBox(height: 8),
                            const Text('Grazing Pressure', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              pasture.grazingPressure ?? 'MODERATE',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pastoral Advisory Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Pastoral Grazing Advisory (የግጦሽ ምክረ-ሐሳብ)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pasture.droughtImpact,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      if (pasture.recommendedMove != null) ...[
                        const Divider(height: 20),
                        Text(
                          'Movement Recommendation: ${pasture.recommendedMove}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF047857)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

extension OutbreakFilterExtension on List<AnimalOutbreakModel> {
  List<AnimalOutbreakModel> filterBy({required String query, required String species, required bool onlyCritical}) {
    return where((item) {
      if (onlyCritical && item.severity.toUpperCase() != 'CRITICAL' && item.severity.toUpperCase() != 'HIGH') {
        return false;
      }
      if (species != 'ALL' && item.animalType.toUpperCase() != species.toUpperCase()) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesDisease = item.diseaseName.toLowerCase().contains(q);
        final matchesWoreda = item.woredaName?.toLowerCase().contains(q) ?? false;
        final matchesKebele = item.kebele?.toLowerCase().contains(q) ?? false;
        if (!matchesDisease && !matchesWoreda && !matchesKebele) return false;
      }
      return true;
    }).toList();
  }
}
