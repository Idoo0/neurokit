// enum mode belajar
enum SessionMode { chill, learn }

extension SessionModeX on SessionMode {
  String get label => this == SessionMode.chill ? 'CHILL' : 'LEARN';
}
