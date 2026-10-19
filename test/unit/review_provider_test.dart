import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/data/models/media_item.dart';
import 'package:lumaspace/data/models/review_action.dart';
import 'package:lumaspace/data/services/preferences_service.dart';
import 'package:lumaspace/providers/review_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReviewProvider Tests', () {
    late PreferencesService prefsService;
    late ReviewProvider reviewProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsService = PreferencesService(prefs);
      reviewProvider = ReviewProvider(prefsService);
      await reviewProvider.initialize();
    });

    test('Initial review state is empty', () {
      expect(reviewProvider.keptCount, 0);
      expect(reviewProvider.pendingCount, 0);
      expect(reviewProvider.canUndo, false);
      expect(reviewProvider.isInitialized, true);
    });

    test('Mark item as keep updates kept state and history', () async {
      await reviewProvider.markKeep('media_1');

      expect(reviewProvider.isKept('media_1'), true);
      expect(reviewProvider.isPendingDelete('media_1'), false);
      expect(reviewProvider.isReviewed('media_1'), true);
      expect(reviewProvider.keptCount, 1);
      expect(reviewProvider.canUndo, true);
      expect(reviewProvider.actionHistory.last.decision, ReviewDecision.keep);
    });

    test('Mark item as pending delete updates pending state and history', () async {
      await reviewProvider.markPendingDelete('media_2');

      expect(reviewProvider.isPendingDelete('media_2'), true);
      expect(reviewProvider.isKept('media_2'), false);
      expect(reviewProvider.isReviewed('media_2'), true);
      expect(reviewProvider.pendingCount, 1);
      expect(reviewProvider.canUndo, true);
      expect(reviewProvider.actionHistory.last.decision, ReviewDecision.pendingDelete);
    });

    test('Switching classification from keep to pending delete handles transition', () async {
      await reviewProvider.markKeep('media_1');
      expect(reviewProvider.isKept('media_1'), true);

      await reviewProvider.markPendingDelete('media_1');
      expect(reviewProvider.isKept('media_1'), false);
      expect(reviewProvider.isPendingDelete('media_1'), true);
      expect(reviewProvider.actionHistory.last.previousDecision, ReviewDecision.keep);
    });

    test('Undo restores previous state', () async {
      await reviewProvider.markKeep('media_1');
      expect(reviewProvider.isKept('media_1'), true);

      final undone = await reviewProvider.undoLastAction();
      expect(undone?.mediaId, 'media_1');
      expect(reviewProvider.isKept('media_1'), false);
      expect(reviewProvider.isReviewed('media_1'), false);
      expect(reviewProvider.canUndo, false);
    });

    test('Consecutive undos work correctly across multiple actions', () async {
      await reviewProvider.markKeep('media_1');
      await reviewProvider.markPendingDelete('media_2');
      await reviewProvider.markKeep('media_3');

      expect(reviewProvider.actionHistory.length, 3);

      // Undo media_3
      final undo3 = await reviewProvider.undoLastAction();
      expect(undo3?.mediaId, 'media_3');
      expect(reviewProvider.isReviewed('media_3'), false);

      // Undo media_2
      final undo2 = await reviewProvider.undoLastAction();
      expect(undo2?.mediaId, 'media_2');
      expect(reviewProvider.isReviewed('media_2'), false);

      // Undo media_1
      final undo1 = await reviewProvider.undoLastAction();
      expect(undo1?.mediaId, 'media_1');
      expect(reviewProvider.isReviewed('media_1'), false);
      expect(reviewProvider.canUndo, false);
    });

    test('Unreviewed items filtering excludes reviewed media', () {
      final items = [
        MediaItem(
          id: 'item_1',
          title: 'Photo 1',
          type: MediaItemType.image,
          size: 1024,
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'item_2',
          title: 'Photo 2',
          type: MediaItemType.image,
          size: 2048,
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'item_3',
          title: 'Video 1',
          type: MediaItemType.video,
          size: 8192,
          createDateTime: DateTime.now(),
        ),
      ];

      reviewProvider.markKeep('item_1');

      final unreviewed = reviewProvider.getUnreviewedItems(items);
      expect(unreviewed.length, 2);
      expect(unreviewed.any((i) => i.id == 'item_1'), false);
      expect(unreviewed.any((i) => i.id == 'item_2'), true);
      expect(unreviewed.any((i) => i.id == 'item_3'), true);
    });

    test('Restore from pending moves item to kept state', () async {
      await reviewProvider.markPendingDelete('item_1');
      expect(reviewProvider.isPendingDelete('item_1'), true);

      await reviewProvider.restoreItemFromPending('item_1');
      expect(reviewProvider.isPendingDelete('item_1'), false);
      expect(reviewProvider.isKept('item_1'), true);
    });

    test('Reset all reviews clears all lists and history', () async {
      await reviewProvider.markKeep('item_1');
      await reviewProvider.markPendingDelete('item_2');

      await reviewProvider.resetAllReviews();

      expect(reviewProvider.keptCount, 0);
      expect(reviewProvider.pendingCount, 0);
      expect(reviewProvider.canUndo, false);
    });
  });
}
