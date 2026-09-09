import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'logger.dart';

/// Universal In-App Audio Streamer for playing TTS and voice advisories
/// directly on the current screen without opening external pages or crashing on unsupported platforms.
class InAppAudioPlayer {
  static final InAppAudioPlayer instance = InAppAudioPlayer._();
  InAppAudioPlayer._() {
    _initPlayer();
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription? _completeSub;
  StreamSubscription? _stateSub;
  Function()? _currentOnComplete;
  Function(String)? _currentOnError;

  void _initPlayer() {
    _completeSub = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      final cb = _currentOnComplete;
      _currentOnComplete = null;
      _currentOnError = null;
      cb?.call();
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _isPlaying = false;
      } else if (state == PlayerState.playing) {
        _isPlaying = true;
      }
    });
  }

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
      _currentOnComplete = onComplete;
      _currentOnError = onError;

      await _player.play(UrlSource(cleanUrl));
    } catch (e) {
      _isPlaying = false;
      _currentOnComplete = null;
      final errCb = _currentOnError;
      _currentOnError = null;
      AppLogger.warning('Audio playback error (graceful fallback): $e');
      errCb?.call(e.toString());
    }
  }

  Future<void> stop() async {
    try {
      _isPlaying = false;
      _currentOnComplete = null;
      _currentOnError = null;
      await _player.stop();
    } catch (e) {
      AppLogger.warning('AudioPlayer stop error: $e');
    }
  }

  bool isPlaying() => _isPlaying;

  void dispose() {
    _completeSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
  }
}

