// lib/services/local_storage_service.dart
import 'dart:convert';
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

  // ===== Stats keys =====
  static const String _weeklyFocusSecKey   = 'stats_weekly_focus_sec';   // int
  static const String _weeklyWeekStartKey  = 'stats_week_start_ymd';     // int (YYYYMMDD of Monday)

  static const String _streakCountKey      = 'stats_streak_count';       // int
  static const String _streakLastYmdKey    = 'stats_streak_last_ymd';    // int (YYYYMMDD)

  static const String _sessionHistoryKey   = 'stats_session_history';    // List<String> JSON

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
  Future<void> setSelectedModeString(String modeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModeKey, modeName);
  }

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
  Future<void> markStudyStartedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyStartedAtKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setBool(_studyDoneKey, false);
  }

  Future<void> markStudyCompleted({required int durationSeconds}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_studyDurationSecKey, durationSeconds);
    await prefs.setBool(_studyDoneKey, true);
  }

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

  /// Convenience: finalize session: mark study, update totals, streak, and history.
  Future<void> finalizeStudy({
    required int durationSeconds,
    int warmupScore = 0,
    int warmupTotal = 0,
    String? modeName,
  }) async {
    await markStudyCompleted(durationSeconds: durationSeconds);
    await addFocusedSecondsThisWeek(durationSeconds);
    await updateStreakOnSessionComplete();
    await addSessionRecord(
      endedAt: DateTime.now(),
      durationSec: durationSeconds,
      warmupScore: warmupScore,
      warmupTotal: warmupTotal,
      modeName: modeName,
    );
  }

  // ===========================
  // Stats — Weekly total
  // ===========================
  Future<void> addFocusedSecondsThisWeek(int seconds, {DateTime? now}) async {
    if (seconds <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final DateTime today = (now ?? DateTime.now());
    final int thisWeekStartYmd = _weekStartYmd(today);

    final int storedWeekStart = prefs.getInt(_weeklyWeekStartKey) ?? 0;
    if (storedWeekStart != thisWeekStartYmd) {
      await prefs.setInt(_weeklyWeekStartKey, thisWeekStartYmd);
      await prefs.setInt(_weeklyFocusSecKey, 0);
    }

    final int current = prefs.getInt(_weeklyFocusSecKey) ?? 0;
    await prefs.setInt(_weeklyFocusSecKey, current + seconds);
  }

  Future<Map<String, int>> getWeeklyFocus() async {
    final prefs = await SharedPreferences.getInstance();
    await addFocusedSecondsThisWeek(0); // rollover if needed
    return {
      'weekStartYmd': prefs.getInt(_weeklyWeekStartKey) ?? _weekStartYmd(DateTime.now()),
      'weeklyFocusSec': prefs.getInt(_weeklyFocusSecKey) ?? 0,
    };
  }

  // ===========================
  // Stats — Streak
  // ===========================
  Future<void> updateStreakOnSessionComplete({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime today = (now ?? DateTime.now());
    final int todayYmd = _toYmd(today);

    final int lastYmd = prefs.getInt(_streakLastYmdKey) ?? 0;
    int count = prefs.getInt(_streakCountKey) ?? 0;

    if (lastYmd == 0) {
      count = 1;
    } else if (lastYmd == todayYmd) {
      count = count <= 0 ? 1 : count;
    } else if (lastYmd == _toYmd(today.subtract(const Duration(days: 1)))) {
      count = (count <= 0 ? 1 : count + 1);
    } else {
      count = 1;
    }

    await prefs.setInt(_streakCountKey, count);
    await prefs.setInt(_streakLastYmdKey, todayYmd);
  }

  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    await addFocusedSecondsThisWeek(0);
    return {
      'weeklyFocusSec': prefs.getInt(_weeklyFocusSecKey) ?? 0,
      'weekStartYmd': prefs.getInt(_weeklyWeekStartKey) ?? _weekStartYmd(DateTime.now()),
      'streakCount': prefs.getInt(_streakCountKey) ?? 0,
      'lastYmd': prefs.getInt(_streakLastYmdKey) ?? 0,
    };
  }

  // ===========================
  // Stats — History
  // ===========================
  Future<void> addSessionRecord({
    required DateTime endedAt,
    required int durationSec,
    required int warmupScore,
    required int warmupTotal,
    String? modeName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final item = {
      'endedAt': endedAt.toIso8601String(),
      'durationSec': durationSec,
      'warmupScore': warmupScore,
      'warmupTotal': warmupTotal,
      'mode': modeName,
    };
    final list = prefs.getStringList(_sessionHistoryKey) ?? <String>[];
    list.add(jsonEncode(item));
    await prefs.setStringList(_sessionHistoryKey, list);
  }

  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_sessionHistoryKey) ?? <String>[];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  // ===========================
  // Session: Reset
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

  // ---- helpers ----
  int _toYmd(DateTime dt) => dt.year * 10000 + dt.month * 100 + dt.day;

  int _weekStartYmd(DateTime dt) {
    final local = dt;
    final int daysFromMonday = local.weekday - DateTime.monday;
    final monday = DateTime(local.year, local.month, local.day)
        .subtract(Duration(days: daysFromMonday));
    return _toYmd(monday);

  }
}