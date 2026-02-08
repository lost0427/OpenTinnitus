import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyFrequency = 'frequency';

  static const String _keyToneVolumeLeft = 'tone_volume_left';
  static const String _keyToneVolumeRight = 'tone_volume_right';

  static const String _keyMaskingSoundAsset = 'masking_sound_asset';
  static const String _keyMaskingSoundVolumeLeft = 'masking_sound_volume_left';
  static const String _keyMaskingSoundVolumeRight =
      'masking_sound_volume_right';

  static const String _keyMaskingNoiseAsset = 'masking_noise_asset';
  static const String _keyMaskingNoiseVolumeLeft = 'masking_noise_volume_left';
  static const String _keyMaskingNoiseVolumeRight =
      'masking_noise_volume_right';

  Future<void> saveFrequency(double frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFrequency, frequency);
  }

  Future<double?> loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFrequency);
  }

  // --- Tone Volume ---
  Future<void> saveToneVolume(double left, double right) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyToneVolumeLeft, left);
    await prefs.setDouble(_keyToneVolumeRight, right);
  }

  Future<Map<String, double>> loadToneVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'left': prefs.getDouble(_keyToneVolumeLeft) ?? 0.5,
      'right': prefs.getDouble(_keyToneVolumeRight) ?? 0.5,
    };
  }

  // --- Masking Sound ---
  Future<void> saveMaskingSound(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMaskingSoundAsset, assetPath);
  }

  Future<String?> loadMaskingSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMaskingSoundAsset);
  }

  Future<void> saveMaskingSoundVolume(double left, double right) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMaskingSoundVolumeLeft, left);
    await prefs.setDouble(_keyMaskingSoundVolumeRight, right);
  }

  Future<Map<String, double>> loadMaskingSoundVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'left': prefs.getDouble(_keyMaskingSoundVolumeLeft) ?? 0.5,
      'right': prefs.getDouble(_keyMaskingSoundVolumeRight) ?? 0.5,
    };
  }

  // --- Masking Noise ---
  Future<void> saveMaskingNoise(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMaskingNoiseAsset, assetPath);
  }

  Future<String?> loadMaskingNoise() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMaskingNoiseAsset);
  }

  Future<void> saveMaskingNoiseVolume(double left, double right) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMaskingNoiseVolumeLeft, left);
    await prefs.setDouble(_keyMaskingNoiseVolumeRight, right);
  }

  Future<Map<String, double>> loadMaskingNoiseVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'left': prefs.getDouble(_keyMaskingNoiseVolumeLeft) ?? 0.5,
      'right': prefs.getDouble(_keyMaskingNoiseVolumeRight) ?? 0.5,
    };
  }
}
