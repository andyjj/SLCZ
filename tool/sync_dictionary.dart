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
// Optionally, drop a thank_you_definition.txt file next to the images (same
// folder) with an English description of how to perform the sign — its
// contents become that entry's "description". If no such file exists, the
// description is left blank for a human to fill in later (or untouched, if
// one was already written by hand directly in words.json).
//
// Existing entries are updated (category + image list) but their word and
// sentences are left untouched. New entries are created with an empty
// description/sentences for a human to fill in afterward. Nothing is ever
// deleted automatically.
//
// Any image wider or taller than maxImageDimension is also downscaled and
// re-compressed in place, so photos straight off a phone camera don't bloat
// the app. This overwrites the file — keep your own full-resolution copies
// elsewhere if you want to preserve the originals.

import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

const int maxImageDimension = 1600;
const int jpegQuality = 85;

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

/// Downscales [file] in place if it's larger than [maxImageDimension] on
/// either edge. Returns the number of bytes saved, or 0 if it was already
/// small enough to leave untouched.
int resizeIfNeeded(File file, String ext) {
  final originalBytes = file.readAsBytesSync();
  final decoded = img.decodeImage(originalBytes);
  if (decoded == null) return 0; // not a readable image; leave it alone

  if (decoded.width <= maxImageDimension && decoded.height <= maxImageDimension) {
    return 0;
  }

  final resized = decoded.width >= decoded.height
      ? img.copyResize(decoded, width: maxImageDimension)
      : img.copyResize(decoded, height: maxImageDimension);

  final encoded = ext == '.png' ? img.encodePng(resized) : img.encodeJpg(resized, quality: jpegQuality);
  file.writeAsBytesSync(encoded);
  return originalBytes.length - encoded.length;
}

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
  var resizedCount = 0;
  var bytesSaved = 0;
  final unknownFolders = <String>[];

  // First pass: group image files per folder by sign id (stripping a
  // trailing _<number> step suffix, e.g. thank_you_1.jpg -> thank_you).
  // Recorded per-folder so we can detect the same base id appearing in more
  // than one category folder before deciding on final ids.
  final groupsByFolder = <String, Map<String, List<MapEntry<int, File>>>>{};
  final folderCategory = <String, String>{};
  final definitionsByFolder = <String, Map<String, String>>{};

  for (final folder in imagesRoot.listSync().whereType<Directory>()) {
    final folderName = folder.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final category = categoryByFolder[folderName];
    if (category == null) {
      unknownFolders.add(folderName);
      continue;
    }
    folderCategory[folderName] = category;

    final groups = <String, List<MapEntry<int, File>>>{};
    final definitions = <String, String>{};
    for (final file in folder.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;

      if (name.toLowerCase().endsWith('_definition.txt')) {
        final baseId = name.substring(0, name.length - '_definition.txt'.length);
        final text = file.readAsStringSync().trim();
        if (text.isNotEmpty) definitions[baseId] = text;
        continue;
      }

      final dot = name.lastIndexOf('.');
      if (dot == -1) continue;
      final ext = name.substring(dot).toLowerCase();
      if (!imageExtensions.contains(ext)) continue;

      final saved = resizeIfNeeded(file, ext);
      if (saved > 0) {
        resizedCount++;
        bytesSaved += saved;
      }

      final base = name.substring(0, dot);
      final match = RegExp(r'^(.*)_(\d+)$').firstMatch(base);
      final baseId = match != null ? match.group(1)! : base;
      final step = match != null ? int.parse(match.group(2)!) : 0;

      groups.putIfAbsent(baseId, () => []).add(MapEntry(step, file));
    }
    groupsByFolder[folderName] = groups;
    definitionsByFolder[folderName] = definitions;
  }

  // A base id that shows up in more than one category folder would silently
  // collide (and overwrite each other) if used as-is, since ids must be
  // unique across the whole dictionary. Prefix with the folder name only
  // for ids that actually collide, so unambiguous ids (the common case)
  // stay short and human-friendly.
  final baseIdFolderCount = <String, int>{};
  for (final groups in groupsByFolder.values) {
    for (final baseId in groups.keys) {
      baseIdFolderCount[baseId] = (baseIdFolderCount[baseId] ?? 0) + 1;
    }
  }
  final disambiguated = <String>[];
  var definitionsApplied = 0;

  for (final folderEntry in groupsByFolder.entries) {
    final folderName = folderEntry.key;
    final category = folderCategory[folderName]!;

    for (final group in folderEntry.value.entries) {
      final baseId = group.key;
      final collides = baseIdFolderCount[baseId]! > 1;
      final id = collides ? '${folderName}_$baseId' : baseId;
      if (collides) disambiguated.add('$folderName/$baseId -> $id');

      final images = group.value..sort((a, b) => a.key.compareTo(b.key));
      final imagePaths = images
          .map((e) => 'assets/images/$folderName/${e.value.uri.pathSegments.last}')
          .toList();
      final definition = definitionsByFolder[folderName]?[baseId];

      final existing = entriesById[id];
      if (existing != null) {
        existing['category'] = category;
        existing['images'] = imagePaths;
        if (definition != null) {
          existing['description'] = definition;
          definitionsApplied++;
        }
        updated++;
      } else {
        final word = baseId
            .replaceAll('_', ' ')
            .replaceFirstMapped(RegExp('^.'), (m) => m.group(0)!.toUpperCase());
        if (definition != null) definitionsApplied++;
        entriesById[id] = {
          'id': id,
          'word': word,
          'category': category,
          'description': definition ?? '',
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
  if (definitionsApplied > 0) {
    stdout.writeln('Applied $definitionsApplied description(s) from *_definition.txt files.');
  }
  if (resizedCount > 0) {
    final savedMb = (bytesSaved / (1024 * 1024)).toStringAsFixed(1);
    stdout.writeln(
        'Resized $resizedCount image(s) down to a max of ${maxImageDimension}px (saved ${savedMb}MB).');
  }
  if (disambiguated.isNotEmpty) {
    stdout.writeln(
        'Note: these ids collided across categories and were auto-prefixed with their folder name:\n  ${disambiguated.join('\n  ')}');
  }
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
