import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';

class StudySessionPage extends StatefulWidget {
  const StudySessionPage({Key? key}) : super(key: key);

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  // step: 0 = pre-session, 1 = running, 2 = paused
  int step = 0;

  // total duration & remaining time
  final Duration _totalDuration = const Duration(minutes: 20);
  Duration _remaining = const Duration(minutes: 20);

  Timer? _ticker;

  // ---- lifecycle ----
  @override
  void initState() {
    super.initState();
    // If you ever want to auto-start, call _startSession() here.
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ---- helpers ----
  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
    // For 20 mins, it'll show mm:ss (e.g., 19:59)
  }

  void _startSession() {
    setState(() {
      step = 1;
      _remaining = _totalDuration; // reset to full 20 mins when starting
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        final next = _remaining - const Duration(seconds: 1);
        _remaining = next.isNegative ? Duration.zero : next;
        if (_remaining == Duration.zero) {
          t.cancel();
          _endSession(userStopped: false); // time up → end session
        }
      });
    });
  }

  void _pauseSession() {
    _ticker?.cancel();
    setState(() => step = 2);
  }

  void _resumeSession() {
    setState(() => step = 1);
    _startTicker();
  }

  void _endSession({required bool userStopped}) {
    // no LED controller yet — safe to leave TODO
    // TODO: when IoT ready, turn OFF LED here (try/catch)

    // Navigate to Motivation (after study). Motivation has safe fallbacks.
    Get.offNamed(
      RoutesName.motivation,
      arguments: {
        'isStarting': false, // after study
        'messages': const [
          'Great work today!',
          'Take a deep breath.',
          'You’re building a powerful habit.',
        ],
      },
    );
  }

  // ---- styles ----
  ButtonStyle _blueButton() => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[900],
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  ButtonStyle _whiteOutlineButton() => OutlinedButton.styleFrom(
    side: const BorderSide(color: Colors.black12, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (step) {
      case 0:
        content = _preSession();
        break;
      case 1:
        content = _activeSession();
        break;
      case 2:
        content = _pausedSession();
        break;
      default:
        content = _preSession();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Pre Session
  // -------------------------------
  Widget _preSession() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sesi Belajar",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Durasi: ${_formatDuration(_totalDuration)}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        const Icon(Icons.self_improvement, size: 120, color: Colors.grey),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startSession,
          style: _blueButton(),
          child: const Text("Mulai"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: _whiteOutlineButton(),
          child: const Text("Kembali"),
        ),
      ],
    );
  }

  // -------------------------------
  // Active Session
  // -------------------------------
  Widget _activeSession() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatDuration(_remaining),
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        const Icon(Icons.nightlight_round, size: 120, color: Colors.grey),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _pauseSession,
          style: _blueButton(),
          child: const Text("Jeda Sesi"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _endSession(userStopped: true),
          style: _whiteOutlineButton(),
          child: const Text("Hentikan Sesi"),
        ),
      ],
    );
  }

  // -------------------------------
  // Paused Session
  // -------------------------------
  Widget _pausedSession() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Wih.. Jeda dulu\nTapi fokusnya jangan kabur",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          "Sisa waktu: ${_formatDuration(_remaining)}",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _resumeSession,
          style: _blueButton(),
          child: const Text("Lanjutkan Sesi"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _endSession(userStopped: true),
          style: _whiteOutlineButton(),
          child: const Text("Hentikan Sesi"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: _whiteOutlineButton(),
          child: const Text("Kembali"),
        ),
      ],
    );
  }
}