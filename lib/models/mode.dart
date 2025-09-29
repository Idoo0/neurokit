enum SessionMode { chill, learn }

extension SessionModeX on SessionMode {
  String get label => this == SessionMode.learn ? 'LEARN' : 'CHILL';
}
