import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/dictionary_repository.dart';
import '../data/favorites_repository.dart';
import '../widgets/ad_banner_placeholder.dart';
import 'entry_list_screen.dart';
import 'entry_detail_screen.dart';

/// Icons chosen per category so the grid is easy to scan at a glance —
/// helpful for users still building English literacy alongside sign language.
const Map<String, IconData> _categoryIcons = {
  'Greetings': Icons.waving_hand_rounded,
  'Family': Icons.family_restroom_rounded,
  'Question Words': Icons.help_outline_rounded,
  'Food': Icons.restaurant_rounded,
  'Cooking': Icons.soup_kitchen_rounded,
  'Work': Icons.work_outline_rounded,
  'Months': Icons.calendar_month_rounded,
  'Days and Time': Icons.access_time_rounded,
  'Numbers': Icons.pin_rounded,
  'House': Icons.house_rounded,
  'Making Plans': Icons.event_note_rounded,
  'Weather': Icons.wb_sunny_rounded,
  'Health and Well-being': Icons.favorite_border_rounded,
  'Feeling': Icons.mood_rounded,
  'Adjectives': Icons.text_fields_rounded,
  'Bible': Icons.menu_book_rounded,
  'School': Icons.school_rounded,
  'Verbs': Icons.directions_run_rounded,
  'Places': Icons.place_outlined,
  'Quantities': Icons.numbers_rounded,
  'Comparisons': Icons.compare_arrows_rounded,
  'Colours': Icons.palette_outlined,
  'Prepositions': Icons.route_rounded,
};

class CategoryScreen extends StatefulWidget {
  final DictionaryRepository repository;
  final FavoritesRepository favoritesRepository;
  final AuthRepository authRepository;

  const CategoryScreen({
    super.key,
    required this.repository,
    required this.favoritesRepository,
    required this.authRepository,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResults = widget.repository.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for a word or expression...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!isSearching)
            ListenableBuilder(
              listenable: widget.authRepository,
              builder: (context, _) => widget.authRepository.isSignedIn
                  ? const SizedBox.shrink()
                  : const AdBannerPlaceholder(),
            ),
          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No matching signs found.'));
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final entry = _searchResults[index];
        return ListTile(
          title: Text(entry.word),
          subtitle: Text(entry.category),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EntryDetailScreen(
                  entry: entry,
                  favoritesRepository: widget.favoritesRepository,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    final categories = widget.repository.categories;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = widget.repository.countForCategory(category);
        return _CategoryCard(
          category: category,
          count: count,
          icon: _categoryIcons[category] ?? Icons.category_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EntryListScreen(
                  repository: widget.repository,
                  favoritesRepository: widget.favoritesRepository,
                  category: category,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: navy),
              const SizedBox(height: 8),
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '$count sign${count == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
