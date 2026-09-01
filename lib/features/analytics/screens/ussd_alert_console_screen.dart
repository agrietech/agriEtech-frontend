import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

class UssdAlertConsoleScreen extends ConsumerStatefulWidget {
  const UssdAlertConsoleScreen({super.key});

  @override
  ConsumerState<UssdAlertConsoleScreen> createState() => _UssdAlertConsoleScreenState();
}

class _UssdAlertConsoleScreenState extends ConsumerState<UssdAlertConsoleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // USSD Simulator State
  final String _ussdDialCode = '*212#';
  String _ussdSessionHistory = '';
  String _currentUssdPrompt = '';
  bool _isSessionActive = false;
  bool _isLoadingUssd = false;
  final TextEditingController _ussdInputController = TextEditingController();

  // SMS Formatter State
  final TextEditingController _smsTextController = TextEditingController(
    text: '[አስቸኳይ ማስጠንቀቂያ] በአዳማ ወረዳ ከፍተኛ የመሬት መንቀጥቀጥና የመሸርሸር ስጋት ተመዝግቧል። ዝርዝር መረጃ ለማግኘት በስልክዎ *212# ይደውሉ።',
  );
  int _charCount = 0;
  bool _isUnicode = true;
  int _segmentCount = 1;
  int _charsRemainingInSegment = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateSmsMetrics();
    _smsTextController.addListener(_calculateSmsMetrics);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ussdInputController.dispose();
    _smsTextController.dispose();
    super.dispose();
  }

  void _calculateSmsMetrics() {
    final text = _smsTextController.text;
    final isUni = text.runes.any((r) => r > 127);
    final count = text.length;

    int segments = 1;
    int maxPerSegment = isUni ? 70 : 160;
    int maxConcat = isUni ? 67 : 153;

    if (count <= maxPerSegment) {
      segments = count == 0 ? 0 : 1;
    } else {
      segments = (count / maxConcat).ceil();
    }

    final totalCapacity = segments <= 1 ? maxPerSegment : (segments * maxConcat);
    final remaining = (totalCapacity - count).clamp(0, totalCapacity);

    setState(() {
      _charCount = count;
      _isUnicode = isUni;
      _segmentCount = segments;
      _charsRemainingInSegment = remaining;
    });
  }

  Future<void> _startUssdSession() async {
    setState(() {
      _isLoadingUssd = true;
      _isSessionActive = true;
      _ussdSessionHistory = 'Dialing $_ussdDialCode...\n';
    });

    final client = ref.read(dioClientProvider);

    try {
      final response = await client.dio.post<String>(
        ApiEndpoints.ussdGateway,
        data: {
          'sessionId': 'flutter_sim_${DateTime.now().millisecondsSinceEpoch}',
          'phoneNumber': '+251911223344',
          'text': '',
        },
      );

      final respText = response.data ?? '';
      _handleUssdResponse(respText);
    } catch (_) {
      // Local fallback simulation if offline
      _handleUssdResponse(
        'CON AgriEtech Ethiopia (*212#)\n'
        '1. Weather Forecast\n'
        '2. Drought & Rain Status\n'
        '3. Flood Alert Status\n'
        '4. Soil & Earthquake Hazard\n'
        '5. Report Threat\n'
        '6. አማርኛ / Afaan Oromoo / English',
      );
    } finally {
      setState(() => _isLoadingUssd = false);
    }
  }

  Future<void> _sendUssdInput(String input) async {
    if (input.trim().isEmpty) return;

    _ussdInputController.clear();
    setState(() {
      _isLoadingUssd = true;
      _ussdSessionHistory += '\n> $input\n';
    });

    final client = ref.read(dioClientProvider);

    try {
      final response = await client.dio.post<String>(
        ApiEndpoints.ussdGateway,
        data: {
          'sessionId': 'flutter_sim_active',
          'phoneNumber': '+251911223344',
          'text': input,
        },
      );

      final respText = response.data ?? '';
      _handleUssdResponse(respText);
    } catch (_) {
      // Intelligent offline simulation
      _simulateLocalUssdBranch(input);
    } finally {
      setState(() => _isLoadingUssd = false);
    }
  }

  void _handleUssdResponse(String raw) {
    setState(() {
      _currentUssdPrompt = raw.replaceFirst('CON ', '').replaceFirst('END ', '');
      _ussdSessionHistory += _currentUssdPrompt;
      if (raw.startsWith('END ')) {
        _isSessionActive = false;
        _ussdSessionHistory += '\n[Session Ended]';
      }
    });
  }

  void _simulateLocalUssdBranch(String input) {
    if (input == '1') {
      _handleUssdResponse('END [Weather] Adama: 24°C, Humidity 52%, Rain Prob: 15%. Good harvesting conditions.');
    } else if (input == '2') {
      _handleUssdResponse('END [Drought/Rain] SPI: -0.2 (Normal), Soil Moisture: 48%. Teff in vegetative phase.');
    } else if (input == '3') {
      _handleUssdResponse('END [Flood Status] Awash Basin: Normal. No flash flood alert in effect.');
    } else if (input == '4') {
      _handleUssdResponse('END [Soil & Seismology] Wonji Fault: PGA 0.12g (Moderate). Soil Loss: 14 t/ha/yr. Apply Terracing & Lime.');
    } else if (input == '5') {
      _handleUssdResponse('CON Report Threat / አደጋ ሪፖርት:\n1. Locust / አንበጣ\n2. Armyworm / ተምች\n3. Crop Disease / በሽታ\n4. Landslide/Crack / የመሬት መሰንጠቅ');
    } else if (input == '6') {
      _handleUssdResponse('CON Select Language / ቋንቋ ይምረጡ:\n1. አማርኛ (Amharic)\n2. Afaan Oromoo\n3. English');
    } else {
      _handleUssdResponse('END Thank you for using AgriEtech (*212#). Response submitted to Development Agents.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('USSD *212# & Multi-Channel Console'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.dialpad), text: 'USSD *212# Simulator'),
            Tab(icon: Icon(Icons.sms_outlined), text: 'SMS Budget Engine'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Interactive USSD Phone Console
          _buildUssdSimulatorTab(isDark),

          // Tab 2: SMS Character Budgeting Engine
          _buildSmsBudgetTab(isDark),
        ],
      ),
    );
  }

  Widget _buildUssdSimulatorTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feature phone frame emulator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1B0D) : const Color(0xFF1E2E1E),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phone Screen Display
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7D7B5), // Retro LCD screen tone
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _ussdSessionHistory.isEmpty
                          ? 'Ready.\nDial *212# to launch AgriEtech Farmer Gateway.'
                          : _ussdSessionHistory,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Controls & Input Box
                if (_isSessionActive) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ussdInputController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Enter USSD menu option...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: _sendUssdInput,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoadingUssd ? null : () => _sendUssdInput(_ussdInputController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSessionActive = false;
                        _ussdSessionHistory += '\n[User Cancelled Session]';
                      });
                    },
                    icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 16),
                    label: const Text('Cancel USSD Session', style: TextStyle(color: Colors.redAccent)),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _isLoadingUssd ? null : _startUssdSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                    label: const Text(
                      'Dial *212# (Launch USSD Session)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // USSD Quick Shortcuts
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Standardized *212# Quick Menus',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildQuickUssdButton('1. Weather Forecast (የአየር ሁኔታ)', '1'),
                  _buildQuickUssdButton('2. Drought & SPI Moisture (የድርቅ ሁኔታ)', '2'),
                  _buildQuickUssdButton('3. Flood Alert (የጎርፍ አደጋ)', '3'),
                  _buildQuickUssdButton('4. Soil & Earthquake Hazard (አፈርና መንቀጥቀጥ)', '4'),
                  _buildQuickUssdButton('5. Report Threat (አደጋ ሪፖርት ማድረጊያ)', '5'),
                  _buildQuickUssdButton('6. Change Language (ቋንቋ ቀይር)', '6'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickUssdButton(String title, String inputCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          if (!_isSessionActive) {
            _startUssdSession().then((_) {
              _sendUssdInput(inputCode);
            });
          } else {
            _sendUssdInput(inputCode);
          }
        },
        child: Text(title, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildSmsBudgetTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SMS Telemetry Header Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.techHeaderGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmsMetricItem('Encoding', _isUnicode ? 'UCS-2 (Unicode)' : 'GSM 7-Bit', Icons.code),
                _buildSmsMetricItem('Characters', '$_charCount', Icons.text_fields),
                _buildSmsMetricItem('SMS Segments', '$_segmentCount', Icons.splitscreen),
                _buildSmsMetricItem('Left in Part', '$_charsRemainingInSegment', Icons.hourglass_bottom),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Message Composer
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Alert Broadcast Composer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _smsTextController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Compose emergency SMS broadcast to farmers...',
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.language, size: 16),
                          label: const Text('Amharic Template', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            _smsTextController.text =
                                '[አስቸኳይ ማስጠንቀቂያ] በአዳማ ወረዳ ከፍተኛ የመሬት መንቀጥቀጥና የመሸርሸር ስጋት ተመዝግቧል። ዝርዝር መረጃ ለማግኘት በስልክዎ *212# ይደውሉ።';
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.language, size: 16),
                          label: const Text('Oromoo Template', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            _smsTextController.text =
                                '[AKEAKKACHIISA CIKKAA] Aanaa Bishooftuu keessatti balaan lolaa fi dhiqama biyyoo mudateera. Odeeffannoo dabalataaf *212# bilbilaa.';
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Broadcast queued for transmission via Africa\'s Talking ($_segmentCount segments/recipient)'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    label: const Text('Simulate Emergency SMS Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.telemetryNdvi, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    );
  }
}
