import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/data/models/media_item.dart';
import 'package:lumaspace/providers/gallery_provider.dart';

void main() {
  group('GalleryProvider Tests', () {
    late GalleryProvider galleryProvider;
    late List<MediaItem> sampleItems;

    setUp(() {
      galleryProvider = GalleryProvider();
      sampleItems = [
        MediaItem(
          id: 'item_old_small',
          title: 'Old Small Photo',
          type: MediaItemType.image,
          size: 1024 * 500, // 500 KB
          createDateTime: DateTime(2023, 1, 1),
        ),
        MediaItem(
          id: 'item_new_large',
          title: 'New Large Video',
          type: MediaItemType.video,
          size: 1024 * 1024 * 50, // 50 MB
          createDateTime: DateTime(2026, 1, 1),
        ),
        MediaItem(
          id: 'item_mid_medium',
          title: 'Mid Medium Photo',
          type: MediaItemType.image,
          size: 1024 * 1024 * 15, // 15 MB
          createDateTime: DateTime(2025, 1, 1),
        ),
      ];
      galleryProvider.setMockItems(sampleItems);
    });

    test('Initial sorting is Date Descending (Newest first)', () {
      final displayed = galleryProvider.displayedItems;
      expect(displayed.first.id, 'item_new_large');
      expect(displayed.last.id, 'item_old_small');
    });

    test('Sort by Date Ascending orders oldest first', () {
      galleryProvider.setSortOption(GallerySortOption.dateAsc);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.first.id, 'item_old_small');
      expect(displayed.last.id, 'item_new_large');
    });

    test('Sort by Size Descending orders largest first', () {
      galleryProvider.setSortOption(GallerySortOption.sizeDesc);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.first.id, 'item_new_large'); // 50MB
      expect(displayed[1].id, 'item_mid_medium'); // 15MB
      expect(displayed.last.id, 'item_old_small'); // 500KB
    });

    test('Sort by Size Ascending orders smallest first', () {
      galleryProvider.setSortOption(GallerySortOption.sizeAsc);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.first.id, 'item_old_small');
      expect(displayed.last.id, 'item_new_large');
    });

    test('Filter by Photos Only displays only images', () {
      galleryProvider.setFilterOption(GalleryFilterOption.photosOnly);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.length, 2);
      expect(displayed.every((i) => i.isImage), true);
    });

    test('Filter by Videos Only displays only videos', () {
      galleryProvider.setFilterOption(GalleryFilterOption.videosOnly);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.length, 1);
      expect(displayed.first.isVideo, true);
    });

    test('Filter by Large Files displays items > 10MB', () {
      galleryProvider.setFilterOption(GalleryFilterOption.largeFiles);
      final displayed = galleryProvider.displayedItems;

      expect(displayed.length, 2);
      expect(displayed.any((i) => i.id == 'item_old_small'), false);
    });
  });
}
