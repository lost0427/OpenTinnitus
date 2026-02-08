import 'package:flutter/material.dart';
import 'tinnitus_audio_service.dart';
import 'storage_service.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final TinnitusAudioService _audioService = TinnitusAudioService();
  final StorageService _storageService = StorageService();

  // Tone Volume
  double _toneVolumeLeft = 0.5;
  double _toneVolumeRight = 0.5;

  // Masking Sound
  String? _selectedMaskingSound;
  double _maskingSoundVolumeLeft = 0.5;
  double _maskingSoundVolumeRight = 0.5;

  final Map<String, String> _maskingSounds = {
    '无遮蔽声': '',
    '雨': 'assets/audio/masking_sounds/rain.ogg',
    '鸟类': 'assets/audio/masking_sounds/birds.ogg',
    '河和鸟': 'assets/audio/masking_sounds/river_and_birds.ogg',
    '蟋蟀': 'assets/audio/masking_sounds/crickets.ogg',
  };

  // Masking Noise
  String? _selectedMaskingNoise;
  double _maskingNoiseVolumeLeft = 0.5;
  double _maskingNoiseVolumeRight = 0.5;

  final Map<String, String> _maskingNoises = {
    '无遮蔽噪声': '',
    '白色': 'assets/audio/masking_noise/white_noise_short_o.ogg',
    '粉色': 'assets/audio/masking_noise/pink_noise_short_o.ogg',
    '棕色': 'assets/audio/masking_noise/brown_noise_short_o.ogg',
    '棕色（平滑）': 'assets/audio/masking_noise/brown_noise_smoothed_short_o.ogg',
    '紫色': 'assets/audio/masking_noise/violet.ogg',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final toneVol = await _storageService.loadToneVolume();
    final maskSound = await _storageService.loadMaskingSound();
    final maskSoundVol = await _storageService.loadMaskingSoundVolume();
    final maskNoise = await _storageService.loadMaskingNoise();
    final maskNoiseVol = await _storageService.loadMaskingNoiseVolume();

    setState(() {
      _toneVolumeLeft = toneVol['left']!;
      _toneVolumeRight = toneVol['right']!;

      _selectedMaskingSound = maskSound ?? '';
      _maskingSoundVolumeLeft = maskSoundVol['left']!;
      _maskingSoundVolumeRight = maskSoundVol['right']!;

      _selectedMaskingNoise = maskNoise ?? '';
      _maskingNoiseVolumeLeft = maskNoiseVol['left']!;
      _maskingNoiseVolumeRight = maskNoiseVol['right']!;
    });
    // Do NOT auto-play or modify audio here.
    // All playback is controlled by the HomePage play button.
  }

  void _updateToneVolume() {
    _audioService.setToneVolume(_toneVolumeLeft, _toneVolumeRight);
    _storageService.saveToneVolume(_toneVolumeLeft, _toneVolumeRight);
  }

  void _updateMaskingSound(String? assetPath) {
    setState(() {
      _selectedMaskingSound = assetPath ?? '';
    });
    _storageService.saveMaskingSound(_selectedMaskingSound!);
    if (_selectedMaskingSound!.isEmpty) {
      _audioService.stopMaskingSound();
    } else {
      // Immediately play the new selection so the change takes effect right away
      _audioService.playMaskingSound(_selectedMaskingSound!);
    }
  }

  void _updateMaskingSoundVolume() {
    _audioService.setMaskingSoundVolume(
      _maskingSoundVolumeLeft,
      _maskingSoundVolumeRight,
    );
    _storageService.saveMaskingSoundVolume(
      _maskingSoundVolumeLeft,
      _maskingSoundVolumeRight,
    );
  }

  void _updateMaskingNoise(String? assetPath) {
    setState(() {
      _selectedMaskingNoise = assetPath ?? '';
    });
    _storageService.saveMaskingNoise(_selectedMaskingNoise!);
    if (_selectedMaskingNoise!.isEmpty) {
      _audioService.stopMaskingNoise();
    } else {
      // Immediately play the new selection so the change takes effect right away
      _audioService.playMaskingNoise(_selectedMaskingNoise!);
    }
  }

  void _updateMaskingNoiseVolume() {
    _audioService.setMaskingNoiseVolume(
      _maskingNoiseVolumeLeft,
      _maskingNoiseVolumeRight,
    );
    _storageService.saveMaskingNoiseVolume(
      _maskingNoiseVolumeLeft,
      _maskingNoiseVolumeRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选项'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Tone Volume
          const Text(
            '治疗音调音量',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildVolumeSliders(
            leftValue: _toneVolumeLeft,
            rightValue: _toneVolumeRight,
            onLeftChanged: (v) {
              setState(() => _toneVolumeLeft = v);
              _updateToneVolume();
            },
            onRightChanged: (v) {
              setState(() => _toneVolumeRight = v);
              _updateToneVolume();
            },
          ),

          const Divider(height: 40),

          // Masking Sound
          const Text(
            '遮蔽声',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _selectedMaskingSound,
            isExpanded: true,
            items: _maskingSounds.entries.map((e) {
              return DropdownMenuItem(value: e.value, child: Text(e.key));
            }).toList(),
            onChanged: _updateMaskingSound,
          ),
          const SizedBox(height: 10),
          const Text('遮蔽音量', style: TextStyle(fontSize: 16)),
          _buildVolumeSliders(
            leftValue: _maskingSoundVolumeLeft,
            rightValue: _maskingSoundVolumeRight,
            onLeftChanged: (v) {
              setState(() => _maskingSoundVolumeLeft = v);
              _updateMaskingSoundVolume();
            },
            onRightChanged: (v) {
              setState(() => _maskingSoundVolumeRight = v);
              _updateMaskingSoundVolume();
            },
          ),

          const Divider(height: 40),

          // Masking Noise
          const Text(
            '遮蔽噪声',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _selectedMaskingNoise,
            isExpanded: true,
            items: _maskingNoises.entries.map((e) {
              return DropdownMenuItem(value: e.value, child: Text(e.key));
            }).toList(),
            onChanged: _updateMaskingNoise,
          ),
          const SizedBox(height: 10),
          const Text('遮蔽噪音声音', style: TextStyle(fontSize: 16)),
          _buildVolumeSliders(
            leftValue: _maskingNoiseVolumeLeft,
            rightValue: _maskingNoiseVolumeRight,
            onLeftChanged: (v) {
              setState(() => _maskingNoiseVolumeLeft = v);
              _updateMaskingNoiseVolume();
            },
            onRightChanged: (v) {
              setState(() => _maskingNoiseVolumeRight = v);
              _updateMaskingNoiseVolume();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSliders({
    required double leftValue,
    required double rightValue,
    required ValueChanged<double> onLeftChanged,
    required ValueChanged<double> onRightChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 30, child: Text('左')),
            Expanded(
              child: Slider(
                value: leftValue,
                min: 0.0,
                max: 1.0,
                onChanged: onLeftChanged,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 30, child: Text('右')),
            Expanded(
              child: Slider(
                value: rightValue,
                min: 0.0,
                max: 1.0,
                onChanged: onRightChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
