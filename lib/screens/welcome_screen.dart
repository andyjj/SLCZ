import 'package:flutter/material.dart';
import '../data/dictionary_repository.dart';
import '../data/favorites_repository.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'quiz_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final DictionaryRepository repository;
  final FavoritesRepository favoritesRepository;

  const WelcomeScreen({
    super.key,
    required this.repository,
    required this.favoritesRepository,
  });

  void _showPremiumComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SLCZ Premium'),
        content: const Text(
          'An ad-free, registered version of SLCZ is coming soon. '
          'Check back here to sign up once it\'s available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;
    final secondaryButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      foregroundColor: navy,
      side: BorderSide(color: navy),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/branding/logo.png',
                width: 140,
                height: 140,
              ),
              const SizedBox(height: 20),
              Text(
                'SLCZ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign Language Channel of Zambia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Works fully offline — no internet needed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Open Dictionary'),
                onPressed: () async {
                  await repository.load();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(
                          repository: repository,
                          favoritesRepository: favoritesRepository,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.star_rounded),
                label: const Text('My Learning List'),
                style: secondaryButtonStyle,
                onPressed: () async {
                  await repository.load();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FavoritesScreen(
                          repository: repository,
                          favoritesRepository: favoritesRepository,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Quiz / Practice'),
                style: secondaryButtonStyle,
                onPressed: () async {
                  await repository.load();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(repository: repository),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                label: const Text('Go ad-free — sign up'),
                onPressed: () => _showPremiumComingSoon(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
