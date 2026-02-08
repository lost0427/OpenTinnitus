import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'soloud_player.dart';

class TinnitusAudioService {
  // Singleton pattern for the service wrapper itself if needed,
  // but main.dart creates a new instance.
  // However, AudioService.init returns a singleton handler.

  static AudioHandler? _audioHandler;

  Future<void> init() async {
    if (_audioHandler != null) return;

    _audioHandler = await AudioService.init(
      builder: () => TinnitusAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.opentinnitus.channel.audio',
        androidNotificationChannelName: 'OpenTinnitus Audio',
        androidNotificationOngoing: true,
        notificationColor: Color(0xFF009688), // Teal
      ),
    );
  }

  Future<void> dispose() async {
    if (_audioHandler != null) {
      await _audioHandler!.stop();
    }
  }

  // --- Tone ---

  Future<void> playTone(double frequency) async {
    await _ensureInit();
    await _audioHandler!.customAction('playTone', {'frequency': frequency});
    await _audioHandler!.play(); // Ensure state is playing
  }

  Future<void> setToneFrequency(double frequency) async {
    await _ensureInit();
    await _audioHandler!.customAction('setToneFrequency', {
      'frequency': frequency,
    });
  }

  Future<void> setToneVolume(double left, double right) async {
    await _ensureInit();
    await _audioHandler!.customAction('setToneVolume', {
      'left': left,
      'right': right,
    });
  }

  Future<void> stopTone() async {
    await _ensureInit();
    await _audioHandler!.customAction('stopTone');
    _checkIfShouldStop();
  }

  // --- Masking Sound ---

  Future<void> playMaskingSound(String assetPath) async {
    await _ensureInit();
    await _audioHandler!.customAction('playMaskingSound', {
      'assetPath': assetPath,
    });
    await _audioHandler!.play();
  }

  Future<void> setMaskingSoundVolume(double left, double right) async {
    await _ensureInit();
    await _audioHandler!.customAction('setMaskingSoundVolume', {
      'left': left,
      'right': right,
    });
  }

  Future<void> stopMaskingSound() async {
    await _ensureInit();
    await _audioHandler!.customAction('stopMaskingSound');
    _checkIfShouldStop();
  }

  // --- Masking Noise ---

  Future<void> playMaskingNoise(String assetPath) async {
    await _ensureInit();
    await _audioHandler!.customAction('playMaskingNoise', {
      'assetPath': assetPath,
    });
    await _audioHandler!.play();
  }

  Future<void> setMaskingNoiseVolume(double left, double right) async {
    await _ensureInit();
    await _audioHandler!.customAction('setMaskingNoiseVolume', {
      'left': left,
      'right': right,
    });
  }

  Future<void> stopMaskingNoise() async {
    await _ensureInit();
    await _audioHandler!.customAction('stopMaskingNoise');
    _checkIfShouldStop();
  }

  Future<void> _ensureInit() async {
    if (_audioHandler == null) {
      await init();
    }
  }

  Future<void> _checkIfShouldStop() async {
    // Logic to check if all sounds are stopped, then update state to stopped.
    // For now, let the handler manage state logic or explicitly call stop if needed.
    // But typically, if specific sounds are stopped, we might still be in "playing" mode logically.
    // We'll let the UI decide when to call full stop, or the handler can decide.
    // The handler can track active sources.
    await _audioHandler!.customAction('checkAutoStop');
  }
}

class TinnitusAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final SoLoudPlayer _player = SoLoudPlayer();

  // Track active states to manage PlaybackState
  bool _isTonePlaying = false;
  bool _isMaskingSoundPlaying = false;
  bool _isMaskingNoisePlaying = false;

  TinnitusAudioHandler() {
    _player.init().then((_) {
      // Initial state
      _updatePlaybackState();
    });
  }

  bool get _isPlaying =>
      _isTonePlaying || _isMaskingSoundPlaying || _isMaskingNoisePlaying;

  void _updatePlaybackState() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (_isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: AudioProcessingState.ready,
        playing: _isPlaying,
      ),
    );

    // Update MediaItem to show something in notification
    mediaItem.add(
      MediaItem(
        id: 'opentinnitus_session',
        album: 'OpenTinnitus',
        title: 'Tinnitus Therapy',
        artist: 'OpenTinnitus',
        duration: null,
        artUri: null, // Could add a launcher icon URI here
      ),
    );
  }

  @override
  Future<void> play() async {
    // Resume or just update state.
    // Since we control specific sounds, 'play' typically resumes last state,
    // but here we might just set state to playing if invoked from headset hook.
    // For now, assume Play triggers state update.
    _updatePlaybackState();
  }

  @override
  Future<void> pause() async {
    // Pause all
    _player.stopAll();
    _isTonePlaying = false;
    _isMaskingSoundPlaying = false;
    _isMaskingNoisePlaying = false;
    _updatePlaybackState();
  }

  @override
  Future<void> stop() async {
    _player.stopAll();
    _isTonePlaying = false;
    _isMaskingSoundPlaying = false;
    _isMaskingNoisePlaying = false;

    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
    // Do not call super.stop() if you want to keep service alive?
    // Actually BaseAudioHandler stop is usually empty.
    await super.stop();
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? arguments,
  ]) async {
    switch (name) {
      case 'playTone':
        final frequency = arguments!['frequency'] as double;
        await _player.playTone(frequency);
        _isTonePlaying = true;
        _updatePlaybackState();
        break;
      case 'setToneFrequency':
        final frequency = arguments!['frequency'] as double;
        _player.setToneFrequency(frequency);
        break;
      case 'setToneVolume':
        final left = arguments!['left'] as double;
        final right = arguments!['right'] as double;
        _player.setToneVolume(left, right);
        break;
      case 'stopTone':
        _player.stopTone();
        _isTonePlaying = false;
        break;

      case 'playMaskingSound':
        final assetPath = arguments!['assetPath'] as String;
        await _player.playMaskingSound(assetPath);
        _isMaskingSoundPlaying = true;
        _updatePlaybackState();
        break;
      case 'setMaskingSoundVolume':
        final left = arguments!['left'] as double;
        final right = arguments!['right'] as double;
        _player.setMaskingSoundVolume(left, right);
        break;
      case 'stopMaskingSound':
        _player.stopMaskingSound();
        _isMaskingSoundPlaying = false;
        break;

      case 'playMaskingNoise':
        final assetPath = arguments!['assetPath'] as String;
        await _player.playMaskingNoise(assetPath);
        _isMaskingNoisePlaying = true;
        _updatePlaybackState();
        break;
      case 'setMaskingNoiseVolume':
        final left = arguments!['left'] as double;
        final right = arguments!['right'] as double;
        _player.setMaskingNoiseVolume(left, right);
        break;
      case 'stopMaskingNoise':
        _player.stopMaskingNoise();
        _isMaskingNoisePlaying = false;
        break;

      case 'checkAutoStop':
        _updatePlaybackState();
        // If not playing anything, we could switch to idle, but let's keep it ready until explicit stop
        if (!_isPlaying) {
          playbackState.add(
            playbackState.value.copyWith(
              playing: false,
              // processingState: AudioProcessingState.idle, // Keep ready?
            ),
          );
        }
        break;
    }
  }
}
