import 'package:flutter/material.dart';
import '../data/dictionary_repository.dart';
import 'category_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final DictionaryRepository repository;

  const WelcomeScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
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
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 24),
              Text(
                'SLCZ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign Language Channel of Zambia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Works fully offline — no internet needed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
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
                        builder: (_) => CategoryScreen(repository: repository),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
