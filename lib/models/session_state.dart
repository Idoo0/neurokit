import 'mode.dart';

enum SessionPhase {
  idle, // belum apa-apa
  prepared, // sudah pilih mode & siap mulai
  running, // sesi berjalan
  paused, // kalau mau dukung pause
  completed, // selesai normal
  error, // ada error
}

class SessionInfo {
  final SessionMode mode;
  final String trackId; // id/filename/uri lagu
  final Duration? target; // optional: durasi target fokus

  const SessionInfo({required this.mode, required this.trackId, this.target});

  Map<String, dynamic> toJson() => {
    'mode': mode.label,
    'trackId': trackId,
    'targetSec': target?.inSeconds,
  };
}
