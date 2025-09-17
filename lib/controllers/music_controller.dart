import 'package:get/get.dart';
import '../models/mode.dart';
import '../services/audio_service.dart';

class MusicController extends GetxController {
  final AudioService _audio;

  MusicController(this._audio);

  // track per mode (sementara hardcoded; bisa dipindah ke repository)
  final Map<SessionMode, String> _trackMap = {
    SessionMode.chill: 'asset://assets/audios/chill.mp3', // contoh
    SessionMode.learn: 'asset://assets/audios/learn.mp3',
  };

  final isPrepared = false.obs;
  final isPlaying = false.obs;
  String? currentTrackId;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _audio.init();
    _audio.playing$.listen((p) => isPlaying.value = p);
  }

  Future<void> prepare(SessionMode mode) async {
    final trackId = _trackMap[mode]!;
    currentTrackId = trackId;
    await _audio.setTrack(trackId);
    isPrepared.value = true;
  }

  Future<void> play() => _audio.play();
  Future<void> pause() => _audio.pause();
  Future<void> stop() async {
    await _audio.stop();
    isPrepared.value = false;
    currentTrackId = null;
  }

  @override
  void onClose() {
    _audio.dispose();
    super.onClose();
  }
}

/*
// ====== ENABLE WHEN READY (just_audio) ======
// onInit():
//   await _audio.init();
//
// prepare(mode):
//   await _audio.setTrack(trackId);
//
// play/pause/stop:
//   return _audio.play(); / _audio.pause(); / _audio.stop();
// =============================================
*/
