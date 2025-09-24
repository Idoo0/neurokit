// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Single place to persist lightweight user & session data.
/// Uses SharedPreferences under the hood.
class LocalStorageService {
  // ===== Onboarding keys =====
  static const String _nameKey = 'userName';
  static const String _classKey = 'userClass';
  static const String _universityKey = 'userUniversity';
  static const String _majorKey = 'userMajor';

  // ===== Session keys =====
  static const String _selectedModeKey = 'session_selected_mode';       // String (SessionMode.name)
  static const String _warmupScoreKey = 'session_warmup_score';         // int
  static const String _warmupQuestionsKey = 'session_warmup_questions'; // int
  static const String _warmupDoneKey = 'session_warmup_done';           // bool

  static const String _studyStartedAtKey = 'session_study_started_at';  // int (ms since epoch)
  static const String _studyDurationSecKey = 'session_study_duration';  // int (seconds)
  static const String _studyDoneKey = 'session_study_done';             // bool

  // ===========================
  // Onboarding
  // ===========================
  Future<void> saveUserData({
    required String name,
    required String userClass,
    required String university,
    required String major,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_classKey, userClass);
    await prefs.setString(_universityKey, university);
    await prefs.setString(_majorKey, major);
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? '',
      'class': prefs.getString(_classKey) ?? '',
      'university': prefs.getString(_universityKey) ?? '',
      'major': prefs.getString(_majorKey) ?? '',
    };
  }

  // Individual setters for user data
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<void> setUserClass(String userClass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_classKey, userClass);
  }

  Future<void> setUserUniversity(String university) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_universityKey, university);
  }

  Future<void> setUserMajor(String major) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_majorKey, major);
  }

  // ===========================
  // Session: Mode
  // ===========================
  /// Save the selected mode as a string (use `SessionMode.name` when calling).
  Future<void> setSelectedModeString(String modeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModeKey, modeName);
  }

  /// Read the selected mode as a string. Convert to enum at the call site if needed.
  Future<String?> getSelectedModeString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedModeKey);
  }

  // ===========================
  // Session: Warmup
  // ===========================
  Future<void> setWarmupResult({
    required int score,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_warmupScoreKey, score);
    await prefs.setInt(_warmupQuestionsKey, totalQuestions);
    await prefs.setBool(_warmupDoneKey, true);
  }

  /// Returns: {'score': int, 'total': int, 'done': bool}
  Future<Map<String, Object>> getWarmupSummary() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'score': prefs.getInt(_warmupScoreKey) ?? 0,
      'total': prefs.getInt(_warmupQuestionsKey) ?? 0,
      'done': prefs.getBool(_warmupDoneKey) ?? false,
    };
  }

  // ===========================
  // Session: Study
  // ===========================
  /// Mark study as started right now (stores the start timestamp).
  Future<void> markStudyStartedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyStartedAtKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_studyDoneKey, false);
  }

  /// When study completes, persist the duration in seconds and set done=true.
  Future<void> markStudyCompleted({required int durationSeconds}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyDurationSecKey, durationSeconds);
    await prefs.setBool(_studyDoneKey, true);
  }

  /// Returns: {'startedAt': DateTime? , 'durationSec': int, 'done': bool}
  Future<Map<String, Object?>> getStudySummary() async {
    final prefs = await SharedPreferences.getInstance();
    final startedMs = prefs.getInt(_studyStartedAtKey);
    return {
      'startedAt': startedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startedMs),
      'durationSec': prefs.getInt(_studyDurationSecKey) ?? 0,
      'done': prefs.getBool(_studyDoneKey) ?? false,
    };
  }

  // ===========================
  // Session: Reset (optional)
  // ===========================
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedModeKey);
    await prefs.remove(_warmupScoreKey);
    await prefs.remove(_warmupQuestionsKey);
    await prefs.remove(_warmupDoneKey);
    await prefs.remove(_studyStartedAtKey);
    await prefs.remove(_studyDurationSecKey);
    await prefs.remove(_studyDoneKey);
  }

  /// Clear ALL data including user profile and session data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}