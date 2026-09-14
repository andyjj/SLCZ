import 'package:cloud_firestore/cloud_firestore.dart';

/// A piece of raw footage an admin has submitted for a sign, awaiting
/// local transcoding (to WebP/MP4) before it becomes part of a SignPack.
/// Mirrors a document in the Firestore "submissions" collection.
class SignSubmission {
  final String id;
  final String word;
  final String category;
  final String description;
  final List<String> sentences;
  final String rawFileUrl;
  final String rawFileName;
  final String status; // 'pending' | 'processed'
  final String submittedBy;
  final DateTime? submittedAt;

  const SignSubmission({
    required this.id,
    required this.word,
    required this.category,
    required this.description,
    required this.sentences,
    required this.rawFileUrl,
    required this.rawFileName,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
  });

  factory SignSubmission.fromFirestore(String id, Map<String, dynamic> data) {
    return SignSubmission(
      id: id,
      word: data['word'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      sentences: (data['sentences'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      rawFileUrl: data['rawFileUrl'] as String? ?? '',
      rawFileName: data['rawFileName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      submittedBy: data['submittedBy'] as String? ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
    );
  }
}
