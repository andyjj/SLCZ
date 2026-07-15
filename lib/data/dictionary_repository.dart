import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/dictionary_entry.dart';

/// Loads the dictionary from the bundled JSON asset.
///
/// Everything here works fully offline: the JSON and every image it
/// references are packaged inside the app at build time (see pubspec.yaml),
/// so no network access is ever required to browse the dictionary.
class DictionaryRepository {
  static const String _dataPath = 'assets/data/words.json';

  List<String> _categories = [];
  List<DictionaryEntry> _entries = [];
  bool _loaded = false;

  List<String> get categories => _categories;
  List<DictionaryEntry> get entries => _entries;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_dataPath);
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;

    _categories = (json['categories'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList();

    _entries = (json['entries'] as List<dynamic>? ?? [])
        .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  List<DictionaryEntry> entriesForCategory(String category) {
    return _entries.where((e) => e.category == category).toList()
      ..sort((a, b) => a.word.compareTo(b.word));
  }

  List<DictionaryEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _entries.where((e) => e.word.toLowerCase().contains(q)).toList()
      ..sort((a, b) => a.word.compareTo(b.word));
  }

  /// Count of entries per category, useful for showing "3 signs" etc.
  /// on the category picker screen.
  int countForCategory(String category) {
    return _entries.where((e) => e.category == category).length;
  }
}
