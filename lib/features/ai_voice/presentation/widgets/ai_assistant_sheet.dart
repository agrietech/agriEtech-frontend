import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/ai_voice_provider.dart';

/// Interactive AI Voice & Agronomic Assistant Bottom Sheet
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

class _AiAssistantSheetState extends ConsumerState<AiAssistantSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
  }

  void _stopAndSendRecording() {
    if (!_isRecording) return;
    setState(() => _isRecording = false);

    final lang = ref.read(aiVoiceProvider).language;
    final defaultQuestions = {
      'am': 'የጤፍ እና የስንዴ መዝሪያ ወቅት እና የማዳበሪያ አጠቃቀም መመሪያ ቢነግሩኝ?',
      'en': 'What is the agronomic advisory for Teff and Wheat planting, rust prevention, and fertilizer schedule this season?',
    };
    final simulatedVoiceQuestion = defaultQuestions[lang] ?? defaultQuestions['am']!;
    _submitQuestion(simulatedVoiceQuestion);
  }

  void _submitQuestion(String query) {
    final text = query.trim();
    if (text.isEmpty) return;

    _questionController.clear();
    FocusScope.of(context).unfocus();

    ref.read(aiVoiceProvider.notifier).sendQuestion(text);
    _scrollToBottom();
  }

  Future<void> _playVoiceAudio(String? audioUrl, String text) async {
    final lang = ref.read(aiVoiceProvider).language;
    final encodedText = Uri.encodeComponent(text.length > 200 ? text.substring(0, 200) : text);
    final streamUrl = audioUrl ?? 'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedText&tl=$lang&client=tw-ob';

    try {
      final uri = Uri.parse(streamUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang == 'am' ? 'የድምፅ ንባብ ተጀምሯል...' : 'Playing AI Voice speech...'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'am' ? 'የድምፅ ንባብ ተጀምሯል...' : 'Playing AI Voice speech...'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiVoiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic = aiState.language == 'am';

    final quickVoiceChips = isAmharic
        ? [
            '🌾 ጤፍ ለመዝራት የተሻለው ወቅት መቼ ነው?',
            '🌽 የበቆሎ አባጨጓሬ (ፎል አርሚዎርም) መከላከያ',
            '🌾 የስንዴ ግንድ ዋግ በሽታ መከላከያ ዘዴዎች',
            '💧 የአፈር እርጥበት እና የመስኖ አጠቃቀም',
            '🧪 የዩሪያ እና የNPS ማዳበሪያ አጠቃቀም',
            '⛅ የአየር ሁኔታ እና የዝናብ ትንበያ',
          ]
        : [
            '🌾 Best time to plant Teff & spacing?',
            '🌽 Maize Fall Armyworm IPM control',
            '🌾 Wheat Stem Rust fungicide treatment',
            '💧 Soil moisture & furrow irrigation',
            '🧪 Urea & NPS balanced fertilizer guide',
            '⛅ Weather & climate risk forecast',
          ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141F14) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAmharic ? 'የአግሪቴክ AI ድምፅ ረዳት' : 'AgriEtech AI Voice Assistant',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isAmharic ? 'በአማርኛ ወይም በእንግሊዝኛ ይናገሩ ወይም ይተይቡ' : 'Speak or type in Amharic & English',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Language Switcher
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(aiVoiceProvider.notifier).setLanguage('am'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAmharic ? AppTheme.secondaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'አማ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: isAmharic ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(aiVoiceProvider.notifier).setLanguage('en'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !isAmharic ? AppTheme.secondaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: !isAmharic ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages List & Quick Chips
          Expanded(
            child: Column(
              children: [
                // Quick Chips Carousel
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: isDark ? const Color(0xFF1E2E1E) : const Color(0xFFF1F8F1),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: quickVoiceChips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final chipText = quickVoiceChips[idx];
                      return ActionChip(
                        label: Text(
                          chipText,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white : AppTheme.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: isDark ? const Color(0xFF2B402B) : Colors.white,
                        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                        onPressed: () => _submitQuestion(chipText.replaceFirst(RegExp(r'^[^\s]+\s+'), '')),
                      );
                    },
                  ),
                ),

                // Conversation Chat Messages
                Expanded(
                  child: aiState.messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.psychology, size: 48, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isAmharic ? 'የኢትዮጵያ ግብርና AI ድምፅ ረዳት' : 'Ethiopian Agronomic AI Voice Assistant',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAmharic
                                      ? 'ስለ ጤፍ፣ ስንዴ፣ በቆሎ፣ አባጨጓሬ፣ ማዳበሪያና የአፈር እንክብካቤ በማይክሮፎኑ ተጭነው ይጠይቁ።'
                                      : 'Tap the mic or select a topic to get instant, scientifically tailored crop advice in Amharic & English.',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: aiState.messages.length + (aiState.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == aiState.messages.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isAmharic ? 'የግብርና AI መልስ በማዘጋጀት ላይ ነው...' : 'Generating agronomic advisory...',
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final msg = aiState.messages[index];
                            final isUser = msg.isUser;
                            final audioUrl = msg.aiResponse?.audioUrlAm ?? msg.aiResponse?.audioUrlEn ?? aiState.lastResponse?.audioUrlAm ?? aiState.lastResponse?.audioUrlEn;

                            if (isUser) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10, left: 48),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B5E20),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14, right: 32),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2F1F) : const Color(0xFFF4F7F4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.eco, size: 16, color: Color(0xFF2E7D32)),
                                          const SizedBox(width: 6),
                                          Text(
                                            isAmharic ? 'የግብርና መመሪያ' : 'Agronomic Guidance',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF2E7D32)),
                                        tooltip: isAmharic ? 'ድምፅ አጫውት' : 'Listen with Voice Speech',
                                        onPressed: () => _playVoiceAudio(audioUrl, msg.text),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SelectableText(
                                    msg.text,
                                    style: const TextStyle(fontSize: 13.5, height: 1.45),
                                  ),
                                  if (msg.aiResponse?.recommendedAction != null &&
                                      msg.aiResponse!.recommendedAction!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF2E7D32)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Action: ${msg.aiResponse!.recommendedAction!}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Bottom Input & Voice Recording Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF172417) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _isRecording
                  ? AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withValues(alpha: 0.15 + _pulseController.value * 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mic, color: Colors.red, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isAmharic ? 'ድምፅዎን በማዳመጥ ላይ ነው... ሲጨርሱ ይልኩ' : 'Listening to your voice... Tap to send',
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                                onPressed: _stopAndSendRecording,
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey, size: 24),
                                onPressed: () => setState(() => _isRecording = false),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Row(
                      children: [
                        // Mic Button
                        GestureDetector(
                          onTap: _startRecording,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _questionController,
                            decoration: InputDecoration(
                              hintText: isAmharic ? 'ጥያቄዎን እዚህ ይጻፉ ወይም ማይክሮፎኑን ይጫኑ...' : 'Ask crop or disease question...',
                              hintStyle: const TextStyle(fontSize: 12.5),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF213321) : const Color(0xFFF1F5F1),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: _submitQuestion,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send Button
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF2E7D32)),
                          onPressed: () => _submitQuestion(_questionController.text),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
