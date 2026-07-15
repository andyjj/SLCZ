import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which dictionary entries the user has saved to their learning
/// list, persisted locally so it survives app restarts with no network.
class FavoritesRepository extends ChangeNotifier {
  static const String _prefsKey = 'favorite_entry_ids';

  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggle(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favoriteIds.toList());
  }
}
