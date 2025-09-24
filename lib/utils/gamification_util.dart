// lib/utils/gamification_util.dart

// A simple class to hold all the info about a user's current level
class LevelInfo {
  final int level;
  final String title;
  final int currentPoints;      // The user's total points
  final int pointsForThisLevel; // Points required to enter this level
  final int pointsForNextLevel; // Points required for the next level

  LevelInfo({
    required this.level,
    required this.title,
    required this.currentPoints,
    required this.pointsForThisLevel,
    required this.pointsForNextLevel,
  });

  // A helper to calculate progress for the progress bar (0.0 to 1.0)
  double get progress {
    if (pointsForNextLevel <= pointsForThisLevel) return 1.0; // Max level
    final pointsInThisLevel = currentPoints - pointsForThisLevel;
    final totalPointsForLevel = pointsForNextLevel - pointsForThisLevel;
    return pointsInThisLevel / totalPointsForLevel;
  }
}

// The core definitions for your levels
const _levels = [
  {'level': 0, 'title': 'Newbie', 'points': 0},
  {'level': 1, 'title': 'Beginner', 'points': 1000},       // ~17 mins
  {'level': 2, 'title': 'Apprentice', 'points': 5000},     // ~1.4 hours
  {'level': 3, 'title': 'Adept', 'points': 15000},         // ~4 hours
  {'level': 4, 'title': 'Expert', 'points': 30000},        // ~8 hours
  {'level': 5, 'title': 'Mastermind', 'points': 50000},    // ~14 hours
];

// The main function that calculates the user's level info
LevelInfo calculateLevelInfo(int totalPoints) {
  Map<String, dynamic> currentLevel = _levels.first;
  Map<String, dynamic> nextLevel = _levels.first;

  // Find the current level by checking where the user's points fit
  for (final levelData in _levels) {
    if (totalPoints >= (levelData['points'] as int)) {
      currentLevel = levelData;
    } else {
      // The first level we don't qualify for is our "next" level
      nextLevel = levelData;
      break;
    }
  }

  // Handle the case where the user is at the max level
  if (totalPoints >= (currentLevel['points'] as int) && currentLevel == _levels.last) {
    nextLevel = currentLevel;
  }

  return LevelInfo(
    level: currentLevel['level'] as int,
    title: currentLevel['title'] as String,
    currentPoints: totalPoints,
    pointsForThisLevel: currentLevel['points'] as int,
    pointsForNextLevel: nextLevel['points'] as int,
  );
}