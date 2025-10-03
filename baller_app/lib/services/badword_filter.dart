import 'package:flutter/services.dart' show rootBundle;

class BadwordFilter {
  static RegExp? _badWordRegExp;

  static Future<void> loadWords() async {
    final raw = await rootBundle.loadString('assets/badwords.txt');
    final words = raw.split('\n').map((word) => RegExp.escape(word.trim().toLowerCase())).where((word) => word.isNotEmpty).toList();

    final pattern = r'\b(' + words.join('|') + r')\b';
    _badWordRegExp = RegExp(pattern, caseSensitive: false);
  }

  static bool containsBadWord(String text) {
    if(_badWordRegExp == null) return false;
    return _badWordRegExp!.hasMatch(text.toLowerCase());
  }
}
