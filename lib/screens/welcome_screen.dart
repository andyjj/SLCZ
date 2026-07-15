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
              // A simple hands/greeting icon stands in for branded artwork —
              // swap in a real logo image later via assets/images/.
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.front_hand_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Zambia Sign\nLanguage Hub',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'Signs Made Simple',
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
