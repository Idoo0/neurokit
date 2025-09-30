// study_session_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../services/local_storage_service.dart';
import '../controllers/bluetooth_controller.dart';
import '../controllers/session_controller.dart';
import '../utils/constants.dart';
import '../utils.dart';

class StudySessionPage extends StatefulWidget {
  const StudySessionPage({super.key});

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

  final session = Get.find<SessionController>();
  final bt = Get.find<BluetoothController>();

  // ---- lifecycle ----
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ---- logic ----
  void _startSession() async {
    if (!bt.isConnected.value) {
      try {
        await bt.scanAndConnect();
      } catch (_) {
        return;
      }
    }
    try {
      await session.start();
    } catch (_) {}

    final store = Get.find<LocalStorageService>();
    final s = await store.getStudySummary();
    if (s['startedAt'] == null) await store.markStudyStartedNow();

    setState(() {
      step = 1;
      _remaining = _totalDuration;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        final next = _remaining - const Duration(seconds: 1);
        _remaining = next.isNegative ? Duration.zero : next;
        if (_remaining == Duration.zero) {
          timer.cancel();
          _endSession(userStopped: false); // time's up
        }
      });
    });
  }

  void _pauseSession() async {
    try {
      await session.pause();
    } catch (_) {}
    _ticker?.cancel();
    setState(() => step = 2);
  }

  void _resumeSession() async {
    try {
      await session.resume();
    } catch (_) {}
    setState(() => step = 1);
    _startTicker();
  }

  void _endSession({required bool userStopped}) async {
    try {
      await session.stop();
    } catch (_) {}
    _ticker?.cancel();

    final store = Get.find<LocalStorageService>();
    final seconds = _totalDuration.inSeconds - _remaining.inSeconds;
    await store.finalizeStudy(durationSeconds: seconds);

    Get.offNamed(RoutesName.motivation, arguments: {'isStarting': false});
  }

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(24.0), child: content),
      ),
    );
  }

  // ---- UI Widgets ----

  /// ⭐️ Displays a confirmation dialog before stopping the session.
  Future<bool?> _showStopConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hentikan Sesi?'),
          content: const Text(
            'Apakah kamu yakin ingin mengakhiri sesi ini lebih awal?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Returns false
              child: Text('Tidak', style: TextStyle(color: neutral700)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Returns true
              child: Text(
                'Ya, Hentikan',
                style: TextStyle(color: brand600, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: brand600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(text, style: buttonText),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: brand600,
                side: const BorderSide(color: brand600, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(text, style: buttonText.copyWith(color: brand600)),
            ),
    );
  }

  Widget _preSession() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Oke, fokus.\nWaktunya mulai.",
                style: mobileH2.copyWith(color: neutral800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                AppFormatters.formatDuration(_totalDuration),
                style: desktopH2.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _buildButton(text: "Mulai", onPressed: _startSession),
        const SizedBox(height: 12),
        _buildButton(
          text: "Kembali",
          onPressed: () => Get.back(),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _activeSession() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppFormatters.formatDuration(_remaining),
                style: desktopH1.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('assets/images/star-wink.png', height: 400),
            ],
          ),
        ),
        _buildButton(text: "Jeda Sesi", onPressed: _pauseSession),
        const SizedBox(height: 12),
        _buildButton(
          text: "Hentikan Sesi",
          onPressed: () async {
            // ⭐️ Show confirmation dialog
            final shouldStop = await _showStopConfirmationDialog();
            if (shouldStop == true && mounted) {
              _endSession(userStopped: true);
            }
          },
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _pausedSession() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Wih.. Jeda dulu\nTapi fokusnya jangan kabur",
                style: mobileH2.copyWith(color: neutral800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Sisa waktu: ${AppFormatters.formatDuration(_remaining)}",
                style: bodyText16.copyWith(color: neutral600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        _buildButton(text: "Lanjutkan Sesi", onPressed: _resumeSession),
        const SizedBox(height: 12),
        _buildButton(
          text: "Hentikan Sesi",
          onPressed: () async {
            // ⭐️ Show confirmation dialog
            final shouldStop = await _showStopConfirmationDialog();
            if (shouldStop == true && mounted) {
              _endSession(userStopped: true);
            }
          },
          isPrimary: false,
        ),
      ],
    );
  }
}
