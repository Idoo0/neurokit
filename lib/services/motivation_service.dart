import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class MotivationService extends GetxController {
  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  
  // State untuk loading dan streaming text
  final isGenerating = false.obs;
  final isPlayingAudio = false.obs;
  final currentText = ''.obs;
  final streamingWords = <String>[].obs;
  
  // State untuk audio file
  File? _audioFile;
  final _audioGenerated = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initTts();
  }
  
  @override
  void onClose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.onClose();
  }
  
  Future<void> _initTts() async {
    await _flutterTts.setLanguage(AppConstants.defaultLanguage);
    await _flutterTts.setSpeechRate(AppConstants.defaultSpeechRate);
    await _flutterTts.setVolume(AppConstants.defaultVolume);
    await _flutterTts.setPitch(AppConstants.defaultPitch);
  }
  
  /// Generate motivasi text dan audio (tanpa langsung play)
  Future<void> generateMotivation(String sesi) async {
    try {
      isGenerating.value = true;
      currentText.value = '';
      streamingWords.clear();
      
      // Validasi API keys terlebih dahulu
      if (!_isValidApiKeys()) {
        print("API keys tidak valid, menggunakan fallback text");
        await _generateFallbackMotivation(sesi);
        return;
      }
      
      // Ambil data user dari local storage
      final storage = Get.find<LocalStorageService>();
      final userData = await storage.getUserData();
      final nama = userData['name']?.isNotEmpty == true ? userData['name']! : "Pelajar";
      final univImpian = userData['university']?.isNotEmpty == true ? userData['university']! : "Universitas Impian";
      
      // Generate text motivasi
      final motivasiText = await _generateMotivationText(nama, univImpian, sesi);
      
      if (motivasiText.isEmpty) {
        throw Exception("Gagal generate motivasi");
      }
      
      currentText.value = motivasiText;
      
      // Generate audio menggunakan ElevenLabs (tapi tidak langsung play)
      try {
        _audioFile = await _generateAudio(motivasiText);
        _audioGenerated.value = true;
      } catch (e) {
        print("Audio generation failed, will use TTS fallback: $e");
        _audioFile = null;
        _audioGenerated.value = true; // Still mark as ready for TTS fallback
      }
      
    } catch (e) {
      print("Error generating motivation: $e");
      // Fallback ke default text
      await _generateFallbackMotivation(sesi);
    } finally {
      isGenerating.value = false;
    }
  }

  /// Play motivasi dengan streaming text
  Future<void> playMotivationWithStreaming() async {
    if (currentText.value.isEmpty) return;
    
    try {
      isPlayingAudio.value = true;
      streamingWords.clear();
      
      // Play audio dan streaming text secara bersamaan
      await Future.wait([
        _playAudioOrTts(),
        _streamText(currentText.value),
      ]);
      
    } catch (e) {
      print("Error playing motivation: $e");
    } finally {
      isPlayingAudio.value = false;
    }
  }

  /// Play audio file atau fallback ke TTS
  Future<void> _playAudioOrTts() async {
    if (_audioFile != null && await _audioFile!.exists()) {
      // Play generated audio file
      try {
        await _audioPlayer.play(DeviceFileSource(_audioFile!.path));
        
        // Listen untuk audio completion
        _audioPlayer.onPlayerComplete.listen((_) {
          isPlayingAudio.value = false;
        });
        
      } catch (e) {
        print("Error playing audio file, fallback to TTS: $e");
        await _flutterTts.speak(currentText.value);
      }
    } else {
      // Fallback ke TTS built-in
      await _flutterTts.speak(currentText.value);
    }
  }

  /// Generate fallback motivation
  Future<void> _generateFallbackMotivation(String sesi) async {
    final storage = Get.find<LocalStorageService>();
    final userData = await storage.getUserData();
    final nama = userData['name']?.isNotEmpty == true ? userData['name']! : "Pelajar";
    final univImpian = userData['university']?.isNotEmpty == true ? userData['university']! : "Universitas Impian";
    
    currentText.value = sesi == "start" 
        ? "Semangat $nama! Kamu pasti bisa mencapai $univImpian. Mari fokus belajar!"
        : "Hebat $nama! Satu langkah lebih dekat menuju $univImpian. Keep going!";
    
    _audioFile = null;
    _audioGenerated.value = true;
  }

  /// Validasi API keys
  bool _isValidApiKeys() {
    return ApiConstants.openRouterApiKey != "YOUR_OPENROUTER_API_KEY" &&
           ApiConstants.elevenLabsApiKey != "YOUR_ELEVENLABS_API_KEY" &&
           ApiConstants.openRouterApiKey.isNotEmpty &&
           ApiConstants.elevenLabsApiKey.isNotEmpty;
  }

  /// Test API keys connectivity (untuk debugging)
  Future<Map<String, bool>> testApiConnectivity() async {
    final results = <String, bool>{};
    
    // Test OpenRouter
    try {
      final response = await _dio.post(
        '${ApiConstants.openRouterBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://github.com/Idoo0/neurokit',
            'X-Title': 'NeuroKit App',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'model': ApiConstants.openRouterModel,
          'messages': [{'role': 'user', 'content': 'Hello'}],
          'max_tokens': 10,
        },
      );
      results['openrouter'] = response.statusCode == 200;
    } catch (e) {
      print("OpenRouter test failed: $e");
      results['openrouter'] = false;
    }
    
    // Test ElevenLabs
    try {
      final response = await _dio.post(
        '${ApiConstants.elevenLabsBaseUrl}/text-to-speech/${ApiConstants.defaultVoiceId}',
        options: Options(
          headers: {
            'xi-api-key': ApiConstants.elevenLabsApiKey,
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'text': 'Test',
          'model_id': ApiConstants.elevenLabsModel,
        },
      );
      results['elevenlabs'] = response.statusCode == 200;
    } catch (e) {
      print("ElevenLabs test failed: $e");
      results['elevenlabs'] = false;
    }
    
    return results;
  }
  
  /// Generate text motivasi menggunakan OpenRouter
  Future<String> _generateMotivationText(String nama, String univImpian, String sesi) async {
    final waktuBelajar = _getCurrentTimeString();
    
    String prompt;
    if (sesi == "start") {
      prompt = "Buatkan motivasi singkat dalam bahasa Indonesia untuk $nama, "
          "yang sedang bersiap belajar di waktu $waktuBelajar. "
          "Motivasi harus memberi semangat agar tetap fokus demi mencapai "
          "universitas impian yaitu $univImpian. Jangan panjang-panjang, singkat dan bersemangat. "
          "Buat hanya untuk sekitar 7-8 detik jika dibacakan";
    } else {
      prompt = "Buatkan ucapan apresiasi singkat dalam bahasa Indonesia untuk $nama, "
          "yang baru selesai belajar di waktu $waktuBelajar. "
          "Berikan semangat agar terus konsisten demi universitas impian $univImpian. "
          "Jangan panjang-panjang, cukup singkat tapi penuh apresiasi. "
          "Buat hanya untuk sekitar 7-8 detik jika dibacakan";
    }
    
    try {
      print("Calling OpenRouter API...");
      
      final response = await _dio.post(
        '${ApiConstants.openRouterBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://github.com/Idoo0/neurokit', // Required by OpenRouter
            'X-Title': 'NeuroKit App', // Required by OpenRouter
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {
          'model': ApiConstants.openRouterModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        },
      );
      
      print("OpenRouter API response status: ${response.statusCode}");
      
      final content = response.data['choices'][0]['message']['content'] as String;
      return content.trim();
      
    } catch (e) {
      print("Error calling OpenRouter: $e");
      
      // Detailed error logging
      if (e is DioException) {
        print("DioException details:");
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
        print("Request headers: ${e.requestOptions.headers}");
      }
      
      // Fallback text jika API gagal
      return sesi == "start" 
          ? "Semangat $nama! Kamu pasti bisa mencapai $univImpian. Mari fokus belajar!"
          : "Hebat $nama! Satu langkah lebih dekat menuju $univImpian. Keep going!";
    }
  }
  
  /// Generate audio menggunakan ElevenLabs
  Future<File> _generateAudio(String text) async {
    try {
      print("Calling ElevenLabs API...");
      
      final response = await _dio.post(
        '${ApiConstants.elevenLabsBaseUrl}/text-to-speech/${ApiConstants.defaultVoiceId}',
        options: Options(
          headers: {
            'xi-api-key': ApiConstants.elevenLabsApiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {
          'text': text,
          'model_id': ApiConstants.elevenLabsModel,
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        },
      );
      
      print("ElevenLabs API response status: ${response.statusCode}");
      print("Audio data size: ${response.data.length} bytes");
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/motivation_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(response.data);
      
      print("Audio file saved: ${file.path}");
      return file;
      
    } catch (e) {
      print("Error calling ElevenLabs: $e");
      
      // Detailed error logging
      if (e is DioException) {
        print("DioException details:");
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
        print("Request headers: ${e.requestOptions.headers}");
      }
      
      throw Exception("Gagal generate audio");
    }
  }
  
  /// Stop semua audio dan reset state
  Future<void> stopAll() async {
    isGenerating.value = false;
    isPlayingAudio.value = false;
    await _audioPlayer.stop();
    await _flutterTts.stop();
    streamingWords.clear();
    _audioFile = null;
    currentText.value = '';
  }
  
  /// Stream text word by word
  Future<void> _streamText(String text) async {
    final words = text.split(' ');
    streamingWords.clear();
    
    for (int i = 0; i < words.length; i++) {
      if (!isPlayingAudio.value) break; // Stop jika audio dihentikan
      
      streamingWords.add(words[i]);
      
      // Delay antar kata (sesuaikan dengan kecepatan audio)
      await Future.delayed(AppConstants.textStreamingDelay);
    }
  }  String _getCurrentTimeString() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 12) {
      return "pagi";
    } else if (hour >= 12 && hour < 15) {
      return "siang";
    } else if (hour >= 15 && hour < 18) {
      return "sore";
    } else {
      return "malam";
    }
  }
}