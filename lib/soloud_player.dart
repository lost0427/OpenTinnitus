import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';

class SoLoudPlayer {
  static final SoLoudPlayer _instance = SoLoudPlayer._internal();

  factory SoLoudPlayer() {
    return _instance;
  }

  SoLoudPlayer._internal();

  AudioSource? _toneSource;
  SoundHandle? _toneHandle;

  AudioSource? _maskingSoundSource;
  SoundHandle? _maskingSoundHandle;

  AudioSource? _maskingNoiseSource;
  SoundHandle? _maskingNoiseHandle;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await SoLoud.instance.init();
      _isInitialized = true;
      debugPrint('SoLoudPlayer: Init success');
    } catch (e) {
      debugPrint('SoLoudPlayer: Init failed: $e');
    }
  }

  // --- Treatment Tone ---

  Future<void> playTone(double frequency) async {
    if (!_isInitialized) await init();

    if (_toneHandle != null) {
      if (SoLoud.instance.getIsValidVoiceHandle(_toneHandle!)) {
        setToneFrequency(frequency);
        return;
      } else {
        _toneHandle = null;
      }
    }

    if (_toneSource == null) {
      try {
        _toneSource = await SoLoud.instance.loadWaveform(
          WaveForm.sin,
          true, // SuperWave enabled
          0.25,
          1.0,
        );
      } catch (e) {
        debugPrint('SoLoudPlayer: Error loading tone: $e');
        return;
      }
    }

    try {
      _toneHandle = await SoLoud.instance.play(_toneSource!);
      SoLoud.instance.setLooping(_toneHandle!, true);
      SoLoud.instance.setProtectVoice(
        _toneHandle!,
        true,
      ); // Prevent voice stealing
      setToneFrequency(frequency);
    } catch (e) {
      debugPrint('SoLoudPlayer: Error playing tone: $e');
    }
  }

  void setToneFrequency(double frequency) {
    if (_toneSource == null) return;

    // Use setWaveformFreq to set the frequency of the waveform source
    SoLoud.instance.setWaveformFreq(_toneSource!, frequency);
  }

  void setToneVolume(double left, double right) {
    if (_toneHandle == null) return;
    if (!SoLoud.instance.getIsValidVoiceHandle(_toneHandle!)) return;

    // Pan: -1.0 (Left) to 1.0 (Right)
    // Volume: 0.0 to 1.0 (Max of L/R)
    double pan = 0.0;
    double volume = (left > right) ? left : right;

    if (left + right > 0) {
      pan = (right - left) / (right + left);
    }

    SoLoud.instance.setPan(_toneHandle!, pan);
    SoLoud.instance.setVolume(_toneHandle!, volume);
  }

  void stopTone() {
    if (_toneHandle != null) {
      if (SoLoud.instance.getIsValidVoiceHandle(_toneHandle!)) {
        SoLoud.instance.stop(_toneHandle!);
      }
      _toneHandle = null;
    }
  }

  // --- Masking Sound (Nature) ---

  Future<void> playMaskingSound(String assetPath) async {
    if (!_isInitialized) await init();

    // Stop previous if exists
    stopMaskingSound();

    if (assetPath.isEmpty || assetPath.contains('silence')) return;

    try {
      // Re-load source every time to switch assets easily
      _maskingSoundSource = await SoLoud.instance.loadAsset(assetPath);
      _maskingSoundHandle = await SoLoud.instance.play(_maskingSoundSource!);
      SoLoud.instance.setLooping(_maskingSoundHandle!, true);

      // Default volume
      SoLoud.instance.setVolume(_maskingSoundHandle!, 1.0);
    } catch (e) {
      debugPrint('SoLoudPlayer: Error playing masking sound ($assetPath): $e');
    }
  }

  void setMaskingSoundVolume(double left, double right) {
    if (_maskingSoundHandle == null) return;
    if (!SoLoud.instance.getIsValidVoiceHandle(_maskingSoundHandle!)) return;

    double pan = 0.0;
    double volume = (left > right) ? left : right;

    if (left + right > 0) {
      pan = (right - left) / (right + left);
    }

    SoLoud.instance.setPan(_maskingSoundHandle!, pan);
    SoLoud.instance.setVolume(_maskingSoundHandle!, volume);
  }

  void stopMaskingSound() {
    if (_maskingSoundHandle != null) {
      if (SoLoud.instance.getIsValidVoiceHandle(_maskingSoundHandle!)) {
        SoLoud.instance.stop(_maskingSoundHandle!);
      }
      _maskingSoundHandle = null;
    }
    // Note: In a real app we might want to dispose the source to free memory
    // if we are sure we won't use it again soon.
    if (_maskingSoundSource != null) {
      // SoLoud.instance.disposeSource(_maskingSoundSource!);
      // Implement this if memory is an issue
      _maskingSoundSource = null;
    }
  }

  // --- Masking Noise ---

  Future<void> playMaskingNoise(String assetPath) async {
    if (!_isInitialized) await init();

    stopMaskingNoise();

    if (assetPath.isEmpty || assetPath.contains('silence')) return;

    try {
      _maskingNoiseSource = await SoLoud.instance.loadAsset(assetPath);
      _maskingNoiseHandle = await SoLoud.instance.play(_maskingNoiseSource!);
      SoLoud.instance.setLooping(_maskingNoiseHandle!, true);
      SoLoud.instance.setVolume(_maskingNoiseHandle!, 1.0);
    } catch (e) {
      debugPrint('SoLoudPlayer: Error playing masking noise ($assetPath): $e');
    }
  }

  void setMaskingNoiseVolume(double left, double right) {
    if (_maskingNoiseHandle == null) return;
    if (!SoLoud.instance.getIsValidVoiceHandle(_maskingNoiseHandle!)) return;

    double pan = 0.0;
    double volume = (left > right) ? left : right;

    if (left + right > 0) {
      pan = (right - left) / (right + left);
    }

    SoLoud.instance.setPan(_maskingNoiseHandle!, pan);
    SoLoud.instance.setVolume(_maskingNoiseHandle!, volume);
  }

  void stopMaskingNoise() {
    if (_maskingNoiseHandle != null) {
      if (SoLoud.instance.getIsValidVoiceHandle(_maskingNoiseHandle!)) {
        SoLoud.instance.stop(_maskingNoiseHandle!);
      }
      _maskingNoiseHandle = null;
    }
    if (_maskingNoiseSource != null) {
      _maskingNoiseSource = null;
    }
  }

  void stopAll() {
    stopTone();
    stopMaskingSound();
    stopMaskingNoise();
  }

  void dispose() {
    stopAll();
    SoLoud.instance.deinit();
    _isInitialized = false;
  }
}
