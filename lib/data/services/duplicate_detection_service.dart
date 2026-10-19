import '../models/media_item.dart';

class DuplicateGroup {
  final String key;
  final int sampleSize;
  final int width;
  final int height;
  final MediaItemType type;
  final List<MediaItem> items;

  const DuplicateGroup({
    required this.key,
    required this.sampleSize,
    required this.width,
    required this.height,
    required this.type,
    required this.items,
  });

  int get potentialSavings => sampleSize * (items.length - 1);
}

class DuplicateDetectionService {
  /// Scans indexed items and groups high-confidence exact duplicate candidates.
  /// Uses actual file size in bytes, width, height, media type, and video duration.
  /// Avoids reading full-resolution media into memory.
  static List<DuplicateGroup> findPotentialDuplicates(List<MediaItem> items) {
    final validItems = items.where((i) => i.size > 0 && i.width > 0 && i.height > 0).toList();
    final Map<String, List<MediaItem>> buckets = {};

    for (final item in validItems) {
      final durationSec = item.isVideo ? item.duration.inSeconds : 0;
      final key = '${item.type.name}_${item.size}_${item.width}x${item.height}_$durationSec';
      buckets.putIfAbsent(key, () => []).add(item);
    }

    final List<DuplicateGroup> duplicateGroups = [];
    for (final entry in buckets.entries) {
      if (entry.value.length > 1) {
        final first = entry.value.first;
        duplicateGroups.add(
          DuplicateGroup(
            key: entry.key,
            sampleSize: first.size,
            width: first.width,
            height: first.height,
            type: first.type,
            items: entry.value,
          ),
        );
      }
    }

    // Sort by largest potential savings first
    duplicateGroups.sort((a, b) => b.potentialSavings.compareTo(a.potentialSavings));
    return duplicateGroups;
  }
}
