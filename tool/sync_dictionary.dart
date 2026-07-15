// Scans assets/images/<category>/ for image files and syncs assets/data/words.json
// so new signs show up in the app without hand-editing JSON.
//
// Usage:
//   dart run tool/sync_dictionary.dart
//
// Naming convention: lowercase, underscore-separated file names.
//   thank_you.jpg              -> one image
//   thank_you_1.jpg, _2.jpg    -> a step sequence, shown in order
//
// Existing entries are updated (category + image list) but their word,
// description, and sentences are left untouched. New entries are created
// with an empty description/sentences for a human to fill in afterward.
// Nothing is ever deleted automatically.

import 'dart:convert';
import 'dart:io';

const Map<String, String> categoryByFolder = {
  'greetings': 'Greetings',
  'family': 'Family',
  'question_words': 'Question Words',
  'food': 'Food',
  'cooking': 'Cooking',
  'work': 'Work',
  'months': 'Months',
  'days_and_time': 'Days and Time',
  'numbers': 'Numbers',
  'house': 'House',
  'making_plans': 'Making Plans',
  'weather': 'Weather',
  'health_and_wellbeing': 'Health and Well-being',
  'feeling': 'Feeling',
  'adjectives': 'Adjectives',
  'bible': 'Bible',
  'school': 'School',
  'verbs': 'Verbs',
  'places': 'Places',
  'quantities': 'Quantities',
  'comparisons': 'Comparisons',
  'colours': 'Colours',
  'prepositions': 'Prepositions',
};

const List<String> imageExtensions = ['.jpg', '.jpeg', '.png'];

void main() {
  final imagesRoot = Directory('assets/images');
  final wordsFile = File('assets/data/words.json');

  if (!imagesRoot.existsSync() || !wordsFile.existsSync()) {
    stderr.writeln(
        'Run this from the project root (expects assets/images/ and assets/data/words.json).');
    exit(1);
  }

  final json = jsonDecode(wordsFile.readAsStringSync()) as Map<String, dynamic>;
  final categories = (json['categories'] as List).cast<String>();
  final existingEntries = (json['entries'] as List).cast<Map<String, dynamic>>();
  final entriesById = {for (final e in existingEntries) e['id'] as String: e};

  var created = 0;
  var updated = 0;
  final unknownFolders = <String>[];

  for (final folder in imagesRoot.listSync().whereType<Directory>()) {
    final folderName = folder.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final category = categoryByFolder[folderName];
    if (category == null) {
      unknownFolders.add(folderName);
      continue;
    }

    // Group image files in this folder by their sign id (strips a
    // trailing _<number> step suffix, e.g. thank_you_1.jpg -> thank_you).
    final groups = <String, List<MapEntry<int, File>>>{};
    for (final file in folder.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      final dot = name.lastIndexOf('.');
      if (dot == -1) continue;
      final ext = name.substring(dot).toLowerCase();
      if (!imageExtensions.contains(ext)) continue;

      final base = name.substring(0, dot);
      final match = RegExp(r'^(.*)_(\d+)$').firstMatch(base);
      final id = match != null ? match.group(1)! : base;
      final step = match != null ? int.parse(match.group(2)!) : 0;

      groups.putIfAbsent(id, () => []).add(MapEntry(step, file));
    }

    for (final entry in groups.entries) {
      final id = entry.key;
      final images = entry.value
        ..sort((a, b) => a.key.compareTo(b.key));
      final imagePaths = images
          .map((e) => 'assets/images/$folderName/${e.value.uri.pathSegments.last}')
          .toList();

      final existing = entriesById[id];
      if (existing != null) {
        existing['category'] = category;
        existing['images'] = imagePaths;
        updated++;
      } else {
        final word = id
            .replaceAll('_', ' ')
            .replaceFirstMapped(RegExp('^.'), (m) => m.group(0)!.toUpperCase());
        entriesById[id] = {
          'id': id,
          'word': word,
          'category': category,
          'description': '',
          'images': imagePaths,
          'video': null,
          'sentences': <String>[],
        };
        created++;
      }
    }
  }

  final sortedEntries = entriesById.values.toList()
    ..sort((a, b) {
      final catCompare = categories
          .indexOf(a['category'] as String)
          .compareTo(categories.indexOf(b['category'] as String));
      if (catCompare != 0) return catCompare;
      return (a['word'] as String).compareTo(b['word'] as String);
    });

  json['entries'] = sortedEntries;
  const encoder = JsonEncoder.withIndent('  ');
  wordsFile.writeAsStringSync('${encoder.convert(json)}\n');

  stdout.writeln('Sync complete: $created new entries, $updated updated.');
  if (unknownFolders.isNotEmpty) {
    stdout.writeln(
        'Skipped folders not in a known category (check categoryByFolder in this script): ${unknownFolders.join(', ')}');
  }
  final emptyDescriptions = sortedEntries.where((e) => (e['description'] as String).isEmpty);
  if (emptyDescriptions.isNotEmpty) {
    stdout.writeln(
        'Entries still needing a description/sentences: ${emptyDescriptions.map((e) => e['id']).join(', ')}');
  }
}
