# OpenTinnitus

中文 | English

OpenTinnitus 是一个基于 Flutter 的耳鸣声音辅助应用，提供可调频治疗音、遮蔽声和遮蔽噪声，并支持左右声道独立音量。  
OpenTinnitus is a Flutter-based tinnitus audio helper app with an adjustable therapy tone, masking sounds, masking noise, and independent left/right channel volume control.

## 项目目标 | Project Goal

- 为耳鸣用户提供可重复、可调节的声音辅助方案。  
  Provide a repeatable and adjustable audio support workflow for tinnitus users.
- 支持本地离线使用，保存用户参数，下次启动可继续使用。  
  Support offline usage with persisted settings that are restored on next launch.

## 功能特性 | Features

- 治疗音调节（`0 ~ 15000 Hz`，滑块按 `100 Hz` 步进，按钮按 `10 Hz` 微调）  
  Therapy tone control (`0 ~ 15000 Hz`, slider snaps to `100 Hz`, buttons adjust by `10 Hz`)
- 播放/暂停一键控制，统一启动或停止所有音源  
  One-tap play/pause to start or stop all audio sources together
- 遮蔽声（自然声音）选择：雨、鸟类、河和鸟、蟋蟀  
  Masking sounds: rain, birds, river and birds, crickets
- 遮蔽噪声选择：白噪声、粉噪声、棕噪声、平滑棕噪声、紫噪声  
  Masking noise: white, pink, brown, smoothed brown, violet
- 治疗音 / 遮蔽声 / 遮蔽噪声均支持左右声道独立音量  
  Independent left/right channel volume for tone, masking sounds, and masking noise
- 频率、选择项、音量持久化（`shared_preferences`）  
  Persisted frequency, selections, and volume settings via `shared_preferences`
- 使用 `audio_service` 支持后台音频会话（尤其 Android 前台通知）  
  `audio_service` integration for background audio session (especially Android foreground notification)

## 技术栈 | Tech Stack

- Flutter / Dart (SDK constraint: `^3.10.8`)
- `flutter_soloud`：音源生成与播放  
  `flutter_soloud`: audio generation and playback
- `audio_service`：媒体会话与后台播放控制  
  `audio_service`: media session and background playback control
- `shared_preferences`：本地参数持久化  
  `shared_preferences`: local settings persistence

## 下载 APK | Download APK

- 在本仓库页面右侧点击 `Releases`，下载已打包 APK。  
  On this repository page, open `Releases` on the right side and download prebuilt APKs.
- 一般安卓手机请选择 `app-arm64-v8a-release.apk`。  
  For most Android phones, use `app-arm64-v8a-release.apk`.
- 如需兼容旧设备可选 `armeabi-v7a`；模拟器或特定设备可用 `x86_64`。  
  Use `armeabi-v7a` for older devices; use `x86_64` for emulators/specific devices.


## 使用说明 | How To Use

1. 在主页面设置耳鸣音调频率。  
   Set your tinnitus tone frequency on the home page.
2. 点击播放按钮启动治疗音。  
   Tap Play to start the therapy tone.
3. 进入“选项”页面选择遮蔽声/遮蔽噪声，并调节左右音量。  
   Open the Options page to select masking sound/noise and adjust left/right volume.
4. 返回主页面，播放时会自动加载已保存配置。  
   Return to home; saved settings are automatically applied on playback.

## 项目结构 | Project Structure

```text
lib/
  main.dart                    # 主页面与播放控制 / Home page and playback control
  options_page.dart            # 选项页面（遮蔽与音量） / Options (masking and volume)
  tinnitus_audio_service.dart  # AudioService 封装 / AudioService wrapper
  soloud_player.dart           # SoLoud 播放器实现 / SoLoud player implementation
  storage_service.dart         # 本地存储服务 / Local storage service
assets/audio/
  masking_sounds/              # 自然遮蔽声音频 / nature masking assets
  masking_noise/               # 噪声音频 / noise masking assets
```

## 重要说明 | Important Notes

- 本项目为声音辅助工具，不构成医疗建议。  
  This project is an audio support tool and does not provide medical advice.
- 若耳鸣症状持续或加重，请咨询专业医生。  
  If tinnitus persists or worsens, consult a qualified medical professional.

## License

MIT License. See [LICENSE](./LICENSE).
