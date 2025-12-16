import 'package:shared_preferences/shared_preferences.dart';

class QuizCooldownService {
  static const int cooldownHours = 24;

  static String _key(String difficulty) => 'quiz_last_played_$difficulty';

  /// Check if quiz can be played
  static Future<bool> canPlay(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayed = prefs.getInt(_key(difficulty));

    if (lastPlayed == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastPlayed;

    return diff >= Duration(hours: cooldownHours).inMilliseconds;
  }

  /// Save play timestamp
  static Future<void> markPlayed(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(difficulty), DateTime.now().millisecondsSinceEpoch);
  }

  /// Remaining cooldown (optional, for UI)
  static Future<Duration?> remainingTime(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayed = prefs.getInt(_key(difficulty));
    if (lastPlayed == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastPlayed;
    final cooldownMs = Duration(hours: cooldownHours).inMilliseconds;

    if (elapsed >= cooldownMs) return Duration.zero;

    return Duration(milliseconds: cooldownMs - elapsed);
  }

  /// 🔴 DEMO / TESTING ONLY
  /// Reset cooldown for one difficulty
  static Future<void> reset(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(difficulty));
  }

  /// 🔴 DEMO / TESTING ONLY
  /// Reset ALL quiz cooldowns
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key("easy"));
    await prefs.remove(_key("medium"));
    await prefs.remove(_key("hard"));
  }
}
