import 'dart:async';
import 'package:flutter/material.dart';
import '../utils.dart'; // Impor utils untuk gaya

class StudySessionPage extends StatefulWidget {
  const StudySessionPage({super.key});

  @override
  State<StudySessionPage> createState() => StudySessionPageState();
}

enum TimerState { idle, running, paused, finished }

class StudySessionPageState extends State<StudySessionPage> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  TimerState _timerState = TimerState.idle;

  TimerState get timerState => _timerState;

  void startFocusSession() {
    if (_timerState == TimerState.idle || _timerState == TimerState.finished) {
      _duration = Duration.zero;
      setState(() {
        _timerState = TimerState.running;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resumeTimer() {
    setState(() {
      _timerState = TimerState.running;
    });
    _startTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerState = TimerState.finished;
    });
  }

  void _resetToHome() {
    _timer?.cancel();
    setState(() {
      _duration = Duration.zero;
      _timerState = TimerState.idle;
    });
    // Di aplikasi nyata, Anda mungkin ingin menavigasi ke tab lain
    // tapi karena kita sudah di dalam wrapper, cukup reset state
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Helper untuk format durasi HH:MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          // Menggunakan switch untuk menampilkan UI yang berbeda berdasarkan state
          child: _buildUIForState(),
        ),
      ),
    );
  }

  Widget _buildUIForState() {
    switch (_timerState) {
      case TimerState.running:
        return _buildRunningUI();
      case TimerState.paused:
        return _buildPausedUI();
      case TimerState.finished:
        return _buildFinishedUI();
      case TimerState.idle:
      default:
        return _buildIdleUI();
    }
  }

  // UI saat timer belum dimulai
  Widget _buildIdleUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Siap untuk Fokus?", style: desktopH2),
        const SizedBox(height: 16),
        Text(
          "Tekan tombol 'fokus' di tengah bawah untuk memulai sesi belajarmu.",
          style: bodyText16.copyWith(color: neutral500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // UI saat timer berjalan
  Widget _buildRunningUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 1), // Spacer
        Text(
          _formatDuration(_duration),
          style: desktopH1.copyWith(fontSize: 56),
        ),
        Image.asset(
          'assets/images/star-spark-glow.png',
          height: 200,
          color: neutral200,
        ),
        Column(
          children: [
            _buildActionButton(
              label: 'Jeda Sesi',
              onPressed: _pauseTimer,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              label: 'Hentikan Sesi',
              onPressed: _stopTimer,
              isPrimary: false,
            ),
          ],
        ),
      ],
    );
  }

  // UI saat timer dijeda
  Widget _buildPausedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 1), // Spacer
        Column(
          children: [
            Text("Wih.. Jeda dulu", style: desktopH2),
            const SizedBox(height: 8),
            Text(
              "Tapi fokusnya jangan kabur",
              style: bodyText16.copyWith(color: neutral500),
            ),
          ],
        ),
        // Ganti dengan path aset bintang Anda
        Image.asset(
          'assets/images/star_inactive.png',
          height: 200,
          color: neutral200,
        ),
        Column(
          children: [
            _buildActionButton(
              label: 'Lanjutkan Sesi',
              onPressed: _resumeTimer,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              label: 'Hentikan Sesi',
              onPressed: _stopTimer,
              isPrimary: false,
            ),
          ],
        ),
      ],
    );
  }

  // UI saat sesi selesai
  Widget _buildFinishedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 1), // Spacer
        Column(
          children: [
            Text("Sesi Fokus Selesai!", style: desktopH2),
            const SizedBox(height: 32),
            // Ganti dengan path aset bintang Anda yang sudah jadi
            Image.asset('assets/images/star-spark-glow.png', height: 200),
            const SizedBox(height: 32),
            Text("Kerja bagus!", style: bodyText16),
            Text(
              "kamu mendapatkan 10 poin",
              style: bodyText16.copyWith(color: neutral500),
            ),
          ],
        ),
        _buildActionButton(
          label: 'Home',
          onPressed: _resetToHome,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? brand800 : Colors.white,
          foregroundColor: isPrimary ? Colors.white : brand800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: brand800, width: 1.5),
          ),
          elevation: isPrimary ? 2 : 0,
        ),
        child: Text(
          label,
          style: buttonText.copyWith(
            color: isPrimary ? Colors.white : brand800,
          ),
        ),
      ),
    );
  }
}
