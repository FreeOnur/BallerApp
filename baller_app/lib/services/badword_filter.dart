import 'package:flutter/services.dart' show rootBundle;
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
>>>>>>> 57071972e109ef32e3450b22982bd4c8245462b9

class BadwordFilter {
  static RegExp? _badWordRegExp;

  static Future<void> loadWords() async {
    final raw = await rootBundle.loadString('assets/badwords.txt');
<<<<<<< HEAD
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
    final lower = text.toLowerCase();
    for (final bad in _badWords) {
      if (lower.contains(bad)) return true;
    }
    return false;
=======
    final words = raw.split('\n').map((word) => RegExp.escape(word.trim().toLowerCase())).where((word) => word.isNotEmpty).toList();

    final pattern = r'\b(' + words.join('|') + r')\b';
    _badWordRegExp = RegExp(pattern, caseSensitive: false);
  }

  static bool containsBadWord(String text) {
    if(_badWordRegExp == null) return false;
    return _badWordRegExp!.hasMatch(text.toLowerCase());
>>>>>>> 57071972e109ef32e3450b22982bd4c8245462b9
  }
}
