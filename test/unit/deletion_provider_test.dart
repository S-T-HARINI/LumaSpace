import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/data/models/media_item.dart';
import 'package:lumaspace/data/services/media_service.dart';
import 'package:lumaspace/providers/deletion_provider.dart';
import 'package:lumaspace/providers/gallery_provider.dart';
import 'package:lumaspace/providers/review_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMediaService implements BaseMediaService {
  List<String> simulatedDeletedIds;

  MockMediaService({this.simulatedDeletedIds = const []});

  @override
  Future<AppPermissionStatus> checkPermission() async => AppPermissionStatus.granted;

  @override
  Future<List<String>> deleteMedia(List<String> ids) async => simulatedDeletedIds;

  @override
  Future<List<MediaAlbum>> getAlbums({RequestType type = RequestType.common}) async => [];

  @override
  Future<List<MediaItem>> getMediaItems({
    MediaAlbum? album,
    int page = 0,
    int pageSize = 60,
    RequestType type = RequestType.common,
  }) async => [];

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<AppPermissionStatus> requestPermission() async => AppPermissionStatus.granted;
}

void main() {
  group('DeletionProvider Tests', () {
    late DeletionProvider deletionProvider;
    late List<MediaItem> sampleItems;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      deletionProvider = DeletionProvider();
      sampleItems = [
        MediaItem(
          id: 'item_1',
          title: 'Photo 1',
          type: MediaItemType.image,
          size: 1024 * 1024 * 5, // 5 MB
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'item_2',
          title: 'Video 1',
          type: MediaItemType.video,
          size: 1024 * 1024 * 20, // 20 MB
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'item_3',
          title: 'Photo 2',
          type: MediaItemType.image,
          size: 1024 * 1024 * 2, // 2 MB
          createDateTime: DateTime.now(),
        ),
      ];
    });

    test('All items are selected by default', () {
      final pendingIds = {'item_1', 'item_2'};
      final selected = deletionProvider.getSelectedPendingItems(sampleItems, pendingIds);

      expect(selected.length, 2);
      expect(deletionProvider.isSelected('item_1'), true);
      expect(deletionProvider.isSelected('item_2'), true);
    });

    test('Deselection excludes item from selected list but preserves it', () {
      final pendingIds = {'item_1', 'item_2'};
      deletionProvider.toggleSelection('item_1');

      expect(deletionProvider.isSelected('item_1'), false);
      expect(deletionProvider.isSelected('item_2'), true);

      final selected = deletionProvider.getSelectedPendingItems(sampleItems, pendingIds);
      expect(selected.length, 1);
      expect(selected.first.id, 'item_2');

      // Toggling again re-selects it
      deletionProvider.toggleSelection('item_1');
      expect(deletionProvider.isSelected('item_1'), true);
    });

    test('Size calculation correctly sums selected bytes and updates immediately upon deselection', () {
      final pendingIds = {'item_1', 'item_2'};
      var selected = deletionProvider.getSelectedPendingItems(sampleItems, pendingIds);
      var total = deletionProvider.calculateTotalSize(selected);
      expect(total, 1024 * 1024 * 25); // 25 MB

      // Deselect item_1 (5 MB)
      deletionProvider.toggleSelection('item_1');
      selected = deletionProvider.getSelectedPendingItems(sampleItems, pendingIds);
      total = deletionProvider.calculateTotalSize(selected);
      expect(total, 1024 * 1024 * 20); // 20 MB
      expect(deletionProvider.formatBytes(total), '20.0 MB');
    });

    test('formatBytes correctly converts units across B, KB, MB, and GB', () {
      expect(deletionProvider.formatBytes(0), '0 B');
      expect(deletionProvider.formatBytes(-100), '0 B');
      expect(deletionProvider.formatBytes(512), '512 B');
      expect(deletionProvider.formatBytes(1024), '1.0 KB');
      expect(deletionProvider.formatBytes(1536), '1.5 KB');
      expect(deletionProvider.formatBytes(1024 * 1024), '1.0 MB');
      expect(deletionProvider.formatBytes(1024 * 1024 * 5 + 512 * 1024), '5.5 MB');
      expect(deletionProvider.formatBytes(1024 * 1024 * 1024), '1.00 GB');
      expect(deletionProvider.formatBytes((1024 * 1024 * 1024 * 2.35).round()), '2.35 GB');
    });

    test('calculateSizeSummary handles fully known, mixed, and unknown sizes gracefully', () {
      // 1. All known
      final summaryKnown = deletionProvider.calculateSizeSummary(sampleItems);
      expect(summaryKnown.totalBytes, 1024 * 1024 * 27);
      expect(summaryKnown.knownCount, 3);
      expect(summaryKnown.unknownCount, 0);
      expect(summaryKnown.hasUnknownSizes, false);
      expect(summaryKnown.allSizesUnknown, false);
      expect(deletionProvider.formatSummarySize(summaryKnown), '27.0 MB');

      // 2. Mixed: one item has size = 0
      final mixedItems = [
        sampleItems[0], // 5 MB
        MediaItem(
          id: 'item_missing_size',
          title: 'Photo with 0 size',
          type: MediaItemType.image,
          size: 0,
          createDateTime: DateTime.now(),
        ),
      ];
      final summaryMixed = deletionProvider.calculateSizeSummary(mixedItems);
      expect(summaryMixed.totalBytes, 1024 * 1024 * 5);
      expect(summaryMixed.knownCount, 1);
      expect(summaryMixed.unknownCount, 1);
      expect(summaryMixed.hasUnknownSizes, true);
      expect(summaryMixed.allSizesUnknown, false);
      expect(deletionProvider.formatSummarySize(summaryMixed), '5.0 MB+');

      // 3. All unknown
      final unknownItems = [
        MediaItem(
          id: 'item_zero_1',
          title: 'Photo 0',
          type: MediaItemType.image,
          size: 0,
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'item_zero_2',
          title: 'Video 0',
          type: MediaItemType.video,
          size: 0,
          createDateTime: DateTime.now(),
        ),
      ];
      final summaryUnknown = deletionProvider.calculateSizeSummary(unknownItems);
      expect(summaryUnknown.totalBytes, 0);
      expect(summaryUnknown.knownCount, 0);
      expect(summaryUnknown.unknownCount, 2);
      expect(summaryUnknown.allSizesUnknown, true);
      expect(deletionProvider.formatSummarySize(summaryUnknown), 'Unknown size');

      // 4. Empty list
      final summaryEmpty = deletionProvider.calculateSizeSummary([]);
      expect(summaryEmpty.isEmpty, true);
      expect(deletionProvider.formatSummarySize(summaryEmpty), '0 B');
    });

    test('Select All and Deselect All work properly', () {
      final pendingIds = {'item_1', 'item_2', 'item_3'};
      final pending = deletionProvider.getPendingItems(sampleItems, pendingIds);

      deletionProvider.deselectAll(pending);
      expect(deletionProvider.getSelectedCount(sampleItems, pendingIds), 0);

      deletionProvider.selectAll();
      expect(deletionProvider.getSelectedCount(sampleItems, pendingIds), 3);
    });

    test('Platform deletion handles successful complete removal', () async {
      final mockService = MockMediaService(simulatedDeletedIds: ['item_1', 'item_2']);
      final reviewProvider = ReviewProvider();
      reviewProvider.setInitialState(pending: {'item_1', 'item_2'});

      final galleryProvider = GalleryProvider(mockService);
      galleryProvider.setMockItems(sampleItems);

      final result = await deletionProvider.executePlatformDeletion(
        itemsToDelete: [sampleItems[0], sampleItems[1]],
        mediaService: mockService,
        reviewProvider: reviewProvider,
        galleryProvider: galleryProvider,
      );

      expect(result.status, DeletionExecutionStatus.success);
      expect(result.deletedCount, 2);
      expect(result.failedOrCancelledCount, 0);
      expect(reviewProvider.pendingCount, 0);
    });

    test('Platform deletion handles user cancellation without falsely deleting', () async {
      final mockService = MockMediaService(simulatedDeletedIds: []); // user cancelled in dialog
      final reviewProvider = ReviewProvider();
      reviewProvider.setInitialState(pending: {'item_1'});

      final galleryProvider = GalleryProvider(mockService);
      galleryProvider.setMockItems(sampleItems);

      final result = await deletionProvider.executePlatformDeletion(
        itemsToDelete: [sampleItems[0]],
        mediaService: mockService,
        reviewProvider: reviewProvider,
        galleryProvider: galleryProvider,
      );

      expect(result.status, DeletionExecutionStatus.cancelled);
      expect(result.deletedCount, 0);
      expect(result.failedOrCancelledCount, 1);
      // Item must remain in pending list!
      expect(reviewProvider.isPendingDelete('item_1'), true);
    });

    test('Platform deletion handles partial deletion reconciliation correctly', () async {
      // 2 items requested, only item_1 actually deleted by platform
      final mockService = MockMediaService(simulatedDeletedIds: ['item_1']);
      final reviewProvider = ReviewProvider();
      reviewProvider.setInitialState(pending: {'item_1', 'item_2'});

      final galleryProvider = GalleryProvider(mockService);
      galleryProvider.setMockItems(sampleItems);

      final result = await deletionProvider.executePlatformDeletion(
        itemsToDelete: [sampleItems[0], sampleItems[1]],
        mediaService: mockService,
        reviewProvider: reviewProvider,
        galleryProvider: galleryProvider,
      );

      expect(result.status, DeletionExecutionStatus.partial);
      expect(result.deletedCount, 1);
      expect(result.failedOrCancelledCount, 1);
      expect(reviewProvider.isPendingDelete('item_1'), false);
      expect(reviewProvider.isPendingDelete('item_2'), true);
    });
  });
}
