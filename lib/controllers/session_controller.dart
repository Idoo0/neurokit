// lib/controllers/session_controller.dart (inti saja)
import 'dart:async';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../models/mode.dart';
import '../models/session_state.dart';
import '../services/bt_classic_service.dart';
import 'bluetooth_controller.dart';

class SessionController extends GetxController {
  final BluetoothController bt;
  SessionController({required this.bt});

  final phase = SessionPhase.idle.obs;
  final remainingText = '20:00'.obs;
  StreamSubscription<String>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = Get.find<BtClassicService>().lines$.listen(_onLine);
  }

  void _onLine(String line) {
    if (line.startsWith('EVT STATUS')) {
      final m = _kv(line.substring(11).trim());
      final rem = int.tryParse(m['remainingMs'] ?? '0') ?? 0;
      remainingText.value =
          '${(rem ~/ 60000).toString().padLeft(2, '0')}:${((rem % 60000) ~/ 1000).toString().padLeft(2, '0')}';
      final run = m['running'] == '1', pause = m['paused'] == '1';
      if (run && !pause) phase.value = SessionPhase.running;
      if (run && pause) phase.value = SessionPhase.paused;
    } else if (line.startsWith('EVT COMPLETED')) {
      phase.value = SessionPhase.completed;
    }
  }

  Map<String, String> _kv(String s) {
    final out = <String, String>{};
    for (final tok in s.split(' ')) {
      final i = tok.indexOf('=');
      if (i > 0) out[tok.substring(0, i)] = tok.substring(i + 1);
    }
    return out;
  }

  Future<void> prepare(SessionMode mode) async {
    final m = mode == SessionMode.learn ? 'LEARN' : 'CHILL';
    final d = SessionDefaults.durationSec;
    final v = SessionDefaults.volumePct;
    final tc = SessionDefaults.trackChill;
    final tl = SessionDefaults.trackLearn;
    final tm = SessionDefaults.motivationTrack;
    await bt.sendLine('PREPARE $m $d $v $tc $tl $tm');
    phase.value = SessionPhase.prepared;
  }

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

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
