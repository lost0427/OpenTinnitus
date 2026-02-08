import 'package:flutter/material.dart';
import 'tinnitus_audio_service.dart';
import 'storage_service.dart';
import 'options_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTinnitus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _frequency = 1000.0;
  bool _isPlaying = false;
  final TinnitusAudioService _audioService = TinnitusAudioService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Initialize audio service
    _audioService.init();
    _loadFrequency();
  }

  Future<void> _loadFrequency() async {
    final savedFrequency = await _storageService.loadFrequency();
    if (savedFrequency != null) {
      setState(() {
        _frequency = savedFrequency;
      });
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      await _startAllAudio();
    } else {
      _stopAllAudio();
    }
  }

  Future<void> _startAllAudio() async {
    // Load and apply all saved settings
    final toneVol = await _storageService.loadToneVolume();
    final maskSound = await _storageService.loadMaskingSound();
    final maskSoundVol = await _storageService.loadMaskingSoundVolume();
    final maskNoise = await _storageService.loadMaskingNoise();
    final maskNoiseVol = await _storageService.loadMaskingNoiseVolume();

    // Start tone
    await _audioService.playTone(_frequency);
    _audioService.setToneVolume(toneVol['left']!, toneVol['right']!);

    // Start masking sound if selected
    if (maskSound != null && maskSound.isNotEmpty) {
      await _audioService.playMaskingSound(maskSound);
      _audioService.setMaskingSoundVolume(
        maskSoundVol['left']!,
        maskSoundVol['right']!,
      );
    }

    // Start masking noise if selected
    if (maskNoise != null && maskNoise.isNotEmpty) {
      await _audioService.playMaskingNoise(maskNoise);
      _audioService.setMaskingNoiseVolume(
        maskNoiseVol['left']!,
        maskNoiseVol['right']!,
      );
    }
  }

  void _stopAllAudio() {
    _audioService.stopTone();
    _audioService.stopMaskingSound();
    _audioService.stopMaskingNoise();
  }

  void _adjustFrequency(int delta) {
    double newValue = _frequency + delta;
    if (newValue < 0.0) newValue = 0.0;
    if (newValue > 15000.0) newValue = 15000.0;

    setState(() {
      _frequency = newValue;
    });

    _storageService.saveFrequency(newValue);

    if (_isPlaying) {
      _audioService.setToneFrequency(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音调耳鸣疗法'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const OptionsPage()),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            tooltip: '选项',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  const Text(
                    '我的耳鸣音调',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_frequency.toInt()} Hz',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24.0,
                  ),
                ),
                child: Slider(
                  value: _frequency,
                  min: 0.0,
                  max: 15000.0,
                  onChanged: (value) {
                    double snappedValue = (value / 100).round() * 100.0;
                    if (snappedValue < 0.0) snappedValue = 0.0;
                    if (snappedValue > 15000.0) snappedValue = 15000.0;
                    setState(() {
                      _frequency = snappedValue;
                    });
                  },
                  onChangeEnd: (value) {
                    _storageService.saveFrequency(_frequency);
                    if (_isPlaying) {
                      _audioService.setToneFrequency(_frequency);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () => _adjustFrequency(-10),
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 48,
                      onPressed: _togglePlay,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 32),
                  FilledButton.tonal(
                    onPressed: () => _adjustFrequency(10),
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
