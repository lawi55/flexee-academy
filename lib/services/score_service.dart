import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _totalScoreKey = 'total_score';

  /// Get total accumulated score
  static Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalScoreKey) ?? 0;
  }

  /// Add points to total score
  static Future<void> addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalScoreKey) ?? 0;
    await prefs.setInt(_totalScoreKey, current + points);
  }

  /// Reset score (for testing / logout)
  static Future<void> resetScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalScoreKey);
  }
}
