import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class BadwordFilter {
  static Set<String> _badWords = {};

  static Future<void> loadWords() async {
    final raw = await rootBundle.loadString('assets/badwords.txt');
    _badWords = await compute(_parseBadWords, raw);
  }

  static Set<String> _parseBadWords(String raw) {
    final lines = raw.split('\n');
    return lines
        .map((word) => word.trim().toLowerCase())
        .where((w) => w.isNotEmpty)
        .toSet();
  }

  static bool containsBadWord(String text) {
    final lower = text.toLowerCase().split(RegExp(r'\s+'));
    for (final bad in _badWords) {
      if (lower.contains(bad)) return true;
    }
    return false;
  }
}
