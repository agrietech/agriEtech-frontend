import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/ai_voice_provider.dart';
import '../services/voice_synthesis_service.dart';

/// Standardized EthioFarm AI Screen (Dual Mode: Real Voice & Conversational Chat)
/// - Real-time microphone voice recording with live Speech-To-Text transcription.
/// - High-fidelity voice replay (TTS) in Amharic and English.
/// - Rich agronomic question answering grounded in Ethiopian agricultural data.
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  int _recordingSeconds = 0;
  bool _timerActive = false;
  int _selectedCategoryIndex = 0;

  static const List<Map<String, dynamic>> _promptCategories = [
    {
      'nameAm': '🌾 ሰብሎች',
      'nameEn': '🌾 Crops',
      'promptsAm': [
        '🌾 የስንዴ ግንድ ዋግ (ረስት) በሽታ መከላከያና መድሃኒቶች',
        '🌾 የጤፍ ሰብል እንክብካቤ፣ ማዳበሪያና መተኛትን (Lodging) መከላከል',
        '🌽 የበቆሎ ምርታማነት ማሳደጊያ የዩሪያና NPS-B አጠቃቀም',
        '☕ የቡና ፍሬ በሽታ (CBD) መከላከያ ፀረ-ፈንገስና የጥላ ዛፎች',
      ],
      'promptsEn': [
        '🌾 Wheat stem rust prevention & systemic fungicides',
        '🌾 Teff crop management, fertilization & lodging control',
        '🌽 Maize yield boost with split Urea & NPS-B schedule',
        '☕ Coffee Berry Disease (CBD) control & shade trees',
      ],
    },
    {
      'nameAm': '🐛 ተባይና በሽታ',
      'nameEn': '🐛 Pests & Diseases',
      'promptsAm': [
        '🌽 የበቆሎ ተምች (Fall Armyworm) ህክምናና ኬሚካሎች',
        '🍅 የቲማቲም ቅጠል መድረቅ (Late Blight) መከላከያ ሪዶሚል ጎልድ',
        '🧅 የሽንኩርት ወይንጠጅ ነጠብጣብ (Purple Blotch) መቆጣጠሪያ',
        '🌾 በማሽላ ላይ የሚከሰተውን አጋም (Striga) ማጥፊያ ዘዴዎች',
      ],
      'promptsEn': [
        '🌽 Fall armyworm treatment & chemical dosages for maize',
        '🍅 Tomato Late Blight fungicide schedule (Ridomil Gold)',
        '🧅 Onion Purple Blotch control & curing protocol',
        '🌾 Parasitic Striga (witchweed) eradication methods',
      ],
    },
    {
      'nameAm': '🧪 አፈርና ማዳበሪያ',
      'nameEn': '🧪 Soil & Fertilizer',
      'promptsAm': [
        '🧪 የአፈር አሲዳማነትን በእርሻ ኖራ (Lime) እንዴት ማከም ይቻላል?',
        '🌿 የፍጥነት ኮምፖስት (የተፈጥሮ ማዳበሪያ) ደረጃ በደረጃ ዝግጅት',
        '⚖️ ለስንዴና በቆሎ የተመጣጠነ የNPS እና ዩሪያ ማዳበሪያ መጠን',
        '💧 የወላካ አፈርን ከመጥለቅለቅ ለመከላከል የBBM ቦይ ዝግጅት',
      ],
      'promptsEn': [
        '🧪 How to remediate acidic soils with Agricultural Lime?',
        '🌿 Step-by-step rapid aerobic compost preparation',
        '⚖️ Balanced NPS-B and split Urea rates for cereals',
        '💧 Vertisol drainage using Broad Bed and Furrows (BBM)',
      ],
    },
    {
      'nameAm': '🐄 እንስሳትና መኖ',
      'nameEn': '🐄 Livestock & Dairy',
      'promptsAm': [
        '🐄 የወተት ላሞች የተመጣጠነ መኖ እና የማስቲቲስ (የጡት በሽታ) ህክምና',
        '🐔 የዶሮ ፈንግል (Newcastle) በሽታ የክትባት ፕሮግራም በዕድሜ',
        '🌿 የዴሾ ሳር (Desho Grass) እና የዝሆን ሳር አመራረትና አጨዳ',
        '🐑 የበግና ፍየል ማደለብ የተመጣጠነ መኖና የሆድ ትል መድኃኒት',
      ],
      'promptsEn': [
        '🐄 Dairy cattle ration balancing & mastitis veterinary care',
        '🐔 Newcastle poultry vaccination schedule by bird age',
        '🌿 Desho grass cultivation for intensive cut-and-carry fodder',
        '🐑 Sheep & goat 90-day fattening ration & deworming',
      ],
    },
    {
      'nameAm': '🌧️ አየር ሁኔታና ውሃ',
      'nameEn': '🌧️ Weather & Water',
      'promptsAm': [
        '🌧️ የዚህ ሳምንት የዝናብ ትንበያና ለእርሻ ስራ ዝግጅት',
        '💧 የአፈር እርጥበትን በደረቅ ገለባ (Mulching) የመጠበቅ ዘዴ',
        '⛰️ የዝናብ ውሃን በአፈር ውስጥ ለማስረግ የታይድ ሪጅስ (Tied ridges) አሰራር',
      ],
      'promptsEn': [
        '🌧️ Weekly rainfall forecast & farming preparation advisory',
        '💧 Soil moisture conservation using crop residue mulching',
        '⛰️ In-situ rainwater harvesting with tied ridges & contour bunds',
      ],
    },
    {
      'nameAm': '🏪 ገበያና ድህረ-ምርት',
      'nameEn': '🏪 Storage & Market',
      'promptsAm': [
        '🌾 እህልን በፒክስ ከረጢት (PICS Bags) ያለ ኬሚካል ማከማቸት',
        '🏪 የኢትዮጵያ ምርት ገበያ (ECX) የጥራት ደረጃና የእርጥበት መጠን',
        '💰 በህብረት ስራ ማህበራት በኩል እህልን በጅምላ በመሸጥ ትርፍ ማሳደግ',
      ],
      'promptsEn': [
        '🌾 Hermetic grain storage in triple-layer PICS bags',
        '🏪 ECX quality standards & grain moisture thresholds (<12.5%)',
        '💰 Maximizing farmer profit through agricultural cooperatives',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    VoiceSynthesisService.instance.stop();
    _focusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTimer() {
    _recordingSeconds = 0;
    _timerActive = true;
    _tick();
  }

  void _stopTimer() {
    _timerActive = false;
    _recordingSeconds = 0;
  }

  void _tick() {
    if (!_timerActive) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerActive) {
        setState(() => _recordingSeconds++);
        _tick();
      }
    });
  }

  Future<void> _handleMicPressed() async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(aiVoiceProvider.notifier);
    final state = ref.read(aiVoiceProvider);

    if (state.isRecording) {
      _stopTimer();
      await notifier.stopVoiceRecordingAndSubmit();
      _scrollToBottom();
    } else {
      _startTimer();
      final started = await notifier.startVoiceRecording();
      if (!started) {
        _stopTimer();
      }
    }
  }

  Future<void> _handleCancelRecording() async {
    HapticFeedback.lightImpact();
    _stopTimer();
    await ref.read(aiVoiceProvider.notifier).cancelVoiceRecording();
  }

  Future<void> _submitTextQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    HapticFeedback.lightImpact();
    _textController.clear();
    FocusScope.of(context).unfocus();

    await ref.read(aiVoiceProvider.notifier).sendQuestion(clean);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiVoiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAm = aiState.language == 'am';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Color(0xFF16A34A), size: 16),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isAm ? 'ኢትዮፋርም AI' : 'EthioFarm AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    isAm
                        ? 'የቀጥታ ድምፅና ፅሁፍ ረዳት'
                        : 'Voice & Text Assistant',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Auto-speak toggle
          IconButton(
            icon: Icon(
              aiState.autoSpeak
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: aiState.autoSpeak ? const Color(0xFF16A34A) : Colors.grey,
            ),
            tooltip: aiState.autoSpeak
                ? (isAm ? 'ራስ-ሰር ድምፅ አጫውት በርቷል' : 'Auto-speak enabled')
                : (isAm ? 'ራስ-ሰር ድምፅ አጫውት ጠፍቷል' : 'Auto-speak disabled'),
            onPressed: () {
              ref.read(aiVoiceProvider.notifier).setAutoSpeak(!aiState.autoSpeak);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(!aiState.autoSpeak
                      ? (isAm ? 'ራስ-ሰር ድምፅ አጫውት ነቅቷል' : 'Auto-speak enabled')
                      : (isAm ? 'ራስ-ሰር ድምፅ አጫውት ተሰናክሏል' : 'Auto-speak disabled')),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          // Language Switcher
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildLangChip('am', 'አማ', aiState.language == 'am'),
                _buildLangChip('en', 'EN', aiState.language == 'en'),
              ],
            ),
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'clear') {
                ref.read(aiVoiceProvider.notifier).clearMessages();
              } else if (value == 'mode') {
                ref.read(aiVoiceProvider.notifier).toggleVoiceMode();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mode',
                child: Row(
                  children: [
                    Icon(
                      aiState.isVoiceMode
                          ? Icons.chat_bubble_outline_rounded
                          : Icons.mic_rounded,
                      size: 18,
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    Text(aiState.isVoiceMode
                        ? (isAm ? 'ወደ ፅሁፍ ውይይት ቀይር' : 'Switch to Chat Feed')
                        : (isAm ? 'ወደ ድምፅ ሁነታ ቀይር' : 'Switch to Voice Orb')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(isAm ? 'ውይይቱን አጽዳ' : 'Clear Conversation'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Engine Telemetry Strip
            _buildTelemetryBanner(context, isDark, isAm),

            // Live Speaking Banner
            if (aiState.isSpeaking) _buildSpeakingLiveBanner(context, isDark, isAm),

            // Main Content: Voice Mode vs Chat Mode
            Expanded(
              child: aiState.isVoiceMode
                  ? _buildVoiceInteractiveView(context, aiState, isDark, isAm)
                  : _buildChatFeedView(context, aiState, isDark, isAm),
            ),

            // Error Banner if present
            if (aiState.error != null) _buildErrorBanner(context, aiState.error!, isAm),

            // Universal Bottom Bar (Voice Recording or Input Field)
            _buildBottomControlBar(context, aiState, isDark, isAm),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip(String code, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(aiVoiceProvider.notifier).setLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryBanner(BuildContext context, bool isDark, bool isAm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112214) : const Color(0xFFF0FDF4),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF22C55E).withValues(alpha: isDark ? 0.3 : 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hub_rounded, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAm
                  ? 'EthioFarm AI • ባለሁለት ቋንቋ የግብርና ድምፅ ረዳት'
                  : 'EthioFarm AI • Bilingual Voice & Vision Agronomic Intelligence',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => ref.read(aiVoiceProvider.notifier).toggleVoiceMode(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  Icon(
                    ref.watch(aiVoiceProvider).isVoiceMode
                        ? Icons.view_stream_rounded
                        : Icons.graphic_eq_rounded,
                    size: 14,
                    color: const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ref.watch(aiVoiceProvider).isVoiceMode
                        ? (isAm ? 'ውይይት' : 'Chat')
                        : (isAm ? 'ድምፅ' : 'Voice'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingLiveBanner(BuildContext context, bool isDark, bool isAm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withValues(alpha: isDark ? 0.35 : 0.1),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Icon(
                Icons.graphic_eq_rounded,
                size: 20,
                color: Color.lerp(const Color(0xFF2563EB), const Color(0xFF60A5FA), _pulseController.value),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAm
                  ? '🔊 የቀጥታ AI ድምፅ በማሰማት ላይ...'
                  : '🔊 EthioFarm AI Speaking Live...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.15),
              foregroundColor: const Color(0xFFDC2626),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(aiVoiceProvider.notifier).stopSpeaking();
            },
            icon: const Icon(Icons.stop_rounded, size: 14),
            label: Text(
              isAm ? 'አቁም' : 'Stop',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // 1. VOICE INTERACTIVE MODE (ORB & WAVEFORM)
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildVoiceInteractiveView(
    BuildContext context,
    AiVoiceState state,
    bool isDark,
    bool isAm,
  ) {
    final hasMessages = state.messages.isNotEmpty;
    final lastAiMsg = hasMessages
        ? state.messages.reversed.firstWhere(
            (m) => !m.isUser && !m.isError,
            orElse: () => state.messages.last,
          )
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Central Pulsating Voice Orb
          _buildVoiceOrb(state, isDark, isAm),

          const SizedBox(height: 24),

          // Live Transcription Card (During Active Voice Recording)
          if (state.isRecording || state.liveTranscript.isNotEmpty)
            _buildLiveTranscriptBox(state, isDark, isAm),

          // Last Answer / Speech Replay Card (if available)
          if (!state.isRecording && lastAiMsg != null && !lastAiMsg.isUser)
            _buildActiveVoiceResponseCard(lastAiMsg, isDark, isAm),

          const SizedBox(height: 20),

          // Quick Voice Prompt Chips
          _buildQuickPrompts(isAm),
        ],
      ),
    );
  }

  Widget _buildVoiceOrb(AiVoiceState state, bool isDark, bool isAm) {
    final isRec = state.isRecording;
    final isThinking = state.isLoading;
    final isSpeaking = state.isSpeaking;

    Color orbColor = const Color(0xFF16A34A);
    String statusText = isAm ? 'ለመናገር ማይክሮፎኑን ይጫኑ' : 'Tap microphone to speak';
    String subText = isAm
        ? 'በአማርኛ ወይም በእንግሊዝኛ ስለ ሰብል፣ በሽታና አፈር ይጠይቁ'
        : 'Ask in Amharic or English about crops, disease & soil';

    if (isRec) {
      orbColor = const Color(0xFFDC2626);
      final mm = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
      final ss = (_recordingSeconds % 60).toString().padLeft(2, '0');
      statusText = isAm ? 'በማዳመጥ ላይ... ($mm:$ss)' : 'Listening... ($mm:$ss)';
      subText = isAm ? 'ጥያቄዎን አሁን ይናገሩ...' : 'Speak your question clearly...';
    } else if (isThinking) {
      orbColor = const Color(0xFFD97706);
      statusText = isAm ? 'ኢትዮፋርም AI በማሰብ ላይ...' : 'EthioFarm AI is analyzing...';
      subText = isAm ? 'የግብርና መፍትሄዎችን በማቀናጀት ላይ ነው' : 'Synthesizing agronomic response';
    } else if (isSpeaking) {
      orbColor = const Color(0xFF2563EB);
      statusText = isAm ? 'መልስ በማሰማት ላይ...' : 'EthioFarm AI is speaking...';
      subText = isAm ? 'ድምፁን ለማቆም የድምፅ ቁልፉን ይጫኑ' : 'Tap stop icon to pause audio';
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Pulsating Rings
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isRec
                    ? 1.0 + (_pulseController.value * 0.3) + (state.soundLevel.clamp(0.0, 10.0) * 0.03)
                    : 1.0 + (_pulseController.value * 0.08);
                return Container(
                  width: 170 * scale,
                  height: 170 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: orbColor.withValues(alpha: isRec ? 0.25 : 0.12),
                  ),
                );
              },
            ),
            // Middle Ring
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    orbColor.withValues(alpha: 0.8),
                    orbColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: orbColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _handleMicPressed,
                  child: Center(
                    child: Icon(
                      isRec
                          ? Icons.stop_rounded
                          : (isSpeaking
                              ? Icons.volume_up_rounded
                              : (isThinking ? Icons.hourglass_top_rounded : Icons.mic_rounded)),
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLiveTranscriptBox(AiVoiceState state, bool isDark, bool isAm) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.5),
          width: 1.5,
        ),
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAm ? 'የቀጥታ ንግግር ቅጂ (SPEECH-TO-TEXT)' : 'LIVE SPEECH TRANSCRIBER',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              if (state.isRecording)
                TextButton.icon(
                  onPressed: _handleCancelRecording,
                  icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                  label: Text(
                    isAm ? 'ሰርዝ' : 'Cancel',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.liveTranscript.isEmpty
                ? (isAm ? 'በማዳመጥ ላይ ነው... እባክዎ ይናገሩ...' : 'Listening... speak into your microphone...')
                : state.liveTranscript,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: state.liveTranscript.isEmpty
                  ? Colors.grey
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
          if (state.isRecording) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleMicPressed,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(isAm ? 'ንግግሩን ጨርስና ጠይቅ' : 'Finish & Submit Inquiry'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveVoiceResponseCard(ChatMessage msg, bool isDark, bool isAm) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17251C) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'ETHIOFARM AI RESPONSE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16A34A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              _buildVoiceAudioBar(msg, isAm),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: msg.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: isDark ? Colors.grey.shade200 : const Color(0xFF1E293B),
              ),
              h1: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              h2: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              h3: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              strong: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              listBullet: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
              blockSpacing: 8.0,
            ),
          ),
          if (msg.aiResponse != null &&
              msg.aiResponse!.responseAm.isNotEmpty &&
              msg.aiResponse!.responseEn.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(aiVoiceProvider.notifier).toggleMessageLanguage(msg.id);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate_rounded, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text(
                      (msg.displayedLanguage ?? ref.watch(aiVoiceProvider).language) == 'am'
                          ? 'Switch to English 🇺🇸'
                          : 'ወደ አማርኛ ቀይር 🇪🇹',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (msg.aiResponse?.recommendedAction != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      msg.aiResponse!.recommendedAction!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPrompts(bool isAm) {
    final cat = _promptCategories[_selectedCategoryIndex.clamp(0, _promptCategories.length - 1)];
    final prompts = (isAm ? cat['promptsAm'] : cat['promptsEn']) as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.explore_outlined, size: 16, color: Color(0xFF16A34A)),
            const SizedBox(width: 6),
            Text(
              isAm ? 'የተለመዱ የግብርና ጥያቄዎችን ይምረጡ፡' : 'Browse agronomic topics by category:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Category Pills Horizontal Scroll
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _promptCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final c = _promptCategories[index];
              final label = isAm ? c['nameAm'] as String : c['nameEn'] as String;
              final isSelected = index == _selectedCategoryIndex;

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategoryIndex = index);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF16A34A)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF16A34A) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.black87),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Prompt Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prompts.map((p) {
            return ActionChip(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.grey.shade100,
              side: BorderSide(color: Colors.grey.shade300),
              label: Text(
                p,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              onPressed: () => _submitTextQuery(p),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // 2. CONVERSATIONAL CHAT FEED VIEW
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildChatFeedView(
    BuildContext context,
    AiVoiceState state,
    bool isDark,
    bool isAm,
  ) {
    if (state.messages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 44,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAm ? 'እንኳን ወደ ኢትዮፋርም AI በደህና መጡ!' : 'Welcome to EthioFarm AI!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isAm
                    ? 'በድምፅ ወይም በፅሁፍ ስለ ሰብልዎ እንክብካቤ፣ ተባይና የአፈር ሁኔታ ይጠይቁ።'
                    : 'Ask questions by voice or text regarding crop pathology, pest control, and weather.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildQuickPrompts(isAm),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isLoading) {
          return _buildThinkingBubble(isDark, isAm);
        }
        final message = state.messages[index];
        return _buildMessageBubble(message, isDark, isAm);
      },
    );
  }

  Widget _buildThinkingBubble(bool isDark, bool isAm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 10),
                Text(
                  isAm ? 'ኢትዮፋርም AI በማሰብ ላይ ነው...' : 'EthioFarm AI is analyzing...',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, bool isAm) {
    final isUser = msg.isUser;
    final isPlaying = ref.watch(aiVoiceProvider).currentlyPlayingMessageId == msg.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF16A34A)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isPlaying
                            ? const Color(0xFF16A34A)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        width: isPlaying ? 1.5 : 1.0,
                      ),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Text Content
                  if (isUser)
                    Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.white,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: msg.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: isDark ? Colors.grey.shade100 : const Color(0xFF0F172A),
                        ),
                        h1: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        h2: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        h3: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        strong: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        listBullet: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                        blockSpacing: 8.0,
                      ),
                    ),

                  // In-Bubble Translation Switcher
                  if (!isUser &&
                      !msg.isError &&
                      msg.aiResponse != null &&
                      msg.aiResponse!.responseAm.isNotEmpty &&
                      msg.aiResponse!.responseEn.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(aiVoiceProvider.notifier).toggleMessageLanguage(msg.id);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.translate_rounded, size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 5),
                            Text(
                              (msg.displayedLanguage ?? ref.watch(aiVoiceProvider).language) == 'am'
                                  ? 'Translate to English 🇺🇸'
                                  : 'ወደ አማርኛ ተርጉም 🇪🇹',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // AI Controls: Voice Replay, Bilingual Switcher, and Recommendations
                  if (!isUser && !msg.isError) ...[
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Audio Play/Pause Button
                        _buildVoiceAudioBar(msg, isAm),
                        // Copy Button
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                          tooltip: 'Copy advice',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Recommended Action Chip
                    if (msg.aiResponse?.recommendedAction != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.task_alt, size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                msg.aiResponse!.recommendedAction!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  // Retry button if error
                  if (msg.isError && msg.failedQuestion != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(aiVoiceProvider.notifier)
                          .retryQuestion(msg.failedQuestion!),
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                      label: Text(isAm ? 'እንደገና ሞክር' : 'Retry Query',
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],

                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatTime(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white70
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAudioBar(ChatMessage msg, bool isAm) {
    final aiState = ref.watch(aiVoiceProvider);
    final isPlaying = aiState.isSpeaking && aiState.currentlyPlayingMessageId == msg.id;
    final currentMsgLang = msg.displayedLanguage ?? aiState.language;
    final altLang = currentMsgLang == 'am' ? 'en' : 'am';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play / Stop Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isPlaying ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: isPlaying ? 2 : 0,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(aiVoiceProvider.notifier).speakResponse(msg, targetLang: currentMsgLang);
          },
          icon: isPlaying
              ? AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => const Icon(Icons.graphic_eq_rounded, size: 15),
                )
              : const Icon(Icons.volume_up_rounded, size: 15),
          label: Text(
            isPlaying
                ? (isAm ? 'አቁም' : 'Stop')
                : (isAm ? 'ድምፅ አጫውት' : 'Play Voice'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        // Secondary language replay if available
        if (msg.aiResponse != null &&
            msg.aiResponse!.responseEn.isNotEmpty &&
            msg.aiResponse!.responseAm.isNotEmpty) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(aiVoiceProvider.notifier).speakResponse(msg, targetLang: altLang);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF16A34A)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                altLang == 'en' ? '🔊 EN' : '🔊 አማ',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error, bool isAm) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade900.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: Colors.red),
            onPressed: () => ref.read(aiVoiceProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // 3. UNIVERSAL BOTTOM CONTROL BAR
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildBottomControlBar(
    BuildContext context,
    AiVoiceState state,
    bool isDark,
    bool isAm,
  ) {
    final isRec = state.isRecording;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: isRec
          ? Row(
              children: [
                // Pulsing Red Recording Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(_recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.liveTranscript.isEmpty
                        ? (isAm ? 'ድምፅ በመቅዳት ላይ...' : 'Listening to voice...')
                        : state.liveTranscript,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  tooltip: 'Cancel',
                  onPressed: _handleCancelRecording,
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 30),
                  tooltip: 'Submit',
                  onPressed: _handleMicPressed,
                ),
              ],
            )
          : Row(
              children: [
                // Microphone Recording Button
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                    tooltip: isAm ? 'ድምፅ ለመቅረጽ ይጫኑ' : 'Record voice',
                    onPressed: _handleMicPressed,
                  ),
                ),
                const SizedBox(width: 8),

                // Text Input Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _submitTextQuery,
                      decoration: InputDecoration(
                        hintText: isAm
                            ? 'በአማርኛ ወይም በእንግሊዝኛ ይጠይቁ...'
                            : 'Type question or tap mic...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Text Submit Button
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF16A34A)),
                  tooltip: 'Send text',
                  onPressed: () => _submitTextQuery(_textController.text),
                ),
              ],
            ),
    );
  }
}
