import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/sign_submission.dart';

/// Handles admin sign-content submissions: uploads raw footage to Firebase
/// Storage and its metadata to Firestore, where it waits ("pending") to be
/// pulled down and transcoded locally (see tool/process_submissions.dart)
/// before being folded into a SignPack.
class SubmissionRepository {
  static const String _collection = 'submissions';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  SubmissionRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> submitSign({
    required String word,
    required String category,
    required String description,
    required List<String> sentences,
    required Uint8List fileBytes,
    required String fileName,
    required String submittedBy,
  }) async {
    final storagePath = 'submissions/raw/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = _storage.ref(storagePath);
    await ref.putData(fileBytes);
    final url = await ref.getDownloadURL();

    await _firestore.collection(_collection).add({
      'word': word,
      'category': category,
      'description': description,
      'sentences': sentences,
      'rawFileUrl': url,
      'rawFileName': fileName,
      'status': 'pending',
      'submittedBy': submittedBy,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live list of submissions, most recent first — lets an admin see what's
  /// been submitted and its processing status.
  Stream<List<SignSubmission>> watchSubmissions() {
    return _firestore
        .collection(_collection)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => SignSubmission.fromFirestore(d.id, d.data())).toList());
  }
}
