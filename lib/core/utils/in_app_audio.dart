import 'package:audioplayers/audioplayers.dart';
import 'logger.dart';

/// Universal In-App Audio Streamer for playing TTS and voice advisories
/// directly on the current screen without opening external pages or crashing on unsupported platforms.
class InAppAudioPlayer {
  static final InAppAudioPlayer instance = InAppAudioPlayer._();
  InAppAudioPlayer._();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playAudioUrl(
    String url, {
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      AppLogger.warning('Invalid or empty audio URL: $url');
      onError?.call('Invalid audio URL');
      return;
    }

    try {
      await _player.stop();
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        onComplete?.call();
      });

      _player.onLog.listen((msg) {
        AppLogger.info('AudioPlayer log: $msg');
      });

      await _player.play(UrlSource(cleanUrl));
    } catch (e) {
      _isPlaying = false;
      AppLogger.warning('Audio playback error (graceful fallback): $e');
      onError?.call(e.toString());
    }
  }

  Future<void> stop() async {
    try {
      _isPlaying = false;
      await _player.stop();
    } catch (e) {
      AppLogger.warning('AudioPlayer stop error: $e');
    }
  }

  bool isPlaying() => _isPlaying;
}
