// lib/controllers/session_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import '../utils/constants.dart'; // BtConstants, SessionDefaults
import '../models/mode.dart';
import '../models/session_state.dart';
import '../services/bt_classic_service.dart';
import 'bluetooth_controller.dart';

class SessionController extends GetxController {
  final BluetoothController bt;
  SessionController({required this.bt});

  final phase = SessionPhase.idle.obs;
  final remainingText = '20:00'.obs;
  SessionInfo? info;

  StreamSubscription<String>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = Get.find<BtClassicService>().lines$.listen(_onLine);
  }

  void _onLine(String line) {
    // Contoh line:
    // ACK START ok
    // EVT STATUS running=1 paused=0 mode=CHILL volume=50 remainingMs=734000
    // EVT COMPLETED
    if (line.startsWith('EVT STATUS')) {
      final map = _parseKv(line.substring('EVT STATUS'.length).trim());
      final rem = int.tryParse(map['remainingMs'] ?? '0') ?? 0;
      final mm = (rem ~/ 60000).toString().padLeft(2, '0');
      final ss = ((rem % 60000) ~/ 1000).toString().padLeft(2, '0');
      remainingText.value = '$mm:$ss';

      final running = (map['running'] == '1');
      final paused = (map['paused'] == '1');
      if (running && !paused) phase.value = SessionPhase.running;
      if (running && paused) phase.value = SessionPhase.paused;
    } else if (line.startsWith('EVT COMPLETED')) {
      phase.value = SessionPhase.completed;
    }
  }

  Map<String, String> _parseKv(String s) {
    // parse "a=1 b=2 mode=CHILL" -> {a:1, b:2, mode:CHILL}
    final Map<String, String> out = {};
    for (final tok in s.split(' ')) {
      final i = tok.indexOf('=');
      if (i > 0) {
        final k = tok.substring(0, i);
        final v = tok.substring(i + 1);
        out[k] = v;
      }
    }
    return out;
  }

  Future<void> prepare(SessionMode mode) async {
    final m = mode == SessionMode.learn ? 'LEARN' : 'CHILL';
    final d = SessionDefaults.durationSec;
    final v = SessionDefaults.volumePct;
    final tc = SessionDefaults.trackChill;
    final tl = SessionDefaults.trackLearn;
    final tm = SessionDefaults.motivationTrack; // -1 (disable)

    info = SessionInfo(
      mode: mode,
      target: Duration(seconds: d),
      trackId: (mode == SessionMode.chill) ? tc : tl,
    );

    // no-op to satisfy types if needed (ignore if not)
    await bt.sendLine('PREPARE $m $d $v $tc $tl $tm');
    phase.value = SessionPhase.prepared;
  }

  // TTS motivasi: diputar lokal di HP (tidak kirim ke device)

  Future<void> start() async {
    await bt.sendLine('START');
    phase.value = SessionPhase.running;
  }

  Future<void> pause() async {
    await bt.sendLine('PAUSE');
    phase.value = SessionPhase.paused;
  }

  Future<void> resume() async {
    await bt.sendLine('RESUME');
    phase.value = SessionPhase.running;
  }

  Future<void> stop() async {
    await bt.sendLine('STOP');
    phase.value = SessionPhase.completed;
  }

  Future<void> volume(int pct) async {
    final clamped = pct.clamp(0, 100);
    await bt.sendLine('VOLUME $clamped');
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
