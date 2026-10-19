import 'package:flutter/foundation.dart';
import '../data/models/media_item.dart';
import '../data/models/review_action.dart';
import '../data/services/preferences_service.dart';

class ReviewProvider extends ChangeNotifier {
  final PreferencesService _prefsService;

  Set<String> _keptIds = {};
  Set<String> _pendingDeleteIds = {};
  List<ReviewAction> _actionHistory = [];
  bool _isInitialized = false;

  ReviewProvider([PreferencesService? prefsService])
      : _prefsService = prefsService ?? PreferencesService();

  Set<String> get keptIds => Set.unmodifiable(_keptIds);
  Set<String> get pendingDeleteIds => Set.unmodifiable(_pendingDeleteIds);
  List<ReviewAction> get actionHistory => List.unmodifiable(_actionHistory);
  bool get canUndo => _actionHistory.isNotEmpty;
  bool get isInitialized => _isInitialized;

  int get keptCount => _keptIds.length;
  int get pendingCount => _pendingDeleteIds.length;

  Future<void> initialize() async {
    _keptIds = await _prefsService.loadKeptIds();
    _pendingDeleteIds = await _prefsService.loadPendingIds();
    _actionHistory = await _prefsService.loadActionHistory();
    _isInitialized = true;
    notifyListeners();
  }

  bool isKept(String id) => _keptIds.contains(id);
  bool isPendingDelete(String id) => _pendingDeleteIds.contains(id);
  bool isReviewed(String id) => isKept(id) || isPendingDelete(id);

  List<MediaItem> getUnreviewedItems(List<MediaItem> allItems) {
    return allItems.where((item) => !isReviewed(item.id)).toList();
  }

  Future<void> markKeep(String mediaId) async {
    ReviewDecision? previous;
    if (_pendingDeleteIds.contains(mediaId)) {
      previous = ReviewDecision.pendingDelete;
      _pendingDeleteIds.remove(mediaId);
    }

    _keptIds.add(mediaId);

    final action = ReviewAction(
      mediaId: mediaId,
      decision: ReviewDecision.keep,
      timestamp: DateTime.now(),
      previousDecision: previous,
    );
    _actionHistory.add(action);

    notifyListeners();
    await _persistState();
  }

  Future<void> markPendingDelete(String mediaId) async {
    ReviewDecision? previous;
    if (_keptIds.contains(mediaId)) {
      previous = ReviewDecision.keep;
      _keptIds.remove(mediaId);
    }

    _pendingDeleteIds.add(mediaId);

    final action = ReviewAction(
      mediaId: mediaId,
      decision: ReviewDecision.pendingDelete,
      timestamp: DateTime.now(),
      previousDecision: previous,
    );
    _actionHistory.add(action);

    notifyListeners();
    await _persistState();
  }

  Future<ReviewAction?> undoLastAction() async {
    if (_actionHistory.isEmpty) return null;

    final lastAction = _actionHistory.removeLast();
    final id = lastAction.mediaId;

    if (lastAction.decision == ReviewDecision.keep) {
      _keptIds.remove(id);
      if (lastAction.previousDecision == ReviewDecision.pendingDelete) {
        _pendingDeleteIds.add(id);
      }
    } else {
      _pendingDeleteIds.remove(id);
      if (lastAction.previousDecision == ReviewDecision.keep) {
        _keptIds.add(id);
      }
    }

    notifyListeners();
    await _persistState();
    return lastAction;
  }

  Future<void> restoreItemFromPending(String mediaId) async {
    _pendingDeleteIds.remove(mediaId);
    _keptIds.add(mediaId);
    notifyListeners();
    await _persistState();
  }

  Future<void> removeDeletedIds(List<String> deletedIds) async {
    if (deletedIds.isEmpty) return;
    final deletedSet = deletedIds.toSet();
    _pendingDeleteIds.removeWhere((id) => deletedSet.contains(id));
    _keptIds.removeWhere((id) => deletedSet.contains(id));
    _actionHistory.removeWhere((action) => deletedSet.contains(action.mediaId));
    notifyListeners();
    await _persistState();
  }

  Future<void> resetAllReviews() async {
    _keptIds.clear();
    _pendingDeleteIds.clear();
    _actionHistory.clear();
    notifyListeners();
    await _prefsService.clearAllReviewData();
  }

  Future<void> _persistState() async {
    await _prefsService.saveKeptIds(_keptIds);
    await _prefsService.savePendingIds(_pendingDeleteIds);
    await _prefsService.saveActionHistory(_actionHistory);
  }

  // Testing helpers
  void setInitialState({
    Set<String>? kept,
    Set<String>? pending,
    List<ReviewAction>? history,
  }) {
    if (kept != null) _keptIds = Set.from(kept);
    if (pending != null) _pendingDeleteIds = Set.from(pending);
    if (history != null) _actionHistory = List.from(history);
    _isInitialized = true;
    notifyListeners();
  }
}
