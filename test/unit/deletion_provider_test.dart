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

    test('Size calculation correctly sums selected bytes', () {
      final total = deletionProvider.calculateTotalSize(sampleItems);
      expect(total, 1024 * 1024 * 27); // 27 MB

      final formatted = deletionProvider.formatBytes(total);
      expect(formatted, '27.0 MB');
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
  });
}
