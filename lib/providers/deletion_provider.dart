import 'package:flutter/foundation.dart';
import '../data/models/media_item.dart';
import '../data/services/media_service.dart';
import 'gallery_provider.dart';
import 'review_provider.dart';

enum DeletionExecutionStatus {
  idle,
  inProgress,
  success,
  partial,
  cancelled,
  error;
}

class DeletionResult {
  final DeletionExecutionStatus status;
  final int requestedCount;
  final int deletedCount;
  final int failedOrCancelledCount;
  final String message;

  const DeletionResult({
    required this.status,
    required this.requestedCount,
    required this.deletedCount,
    required this.failedOrCancelledCount,
    required this.message,
  });
}

class DeletionSizeSummary {
  final int totalBytes;
  final int knownCount;
  final int unknownCount;
  final int totalCount;

  const DeletionSizeSummary({
    required this.totalBytes,
    required this.knownCount,
    required this.unknownCount,
    required this.totalCount,
  });

  bool get hasUnknownSizes => unknownCount > 0;
  bool get allSizesUnknown => unknownCount == totalCount && totalCount > 0;
  bool get isEmpty => totalCount == 0;
}

class DeletionProvider extends ChangeNotifier {
  final Set<String> _deselectedIds = {};
  bool _isProcessing = false;

  Set<String> get deselectedIds => Set.unmodifiable(_deselectedIds);
  bool get isProcessing => _isProcessing;

  bool isSelected(String id) => !_deselectedIds.contains(id);

  void toggleSelection(String id) {
    if (_deselectedIds.contains(id)) {
      _deselectedIds.remove(id);
    } else {
      _deselectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _deselectedIds.clear();
    notifyListeners();
  }

  void deselectAll(List<MediaItem> pendingItems) {
    for (final item in pendingItems) {
      _deselectedIds.add(item.id);
    }
    notifyListeners();
  }

  List<MediaItem> getPendingItems(List<MediaItem> allItems, Set<String> pendingIds) {
    return allItems.where((item) => pendingIds.contains(item.id)).toList();
  }

  List<MediaItem> getSelectedPendingItems(List<MediaItem> allItems, Set<String> pendingIds) {
    return allItems
        .where((item) => pendingIds.contains(item.id) && !_deselectedIds.contains(item.id))
        .toList();
  }

  int getSelectedCount(List<MediaItem> allItems, Set<String> pendingIds) {
    return getSelectedPendingItems(allItems, pendingIds).length;
  }

  DeletionSizeSummary calculateSizeSummary(List<MediaItem> items) {
    int totalBytes = 0;
    int knownCount = 0;
    int unknownCount = 0;

    for (final item in items) {
      if (item.size > 0) {
        totalBytes += item.size;
        knownCount++;
      } else {
        unknownCount++;
      }
    }

    return DeletionSizeSummary(
      totalBytes: totalBytes,
      knownCount: knownCount,
      unknownCount: unknownCount,
      totalCount: items.length,
    );
  }

  String formatSummarySize(DeletionSizeSummary summary) {
    if (summary.isEmpty) return '0 B';
    if (summary.allSizesUnknown) return 'Unknown size';
    final formatted = formatBytes(summary.totalBytes);
    if (summary.hasUnknownSizes) {
      return '$formatted+';
    }
    return formatted;
  }

  int calculateTotalSize(List<MediaItem> items) {
    int total = 0;
    for (final item in items) {
      if (item.size > 0) {
        total += item.size;
      }
    }
    return total;
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<DeletionResult> executePlatformDeletion({
    required List<MediaItem> itemsToDelete,
    required BaseMediaService mediaService,
    required ReviewProvider reviewProvider,
    required GalleryProvider galleryProvider,
  }) async {
    if (_isProcessing) {
      return const DeletionResult(
        status: DeletionExecutionStatus.inProgress,
        requestedCount: 0,
        deletedCount: 0,
        failedOrCancelledCount: 0,
        message: 'A deletion operation is already in progress.',
      );
    }

    if (itemsToDelete.isEmpty) {
      return const DeletionResult(
        status: DeletionExecutionStatus.idle,
        requestedCount: 0,
        deletedCount: 0,
        failedOrCancelledCount: 0,
        message: 'No items selected for deletion.',
      );
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final idsToDelete = itemsToDelete.map((e) => e.id).toList();
      // Invoke platform deletion: triggers Android MediaStore delete dialog or iOS photo dialog
      final deletedIds = await mediaService.deleteMedia(idsToDelete);

      final requested = idsToDelete.length;
      final deleted = deletedIds.length;
      final remaining = requested - deleted;

      // Reconcile application state ONLY based on what platform actually deleted!
      if (deleted > 0) {
        await reviewProvider.removeDeletedIds(deletedIds);
        galleryProvider.removeDeletedItems(deletedIds);
        _deselectedIds.removeWhere((id) => deletedIds.contains(id));
      }

      if (deleted == requested) {
        return DeletionResult(
          status: DeletionExecutionStatus.success,
          requestedCount: requested,
          deletedCount: deleted,
          failedOrCancelledCount: 0,
          message: 'Successfully reclaimed space for $deleted ${deleted == 1 ? "item" : "items"}.',
        );
      } else if (deleted > 0) {
        return DeletionResult(
          status: DeletionExecutionStatus.partial,
          requestedCount: requested,
          deletedCount: deleted,
          failedOrCancelledCount: remaining,
          message: 'Partially completed: $deleted deleted, $remaining kept or cancelled.',
        );
      } else {
        return DeletionResult(
          status: DeletionExecutionStatus.cancelled,
          requestedCount: requested,
          deletedCount: 0,
          failedOrCancelledCount: requested,
          message: 'Deletion was cancelled or denied by the system. No files were removed.',
        );
      }
    } catch (e) {
      return DeletionResult(
        status: DeletionExecutionStatus.error,
        requestedCount: itemsToDelete.length,
        deletedCount: 0,
        failedOrCancelledCount: itemsToDelete.length,
        message: 'Deletion failed: $e',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
