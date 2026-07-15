import 'package:flutter/material.dart';
import '../data/dictionary_repository.dart';
import '../data/favorites_repository.dart';
import 'entry_detail_screen.dart';

class EntryListScreen extends StatelessWidget {
  final DictionaryRepository repository;
  final FavoritesRepository favoritesRepository;
  final String category;

  const EntryListScreen({
    super.key,
    required this.repository,
    required this.favoritesRepository,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final entries = repository.entriesForCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No signs added to "$category" yet.\nAdd entries in assets/data/words.json.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final hasImage = entry.images.isNotEmpty;
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              entry.images.first,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.front_hand_rounded,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                    title: Text(
                      entry.word,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListenableBuilder(
                          listenable: favoritesRepository,
                          builder: (context, _) {
                            final isFavorite = favoritesRepository.isFavorite(entry.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                color: isFavorite ? Colors.amber.shade700 : Colors.grey.shade400,
                              ),
                              onPressed: () => favoritesRepository.toggle(entry.id),
                            );
                          },
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EntryDetailScreen(
                            entry: entry,
                            favoritesRepository: favoritesRepository,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
