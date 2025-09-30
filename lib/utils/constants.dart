class ApiConstants {
  // OpenRouter API Configuration
  static const String openRouterBaseUrl = "https://openrouter.ai/api/v1";
  static const String openRouterApiKey =
      "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"; // Ganti dengan API key yang valid

  // ElevenLabs API Configuration
  static const String elevenLabsBaseUrl = "https://api.elevenlabs.io/v1";
  static const String elevenLabsApiKey =
      "sk_2015ce1db20fffa9520fca6d6ca3337c4f66b48f491a2215"; // Ganti dengan API key yang valid

  // Voice ID untuk ElevenLabs (ini adalah voice ID default, bisa diganti)
  static const String defaultVoiceId = "Xb7hH8MSUJpSbSDYk0k2";

  // Model configuration - using more reliable free models
  static const String openRouterModel = "meta-llama/llama-3.1-8b-instruct:free";
  static const String elevenLabsModel = "eleven_multilingual_v2";
}

class AppConstants {
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration textStreamingDelay = Duration(milliseconds: 400);

  // TTS Settings
  static const double defaultSpeechRate = 0.5;
  static const double defaultVolume = 1.0;
  static const double defaultPitch = 1.0;
  static const String defaultLanguage = "id-ID";
}

class BtConstants {
  /// Nama perangkat yang ingin dihubungkan (prefix cocok juga).
  static const deviceNameHint = 'NEUROKIT';

  /// UUID SPP standar untuk RFCOMM (dipakai di sisi Android).
  static const sppUuid = '00001101-0000-1000-8000-00805F9B34FB';

  static const MAC_ADDRESS = '24:6F:28:AD:9D:56';
}

class SessionDefaults {
  static const int durationSec = 20 * 60; // 20 menit
  static const int volumePct = 50;

  // Track di DFPlayer (001.mp3 -> 1, dst)
  static const int trackChill = 1;
  static const int trackLearn = 2;

  /// Motivasi/TTS tidak dikirim ke device → -1
  static const int motivationTrack = -1;
}
