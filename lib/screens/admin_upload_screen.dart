import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/dictionary_repository.dart';
import '../data/submission_repository.dart';
import '../models/sign_submission.dart';

class AdminUploadScreen extends StatefulWidget {
  final DictionaryRepository repository;
  final SubmissionRepository submissionRepository;
  final String adminEmail;

  const AdminUploadScreen({
    super.key,
    required this.repository,
    required this.submissionRepository,
    required this.adminEmail,
  });

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _wordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sentencesController = TextEditingController();
  String? _category;
  PlatformFile? _pickedFile;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _wordController.dispose();
    _descriptionController.dispose();
    _sentencesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
    );
    if (result.isNotEmpty) {
      setState(() => _pickedFile = result.first);
    }
  }

  Future<void> _submit() async {
    final word = _wordController.text.trim();
    final description = _descriptionController.text.trim();
    final sentences = _sentencesController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (word.isEmpty || _category == null || _pickedFile == null) {
      setState(() => _error = 'Word, category, and a footage file are all required.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final fileBytes = await _pickedFile!.readAsBytes();
      await widget.submissionRepository.submitSign(
        word: word,
        category: _category!,
        description: description,
        sentences: sentences,
        fileBytes: fileBytes,
        fileName: _pickedFile!.name,
        submittedBy: widget.adminEmail,
      );
      if (!mounted) return;
      _wordController.clear();
      _descriptionController.clear();
      _sentencesController.clear();
      setState(() {
        _category = null;
        _pickedFile = null;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted — pending local transcode.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not submit: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Submit a Sign')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _wordController,
                    decoration: const InputDecoration(labelText: 'Word', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: widget.repository.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Sign description (how to perform it)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sentencesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Example sentences (one per line)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(_pickedFile == null ? 'Choose raw footage' : _pickedFile!.name),
                    onPressed: _pickFile,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _SubmissionsList(submissionRepository: widget.submissionRepository)),
        ],
      ),
    );
  }
}

class _SubmissionsList extends StatelessWidget {
  final SubmissionRepository submissionRepository;

  const _SubmissionsList({required this.submissionRepository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SignSubmission>>(
      stream: submissionRepository.watchSubmissions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final submissions = snapshot.data ?? [];
        if (submissions.isEmpty) {
          return const Center(child: Text('No submissions yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final s = submissions[index];
            return Card(
              child: ListTile(
                title: Text('${s.word} (${s.category})'),
                subtitle: Text('${s.rawFileName} — ${s.status}'),
                trailing: Icon(
                  s.status == 'processed' ? Icons.check_circle : Icons.hourglass_top,
                  color: s.status == 'processed' ? Colors.green : Colors.orange,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
