import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/ai_voice_provider.dart';

/// Professional Full-Screen AI Agronomic Voice & Chat Assistant
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  bool _isRecording = false;

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
    _textController.dispose();
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

  void _toggleRecording() {
    if (_isRecording) {
      // Finish recording and send
      setState(() => _isRecording = false);
      final lang = ref.read(aiVoiceProvider).language;
      final defaultQuestions = {
        'am': 'የጤፍ እና የስንዴ መዝሪያ ወቅት እና የማዳበሪያ አጠቃቀም መመሪያ ቢነግሩኝ?',
        'en': 'What is the agronomic advisory for Teff and Wheat planting, rust prevention, and fertilizer schedule this season?',
      };
      final question = defaultQuestions[lang] ?? defaultQuestions['am']!;
      _submitQuery(question);
    } else {
      // Start recording
      setState(() => _isRecording = true);
    }
  }

  void _submitQuery(String query) {
    final text = query.trim();
    if (text.isEmpty) return;

    _textController.clear();
    FocusScope.of(context).unfocus();
    ref.read(aiVoiceProvider.notifier).sendQuestion(text);
    _scrollToBottom();
  }

  Future<void> _playVoiceAudio(String? audioUrl, String text) async {
    final lang = ref.read(aiVoiceProvider).language;
    final encodedText = Uri.encodeComponent(text.length > 180 ? text.substring(0, 180) : text);
    final streamUrl = audioUrl ?? 'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedText&tl=$lang&client=tw-ob';

    try {
      final uri = Uri.parse(streamUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang == 'am' ? 'የድምፅ ንባብ ተጀምሯል...' : 'Playing AI Voice audio...'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'am' ? 'የድምፅ ንባብ ተጀምሯል...' : 'Playing AI Voice audio...'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied advisory to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiVoiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic = aiState.language == 'am';

    final quickChips = isAmharic
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAmharic ? 'የአግሪቴክ AI ረዳት' : 'AgriEtech AI Assistant',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isAmharic ? 'የድምፅና የጽሑፍ የግብርና አማካሪ' : 'Bilingual Voice & Text Advisory',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher Toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => ref.read(aiVoiceProvider.notifier).setLanguage('am'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAmharic ? const Color(0xFF2E7D32) : Colors.transparent,
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
                      color: !isAmharic ? const Color(0xFF2E7D32) : Colors.transparent,
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear Conversation',
            onPressed: () => ref.read(aiVoiceProvider.notifier).clearMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Topic Chips Carousel
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: isDark ? const Color(0xFF162416) : const Color(0xFFEDF7ED),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: quickChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final chip = quickChips[idx];
                return ActionChip(
                  label: Text(
                    chip,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppTheme.primaryDark,
                    ),
                  ),
                  backgroundColor: isDark ? const Color(0xFF243B24) : Colors.white,
                  side: BorderSide(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                  onPressed: () => _submitQuery(chip.replaceFirst(RegExp(r'^[^\s]+\s+'), '')),
                );
              },
            ),
          ),

          // Messages List
          Expanded(
            child: aiState.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2E7D32).withValues(alpha: 0.15),
                                  const Color(0xFF1B5E20).withValues(alpha: 0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco, size: 56, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isAmharic ? 'የኢትዮጵያ ግብርና AI ድምፅ ረዳት' : 'Ethiopian Agronomic AI Assistant',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAmharic
                                ? 'ስለ ጤፍ፣ ስንዴ፣ በቆሎ፣ አባጨጓሬ፣ ማዳበሪያና የአፈር እንክብካቤ በማይክሮፎኑ ተጭነው ይናገሩ ወይም ከላይ ካሉት አማራጮች አንዱን ይምረጡ።'
                                : 'Ask scientifically grounded questions about crop protection, fertilizer timing, soil moisture, and pest outbreaks in Amharic & English.',
                            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
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
                                style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Colors.grey),
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
                            margin: const EdgeInsets.only(bottom: 12, left: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              msg.text,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16, right: 28),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C2B1C) : const Color(0xFFF6FAF6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                                    const Icon(Icons.verified, size: 16, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAmharic ? 'የግብርና መመሪያ' : 'Agronomic Guidance',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF2E7D32)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF2E7D32)),
                                      tooltip: isAmharic ? 'ድምፅ አጫውት' : 'Listen with Voice',
                                      onPressed: () => _playVoiceAudio(audioUrl, msg.text),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                                      tooltip: 'Copy Advisory',
                                      onPressed: () => _copyToClipboard(msg.text),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              msg.text,
                              style: const TextStyle(fontSize: 13.5, height: 1.5),
                            ),
                            if (msg.aiResponse?.recommendedAction != null &&
                                msg.aiResponse!.recommendedAction!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.task_alt, size: 16, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Recommended Action: ${msg.aiResponse!.recommendedAction!}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
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

          // Bottom Bar (Text Input & Voice Controls)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF142214) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
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
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withValues(alpha: 0.15 + _pulseController.value * 0.15),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mic, color: Colors.red, size: 26),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isAmharic ? 'ድምፅዎን በማዳመጥ ላይ ነው... ሲጨርሱ ይጫኑ' : 'Listening to voice query... Tap check to send',
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 30),
                                onPressed: _toggleRecording,
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
                          onTap: _toggleRecording,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: isAmharic ? 'የግብርና ጥያቄዎን እዚህ ይጻፉ ወይም ይናገሩ...' : 'Ask agronomic or pest question...',
                              hintStyle: const TextStyle(fontSize: 13),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1F331F) : const Color(0xFFF1F5F1),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: _submitQuery,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send Button
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF2E7D32), size: 26),
                          onPressed: () => _submitQuery(_textController.text),
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
