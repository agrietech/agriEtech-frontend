import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';

class CropProtectionHubScreen extends ConsumerWidget {
  const CropProtectionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Agricultural Intelligence Suite',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Agronomic Standards',
            onPressed: () => _showStandardsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Header Banner
            _buildHeroHeader(context, isDark),

            const SizedBox(height: AppSpacing.sectionGap),

            // 2. Section Title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '8 Autonomous Intelligence Engines',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Flagship Tools Grid
            _buildToolsList(context, isDark),

            const SizedBox(height: AppSpacing.sectionGap),

            // 4. EIAR / MoA Compliance Footer Card
            _buildComplianceCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.naturalHeroGradient,
        borderRadius: AppRadii.roundedLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Intelligence Command Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '8 Autonomous Engines • AI Vision • EIAR Protocols • Voice AI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Color(0xFF4ADE80), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unified intelligence hub: leaf pathology, voice agronomist, weed CV, knapsack calibrations (16L), W-A-L-E-S mixing, & seed geometry.',
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsList(BuildContext context, bool isDark) {
    final tools = [
      _HubTool(
        title: 'AI Crop Disease Doctor (Leaf Scan)',
        amharicTitle: 'የሰብል በሽታ መለያ በምስል (AI)',
        description: 'Deep learning leaf pathology scanner detecting 38+ crop diseases (Rust, Blight, Smut) with instant chemical and cultural remedies.',
        icon: Icons.biotech_rounded,
        accentColor: const Color(0xFF059669),
        route: '/diagnosis/create',
        badge: 'DEEP LEARNING',
      ),
      _HubTool(
        title: 'Bilingual AI Voice Agronomist',
        amharicTitle: 'የድምፅ እና የፅሁፍ AI ረዳት',
        description: 'Natural language and speech queries in Amharic & English. Expert agronomic guidance calibrated on Ethiopian crop calendar and soil zones.',
        icon: Icons.smart_toy_rounded,
        accentColor: const Color(0xFF0284C7),
        route: '/ai-assistant',
        badge: 'NLP & VOICE',
      ),
      _HubTool(
        title: 'AI Weed Detector & Herbicide Prescriptions',
        amharicTitle: 'የአረም መለያ እና የፀረ-አረም መመሪያ',
        description: 'Instant weed identification (Parthenium, Striga, Wild Oat) with knapsack dilutions and selective herbicides.',
        icon: Icons.grass_rounded,
        accentColor: const Color(0xFF16A34A),
        route: '/crop-protection/weed-detector',
        badge: 'AI VISION',
      ),
      _HubTool(
        title: 'Smart "Spray Window" Weather Advisory',
        amharicTitle: 'ተስማሚ የርጭት የአየር ሁኔታ መመሪያ',
        description: 'Hourly drift risk (<12 km/h), rainfastness window, thermal scorch warnings, and optimal spray hours.',
        icon: Icons.air_rounded,
        accentColor: const Color(0xFF0284C7),
        route: '/crop-protection/spray-window',
        badge: 'LIVE WEATHER',
      ),
      _HubTool(
        title: 'Visual Leaf Nutrient Deficiency Scanner',
        amharicTitle: 'የቅጠል ንጥረ-ነገር እጥረት መለያ',
        description: 'Diagnose N, P, K, Zn, Fe, S chlorosis symptoms with soil factor links and corrective top-dressing doses.',
        icon: Icons.energy_savings_leaf_rounded,
        accentColor: const Color(0xFFD97706),
        route: '/crop-protection/nutrient-scanner',
        badge: 'TOP-DRESSING',
      ),
      _HubTool(
        title: 'Insect Pest Scout & ETL Decision Engine',
        amharicTitle: 'የተባይ ቅኝት እና የኢኮኖሚ ጉዳት ወሰን (ETL)',
        description: 'Fall Armyworm, Locust, Stem Borer scouting. Interactive ETL calculator determines if chemical spray is needed.',
        icon: Icons.bug_report_rounded,
        accentColor: const Color(0xFFDC2626),
        route: '/crop-protection/pest-scout',
        badge: 'ETL CALCULATOR',
      ),
      _HubTool(
        title: 'Chemical Tank-Mix & Compatibility Validator',
        amharicTitle: 'የኬሚካል ቅልቅል ተኳሃኝነት ማረጋገጫ',
        description: 'Verify 2,4-D, Fungicides & Nutrients compatibility. Generates W-A-L-E-S mixing sequence & 500mL jar test.',
        icon: Icons.science_rounded,
        accentColor: const Color(0xFF9333EA),
        route: '/crop-protection/tank-mix',
        badge: 'W-A-L-E-S',
      ),
      _HubTool(
        title: 'Seed Rate & Planting Spacing Calculator',
        amharicTitle: 'የዘር መጠን እና የረድፍ ክፍተት አስሊ',
        description: 'Calculate exact certified seed kg, 50kg bags, plant geometry, and basal NPSB & Urea requirements for your farm area.',
        icon: Icons.straighten_rounded,
        accentColor: const Color(0xFF0D9488),
        route: '/crop-protection/seed-calculator',
        badge: 'HECTARE / TIMAD',
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return AppSurfaceCard(
          padding: const EdgeInsets.all(16),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(tool.route);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tool.accentColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(
                    color: tool.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(tool.icon, color: tool.accentColor, size: 26),
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
                            tool.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: tool.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: tool.accentColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            tool.badge,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: tool.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tool.amharicTitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tool.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132419) : const Color(0xFFF0FDF4),
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: isDark ? const Color(0xFF23442E) : const Color(0xFFBBF7D0),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.gavel_rounded, color: AppTheme.primaryColor, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Grounded in Ethiopian Institute of Agricultural Research (EIAR) field research, EthioSIS soil maps, and Ministry of Agriculture registered pesticide guidelines.',
              style: TextStyle(fontSize: 11.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showStandardsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agronomic Standards & Safety'),
        content: const SingleChildScrollView(
          child: Text(
            'This suite provides calibrated precision farming recommendations for Ethiopian smallholder farmers and commercial growers:\n\n'
            '• Sprayer Calibrations: Uses standard 16L knapsack sprayer volume (200 L/ha water baseline).\n'
            '• Spray Weather Safety: Requires wind <12 km/h, temperature <28°C, and 2-4 hours rainfastness.\n'
            '• Integrated Pest Management (IPM): Economic Threshold Levels (ETL) prevent unnecessary chemical overuse and protect beneficial insects.\n'
            '• Tank-Mix Protocols: Enforces international W-A-L-E-S mixing sequence to prevent curdling and sprayer nozzle blockages.\n'
            '• Soil & Seed Rates: Calibrated for Ethiopian Teff, Wheat, Maize, Barley, Sorghum, and Legumes with traditional Timad unit conversions.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HubTool {
  final String title;
  final String amharicTitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String route;
  final String badge;

  _HubTool({
    required this.title,
    required this.amharicTitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.route,
    required this.badge,
  });
}
