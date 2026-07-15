import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';

class EntryDetailScreen extends StatelessWidget {
  final DictionaryEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(entry.category)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            entry.word,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 24),

          if (entry.description.isNotEmpty) ...[
            _SectionHeader(title: 'Sign Description', color: navy),
            const SizedBox(height: 12),
            Text(
              entry.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),
          ],

          if (entry.images.isNotEmpty) ...[
            _SectionHeader(title: 'Visual Support', color: navy),
            const SizedBox(height: 12),
            // Step-by-step images, shown in sequence — swipe through them
            // like a flip-book of the sign being performed.
            _ImageStepSequence(images: entry.images),
            const SizedBox(height: 24),
          ],

          if (entry.sentences.isNotEmpty) ...[
            _SectionHeader(title: 'Potential Sentences', color: navy),
            const SizedBox(height: 12),
            ...entry.sentences.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${e.key + 1}.) ${e.value}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ImageStepSequence extends StatefulWidget {
  final List<String> images;

  const _ImageStepSequence({required this.images});

  @override
  State<_ImageStepSequence> createState() => _ImageStepSequenceState();
}

class _ImageStepSequenceState extends State<_ImageStepSequence> {
  int _currentPage = 0;
  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return Image.asset(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentPage ? navy : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Step ${_currentPage + 1} of ${widget.images.length} — swipe to see the next step',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }
}
