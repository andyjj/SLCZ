import 'dart:math';
import 'package:flutter/material.dart';
import '../data/dictionary_repository.dart';
import '../models/dictionary_entry.dart';

class QuizScreen extends StatefulWidget {
  final DictionaryRepository repository;

  const QuizScreen({super.key, required this.repository});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizQuestion {
  final DictionaryEntry correct;
  final List<DictionaryEntry> options;

  _QuizQuestion({required this.correct, required this.options});
}

const int _questionsPerRound = 10;
const int _optionsPerQuestion = 4;

class _QuizScreenState extends State<QuizScreen> {
  late List<_QuizQuestion> _questions;
  int _questionIndex = 0;
  int _score = 0;
  DictionaryEntry? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  List<_QuizQuestion> _buildQuestions() {
    final eligible = widget.repository.entries.where((e) => e.images.isNotEmpty).toList();
    eligible.shuffle();

    final questionCount = min(_questionsPerRound, eligible.length);
    final questionEntries = eligible.take(questionCount).toList();

    return questionEntries.map((correct) {
      final distractorPool = eligible.where((e) => e.id != correct.id).toList()..shuffle();
      final distractors = distractorPool.take(_optionsPerQuestion - 1).toList();
      final options = [correct, ...distractors]..shuffle();
      return _QuizQuestion(correct: correct, options: options);
    }).toList();
  }

  void _restart() {
    setState(() {
      _questions = _buildQuestions();
      _questionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
    });
  }

  void _selectAnswer(DictionaryEntry answer) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = answer;
      if (answer.id == _questions[_questionIndex].correct.id) {
        _score++;
      }
    });
  }

  void _next() {
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Add some signs with images before starting a quiz.'),
          ),
        ),
      );
    }

    if (_questionIndex >= _questions.length) {
      return _buildResultsScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_questionIndex];
    final navy = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz — ${_questionIndex + 1} of ${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'What is this sign?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(question.correct.images.first, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = _selectedAnswer?.id == option.id;
                  final isCorrect = option.id == question.correct.id;
                  final answered = _selectedAnswer != null;

                  Color? backgroundColor;
                  if (answered && isCorrect) {
                    backgroundColor = Colors.green.shade100;
                  } else if (answered && isSelected && !isCorrect) {
                    backgroundColor = Colors.red.shade100;
                  }

                  return Material(
                    color: backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectAnswer(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: answered && isCorrect ? Colors.green : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.word,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (answered && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
                            if (answered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedAnswer != null)
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
                child: Text(_questionIndex + 1 < _questions.length ? 'Next' : 'See results'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final navy = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded, size: 72, color: navy),
              const SizedBox(height: 16),
              Text(
                'You scored $_score / ${_questions.length}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _restart, child: const Text('Play again')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
