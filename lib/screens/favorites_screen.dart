import 'package:flutter/material.dart';
import '../data/dictionary_repository.dart';
import '../data/favorites_repository.dart';
import 'entry_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final DictionaryRepository repository;
  final FavoritesRepository favoritesRepository;

  const FavoritesScreen({
    super.key,
    required this.repository,
    required this.favoritesRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning List')),
      body: ListenableBuilder(
        listenable: favoritesRepository,
        builder: (context, _) {
          final favorites = repository.entries
              .where((e) => favoritesRepository.isFavorite(e.id))
              .toList()
            ..sort((a, b) => a.word.compareTo(b.word));

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No signs saved yet.\nTap the star on any sign to add it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = favorites[index];
              final hasImage = entry.images.isNotEmpty;
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  title: Text(entry.word, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(entry.category),
                  trailing: Icon(Icons.star_rounded, color: Colors.amber.shade700),
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
          );
        },
      ),
    );
  }
}
