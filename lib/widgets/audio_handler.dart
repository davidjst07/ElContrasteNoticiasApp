import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class RadioAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final String streamUrl = 'https://stream.zeno.fm/3u4rvdaxhrhvv';
  static bool _isInitialized = false;

   RadioAudioHandler() {
    if (!_isInitialized) {
      _init();
      _isInitialized = true;
    }
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(streamUrl);
      
      _player.playbackEventStream.listen((event) {
        playbackState.add(PlaybackState(
          controls: [
            MediaControl.play,
            MediaControl.pause,
            MediaControl.stop,
          ],
          androidCompactActionIndices: [0, 1, 2],
          playing: _player.playing,
          processingState: AudioProcessingState.ready,
        ));
      });
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }
}