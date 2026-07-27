import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dictionary_entry.dart';

/// Lets a signed-in user email feedback about a specific sign (e.g. regional
/// differences, questions) to the SLCZ team. Opens the device's email app
/// pre-filled — the user still has to tap Send there themselves. A fully
/// silent, in-app send is a possible future upgrade once a backend mail
/// sender (e.g. a Firebase Extension) is set up.
class FeedbackSection extends StatefulWidget {
  final DictionaryEntry entry;
  final String? userEmail;

  const FeedbackSection({super.key, required this.entry, this.userEmail});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  static const String _recipient = 'slczambia@gmail.com';

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter some feedback first.')),
      );
      return;
    }

    final bodyLines = [
      'Sign: ${widget.entry.word} (${widget.entry.category})',
      if (widget.userEmail != null) 'From: ${widget.userEmail}',
      '',
      feedback,
    ];

    final uri = Uri(
      scheme: 'mailto',
      path: _recipient,
      queryParameters: {
        'subject': 'Mobile App Comment ${widget.entry.word}',
        'body': bodyLines.join('\n'),
      },
    );

    final launched = await launchUrl(uri);
    if (!mounted) return;

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open an email app. Is one installed on this device?')),
      );
      return;
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(8)),
          child: const Text(
            'Feedback',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Notice a regional difference in how this sign is done, or have a question? Let us know.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.email_outlined),
          label: const Text('Send Feedback'),
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
