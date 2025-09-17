import 'dart:async';
import 'package:get/get.dart';
import '../models/mode.dart';
import '../models/session_state.dart';
import 'bluetooth_controller.dart';
import 'music_controller.dart';

class SessionController extends GetxController {
  final BluetoothController bt;
  final MusicController music;

  SessionController({required this.bt, required this.music});

  // state session
  final phase = SessionPhase.idle.obs;
  SessionInfo? info;

  /// dipanggil saat user memilih mode di popup
  Future<void> selectMode(SessionMode mode) async {
    // siapkan track di audio (tanpa play)
    await music.prepare(mode);
    info = SessionInfo(mode: mode, trackId: music.currentTrackId ?? '');
    phase.value = SessionPhase.prepared;
  }

  /// dipanggil saat tombol "Mulai Sesi" di StudySessionPage ditekan
  Future<void> startSession() async {
    if (phase.value != SessionPhase.prepared || info == null) return;

    // 1) pastikan tersambung BLE dulu
    if (!bt.isConnected.value) {
      // optional: auto connect
      await bt.scanAndConnect();
      if (!bt.isConnected.value) {
        phase.value = SessionPhase.error;
        return;
      }
    }

    // 2) kirim komando 'prepare' dulu ke ESP32 (agar lampu siap/mode set)
    // await bt.sendCommand({
    //   'cmd': 'prepare',
    //   ...info!.toJson(),
    // });
    // TODO: kalau perlu tunggu ACK dari notifications

    // 3) play audio (OS akan route audio ke NeuroKit jika A2DP tersambung)
    await music.play();
    phase.value = SessionPhase.running;

    // 4) opsional: kirim 'start' setelah musik benar-benar jalan
    //await bt.sendCommand({'cmd': 'start'});
  }

  Future<void> stopSession({bool completed = false}) async {
    // kirim komando stop dan matikan audio
    //await bt.sendCommand({'cmd': 'stop'});
    await music.stop();
    phase.value = completed ? SessionPhase.completed : SessionPhase.idle;
    info = null;
  }
}

/*
// ====== OPTIONAL: tunggu ACK dari ESP32 sebelum play ======
// Future<bool> _waitAck(String expect, {Duration timeout = const Duration(seconds: 3)}) async {
//   final c = Completer<bool>();
//   final sub = bt._ble.notifications.listen((m) {
//     if (m['ack'] == expect) c.complete(true);
//   });
//   Future.delayed(timeout, () { if (!c.isCompleted) c.complete(false); });
//   final ok = await c.future;
//   await sub.cancel();
//   return ok;
// }
//
// di startSession():
//   await bt.sendCommand({'cmd': 'prepare', ...info!.toJson()});
//   final ok = await _waitAck('prepare');
//   if (!ok) { phase.value = SessionPhase.error; return; }
//   await music.play();
//   await bt.sendCommand({'cmd': 'start'});
// ============================================================
*/
