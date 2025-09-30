import 'mode.dart';

enum SessionPhase { idle, prepared, running, paused, completed }

class SessionInfo {
  final SessionMode mode;
  final Duration target;
  final int trackId; // untuk UI info (dfplayer:<no>)

  SessionInfo({
    required this.mode,
    required this.target,
    required this.trackId,
  });
}
