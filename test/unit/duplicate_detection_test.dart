import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/data/models/media_item.dart';
import 'package:lumaspace/data/services/duplicate_detection_service.dart';

void main() {
  group('DuplicateDetectionService Tests', () {
    test('Identifies duplicate candidates with identical size, dimensions, and type', () {
      final items = [
        MediaItem(
          id: 'photo_1',
          title: 'IMG_001.jpg',
          type: MediaItemType.image,
          size: 1024 * 1024 * 3, // 3 MB
          width: 4000,
          height: 3000,
          createDateTime: DateTime(2026, 1, 1),
        ),
        MediaItem(
          id: 'photo_1_copy',
          title: 'IMG_001_copy.jpg',
          type: MediaItemType.image,
          size: 1024 * 1024 * 3, // 3 MB
          width: 4000,
          height: 3000,
          createDateTime: DateTime(2026, 1, 2),
        ),
        MediaItem(
          id: 'photo_distinct',
          title: 'IMG_002.jpg',
          type: MediaItemType.image,
          size: 1024 * 1024 * 4, // 4 MB
          width: 4000,
          height: 3000,
          createDateTime: DateTime(2026, 1, 3),
        ),
      ];

      final groups = DuplicateDetectionService.findPotentialDuplicates(items);
      expect(groups.length, 1);
      expect(groups.first.items.length, 2);
      expect(groups.first.sampleSize, 1024 * 1024 * 3);
      expect(groups.first.potentialSavings, 1024 * 1024 * 3);
      expect(groups.first.items.map((i) => i.id).toSet(), {'photo_1', 'photo_1_copy'});
    });

    test('Does not classify files with different sizes or dimensions as duplicates', () {
      final items = [
        MediaItem(
          id: 'p1',
          title: 'Photo A.jpg',
          type: MediaItemType.image,
          size: 1024 * 500,
          width: 1920,
          height: 1080,
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'p2',
          title: 'Photo B.jpg',
          type: MediaItemType.image,
          size: 1024 * 501, // 1 byte difference
          width: 1920,
          height: 1080,
          createDateTime: DateTime.now(),
        ),
      ];

      final groups = DuplicateDetectionService.findPotentialDuplicates(items);
      expect(groups.isEmpty, true);
    });

    test('Sorts groups by potential space savings descending', () {
      final items = [
        // Small duplicates (500 KB * 2 -> 500 KB savings)
        MediaItem(
          id: 'small_1',
          title: 'small_1.jpg',
          type: MediaItemType.image,
          size: 1024 * 500,
          width: 800,
          height: 600,
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'small_2',
          title: 'small_2.jpg',
          type: MediaItemType.image,
          size: 1024 * 500,
          width: 800,
          height: 600,
          createDateTime: DateTime.now(),
        ),
        // Large duplicates (20 MB * 2 -> 20 MB savings)
        MediaItem(
          id: 'large_1',
          title: 'large_1.mp4',
          type: MediaItemType.video,
          size: 1024 * 1024 * 20,
          width: 1920,
          height: 1080,
          duration: const Duration(seconds: 15),
          createDateTime: DateTime.now(),
        ),
        MediaItem(
          id: 'large_2',
          title: 'large_2.mp4',
          type: MediaItemType.video,
          size: 1024 * 1024 * 20,
          width: 1920,
          height: 1080,
          duration: const Duration(seconds: 15),
          createDateTime: DateTime.now(),
        ),
      ];

      final groups = DuplicateDetectionService.findPotentialDuplicates(items);
      expect(groups.length, 2);
      expect(groups.first.key.contains('large'), false);
      expect(groups.first.sampleSize, 1024 * 1024 * 20); // 20MB first
      expect(groups.last.sampleSize, 1024 * 500); // 500KB second
    });
  });
}
