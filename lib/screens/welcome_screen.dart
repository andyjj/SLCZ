import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/dictionary_repository.dart';
import '../data/favorites_repository.dart';
import 'auth_screen.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'quiz_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final DictionaryRepository repository;
  final FavoritesRepository favoritesRepository;
  final AuthRepository authRepository;

  const WelcomeScreen({
    super.key,
    required this.repository,
    required this.favoritesRepository,
    required this.authRepository,
  });

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: Text('Signed in as ${authRepository.email}. Ads will show again after signing out.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) {
      await authRepository.signOut();
    }
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
                          authRepository: authRepository,
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
              ListenableBuilder(
                listenable: authRepository,
                builder: (context, _) {
                  if (authRepository.isSignedIn) {
                    return TextButton.icon(
                      icon: const Icon(Icons.workspace_premium_rounded, size: 18, color: Colors.amber),
                      label: Text('Ad-free — signed in as ${authRepository.email}'),
                      onPressed: () => _confirmSignOut(context),
                    );
                  }
                  return TextButton.icon(
                    icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                    label: const Text('Go ad-free — sign up'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AuthScreen(authRepository: authRepository),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
