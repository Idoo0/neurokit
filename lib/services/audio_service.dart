// NOTE: Skeleton audio. Implementasi real pakai just_audio/audio_service.
// Tujuan: siapkan player, pilih track sesuai mode, play/pause/stop.

import 'dart:async';

class AudioService {
  // TODO: final AudioPlayer _player = AudioPlayer();

  // Sinyal "sedang memutar?" buat UI
  final StreamController<bool> _playingCtrl =
      StreamController<bool>.broadcast();
  Stream<bool> get playing$ => _playingCtrl.stream;

  Future<void> init() async {
    // TODO: inisialisasi player (optional)
  }

  Future<void> setTrack(String uriOrAsset) async {
    // TODO:
    // - jika file lokal/asset: setAsset
    // - jika dari url: setUrl
  }

  Future<void> play() async {
    // await _player.play();
    _playingCtrl.add(true);
  }

  Future<void> pause() async {
    // await _player.pause();
    _playingCtrl.add(false);
  }

  Future<void> stop() async {
    // await _player.stop();
    _playingCtrl.add(false);
  }

  Future<void> dispose() async {
    await _playingCtrl.close();
    // await _player.dispose();
  }
}

/*
// ========== REAL AUDIO IMPLEMENTATION (just_audio) ==========
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioService {
  final _player = AudioPlayer();
  final _playingCtrl = StreamController<bool>.broadcast();
  Stream<bool> get playing$ => _playingCtrl.stream;

  Future<void> init() async {
    // Integrasi dengan audio_session kalau perlu
    _player.playingStream.listen((p) => _playingCtrl.add(p));
  }

  Future<void> setTrack(String src) async {
    if (src.startsWith('asset://')) {
      final path = src.replaceFirst('asset://', '');
      await _player.setAsset(path);
    } else {
      await _player.setUrl(src);
    }
  }

  Future<void> play()  => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop()  => _player.stop();

  Future<void> dispose() async {
    await _player.dispose();
    await _playingCtrl.close();
  }
}
// ==============================================================
*/
