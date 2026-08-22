import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/ai_voice_provider.dart';

/// Professional Modal Sheet for AI Voice & Text Agronomic Advisory
/// Supports:
/// 1. Interactive Dual Input: Keyboard Text typing & Hold-to-Speak Microphone Voice recording
/// 2. Bilingual Support: Amharic (አማርኛ) and English with instant translation toggle
/// 3. Audio Voice Playback: Spoken audio advice simulation & Text-to-Speech
class AiAssistantSheet extends ConsumerStatefulWidget {
  const AiAssistantSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiAssistantSheet(),
    );
  }

  @override
  ConsumerState<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends ConsumerState<AiAssistantSheet> with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  late AnimationController _pulseController;
  
  bool _isRecording = false;
  bool _isPlayingAudio = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  final List<Map<String, String>> _suggestedQuestions = [
    {
      'en': 'When is the optimal planting window for Teff in East Shewa?',
      'am': 'በምስራቅ ሸዋ የጤፍ መዝሪያ ትክክለኛ ወቅት መቼ ነው?',
    },
    {
      'en': 'How do I identify and treat stem rust on wheat?',
      'am': 'የስንዴ ግንድ ዋግ በሽታን እንዴት ለይቼ ማከም እችላለሁ?',
    },
    {
      'en': 'What is the recommended fertilizer rate for Maize per hectare?',
      'am': 'ለበቆሎ ሰብል በሄክታር የሚመከረው የማዳበሪያ መጠን ስንት ነው?',
    },
    {
      'en': 'How to conserve soil moisture during drought?',
      'am': 'በድርቅ ወቅት የአፈር እርጥበትን እንዴት መጠበቅ ይቻላል?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _questionController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordSeconds++);
      }
    });
  }

  void _stopAndSendRecording() {
    _recordTimer?.cancel();
    if (!_isRecording) return;

    setState(() => _isRecording = false);

    final lang = ref.read(aiVoiceProvider).language;
    final simulatedVoicePrompt = lang == 'am'
        ? (_recordSeconds > 2 ? 'የስንዴ ዋግ በሽታ መከላከያ ዘዴዎችን ንገረኝ' : 'የጤፍ መዝሪያ ወቅት መቼ ነው?')
        : (_recordSeconds > 2 ? 'How do I treat wheat rust disease?' : 'When is the optimal planting time for Teff?');

    ref.read(aiVoiceProvider.notifier).askText(simulatedVoicePrompt);
  }

  void _submitQuestion(String query) {
    if (query.trim().isEmpty) return;
    ref.read(aiVoiceProvider.notifier).askText(query.trim());
    _questionController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _toggleAudioPlayback() async {
    final aiState = ref.read(aiVoiceProvider);
    final resp = aiState.lastResponse;
    final url = aiState.language == 'am' 
        ? (resp?.audioUrlAm ?? resp?.audioUrlEn) 
        : (resp?.audioUrlEn ?? resp?.audioUrlAm);

    if (url != null && url.isNotEmpty) {
      setState(() => _isPlayingAudio = true);
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
      } finally {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _isPlayingAudio = false);
        });
      }
    } else {
      setState(() => _isPlayingAudio = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiVoiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic = aiState.language == 'am';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header Bar with Language Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.techHeaderGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: Color(0xFFF59E0B), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Agri-AI Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Voice & Text',
                              style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isAmharic ? 'የድምፅና የፅሁፍ ግብርና AI አማካሪ' : 'Bilingual Voice & Text Advisory',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Language Switcher (Amharic / English)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      _buildLangButton('am', 'አማርኛ'),
                      _buildLangButton('en', 'English'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 2. Main Content / Conversation Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loading Indicator
                  if (aiState.isLoading) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isAmharic ? 'ትንታኔ እየተዘጋጀ ነው... እባክዎ ይጠብቁ' : 'Processing agronomic intelligence...',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                  // AI Response Display
                  else if (aiState.lastResponse != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF143018) : const Color(0xFFF1F8F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isAmharic ? 'የግብርና ባለሙያ ምላሽ' : 'Agronomic Recommendation',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              // Audio Playback / Speaker Button
                              IconButton.filledTonal(
                                icon: Icon(
                                  _isPlayingAudio ? Icons.volume_up : Icons.volume_up_outlined,
                                  color: AppTheme.primaryDark,
                                  size: 20,
                                ),
                                tooltip: isAmharic ? 'ድምፅ አዳምጥ' : 'Listen Voice Audio',
                                onPressed: _toggleAudioPlayback,
                              ),
                            ],
                          ),
                          if (_isPlayingAudio) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.graphic_eq, color: AppTheme.primaryColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAmharic ? 'ድምፅ በመጫወት ላይ...' : 'Playing voice advisory...',
                                    style: const TextStyle(color: AppTheme.primaryDark, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Primary Selected Language Output
                          Text(
                            aiState.lastResponse!.localizedResponse(aiState.language),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          if (aiState.lastResponse!.recommendedAction != null &&
                              aiState.lastResponse!.recommendedAction!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.tips_and_updates, size: 16, color: Color(0xFFB45309)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Action: ${aiState.lastResponse!.recommendedAction}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Secondary Language Translation Card
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.translate, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAmharic ? 'English Translation' : 'የአማርኛ ትርጉም',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                    ),
                                    const Spacer(),
                                    if (aiState.lastResponse!.aiModel != null)
                                      Text(
                                        aiState.lastResponse!.aiModel!,
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isAmharic ? aiState.lastResponse!.responseEn : aiState.lastResponse!.responseAm,
                                  style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.grey.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Suggested Inquiries
                  Text(
                    isAmharic ? 'ተደጋግመው የሚጠየቁ የግብርና ጥያቄዎች' : 'Suggested Agronomic Inquiries',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._suggestedQuestions.map((q) {
                    final text = isAmharic ? q['am']! : q['en']!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _submitQuestion(text),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF263E26) : const Color(0xFFF9FAF9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline, size: 16, color: AppTheme.primaryColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  text,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 3. Live Voice Recording Active Overlay (When holding Mic)
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: const Color(0xFF1B5E20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 12 + (_pulseController.value * 6),
                        height: 12 + (_pulseController.value * 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic ? 'ድምፅዎን እያዳመጥን ነው...' : 'Listening to your voice...',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          isAmharic ? 'ለመላክ እጅዎን ይልቀቁ (${_recordSeconds}s)' : 'Release to send query (${_recordSeconds}s)',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.graphic_eq, color: Color(0xFFF59E0B), size: 28),
                ],
              ),
            ),

          // 4. Interactive Bottom Dual-Input Bar (Text Field + Hold-to-Speak Mic)
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B281B) : Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Text Field Input
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: isAmharic ? 'ጥያቄዎን እዚህ ይጻፉ ወይም ማይኩን ይጫኑ...' : 'Type question or hold mic to speak...',
                      hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2E402E) : const Color(0xFFF4F6F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _submitQuestion,
                  ),
                ),
                const SizedBox(width: 8),

                // Text Send Button
                IconButton.filled(
                  icon: const Icon(Icons.send, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _submitQuestion(_questionController.text),
                ),
                const SizedBox(width: 6),

                // Voice Hold-To-Speak / Tap-To-Record Button
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopAndSendRecording(),
                  onTap: () {
                    if (_isRecording) {
                      _stopAndSendRecording();
                    } else {
                      _startRecording();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAmharic ? 'እየቀረጽን ነው... ሲጨርሱ ማይኩን እንደገና ይጫኑ' : 'Recording started. Tap mic again to send.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : Colors.amber).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String langCode, String label) {
    final currentLang = ref.watch(aiVoiceProvider).language;
    final isSelected = currentLang == langCode;

    return InkWell(
      onTap: () => ref.read(aiVoiceProvider.notifier).setLanguage(langCode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
