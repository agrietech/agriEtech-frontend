import 'package:audioplayers/audioplayers.dart';

/// Universal In-App Audio Streamer for playing TTS and voice advisories
/// directly on the current screen without opening external pages or new tabs.
class InAppAudioPlayer {
  static final InAppAudioPlayer instance = InAppAudioPlayer._();
  InAppAudioPlayer._();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playAudioUrl(String url, {Function()? onComplete, Function(String)? onError}) async {
    try {
      await _player.stop();
      _isPlaying = true;
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        onComplete?.call();
      });
      await _player.play(UrlSource(url));
    } catch (e) {
      _isPlaying = false;
      onError?.call(e.toString());
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
  }

  bool isPlaying() => _isPlaying;
}
