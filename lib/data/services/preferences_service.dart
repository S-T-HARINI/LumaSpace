import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_action.dart';

class PreferencesService {
  static const String _keyKeptIds = 'lumaspace_kept_ids';
  static const String _keyPendingIds = 'lumaspace_pending_ids';
  static const String _keyDeselectedIds = 'lumaspace_deselected_ids';
  static const String _keyActionHistory = 'lumaspace_action_history';

  final SharedPreferences? _prefs;

  PreferencesService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<Set<String>> loadKeptIds() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_keyKeptIds) ?? [];
    return list.toSet();
  }

  Future<void> saveKeptIds(Set<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_keyKeptIds, ids.toList());
  }

  Future<Set<String>> loadPendingIds() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_keyPendingIds) ?? [];
    return list.toSet();
  }

  Future<void> savePendingIds(Set<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_keyPendingIds, ids.toList());
  }

  Future<Set<String>> loadDeselectedIds() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_keyDeselectedIds) ?? [];
    return list.toSet();
  }

  Future<void> saveDeselectedIds(Set<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_keyDeselectedIds, ids.toList());
  }

  Future<List<ReviewAction>> loadActionHistory() async {
    final prefs = await _getPrefs();
    final raw = prefs.getStringList(_keyActionHistory) ?? [];
    final List<ReviewAction> list = [];
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        list.add(ReviewAction.fromJson(map));
      } catch (_) {}
    }
    return list;
  }

  Future<void> saveActionHistory(List<ReviewAction> history) async {
    final prefs = await _getPrefs();
    final stringList = history.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyActionHistory, stringList);
  }

  Future<void> clearAllReviewData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyKeptIds);
    await prefs.remove(_keyPendingIds);
    await prefs.remove(_keyDeselectedIds);
    await prefs.remove(_keyActionHistory);
  }
}
