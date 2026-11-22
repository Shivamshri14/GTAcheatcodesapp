import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favorites extends ChangeNotifier {
  static const _key = 'favorites_v1';
  final Set<String> _ids = {};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _ids.addAll(_prefs!.getStringList(_key) ?? const []);
  }

  bool contains(String id) => _ids.contains(id);
  Set<String> get ids => Set.unmodifiable(_ids);

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    _prefs?.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}
