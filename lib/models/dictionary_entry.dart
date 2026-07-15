/// A single entry in the sign language dictionary.
///
/// This mirrors the structure of assets/data/words.json exactly.
/// Adding a new sign to the app never requires touching Dart code —
/// just add an entry to that JSON file and drop the images into
/// assets/images/<category_folder>/.
class DictionaryEntry {
  final String id;
  final String word;
  final String category;
  final String description;
  final List<String> images;
  final String? video;
  final List<String> sentences;

  const DictionaryEntry({
    required this.id,
    required this.word,
    required this.category,
    required this.description,
    required this.images,
    this.video,
    required this.sentences,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      id: json['id'] as String,
      word: json['word'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      video: json['video'] as String?,
      sentences: (json['sentences'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}
