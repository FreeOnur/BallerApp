import 'package:flutter/services.dart';

class BadwordFilter {
  static Set<String> _badWords = {};

  static Future<void> loadWords() async {
    final raw = await rootBundle.loadString('/lib/assets/badwords.txt');
    _badWords = raw.split('\n').map((word) => word.trim().toLowerCase()).toSet();
  }
  static bool containsBadWord(String text) {
    final lowerInput = text.toLowerCase();
    return _badWords.any((badWord) => lowerInput.contains(badWord));
  }
}