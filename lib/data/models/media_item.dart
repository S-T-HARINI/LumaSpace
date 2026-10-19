import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

enum MediaItemType {
  image,
  video;

  static MediaItemType fromAssetType(AssetType type) {
    if (type == AssetType.video) return MediaItemType.video;
    return MediaItemType.image;
  }
}

class MediaItem {
  final String id;
  final String title;
  final MediaItemType type;
  final int size; // in bytes
  final DateTime createDateTime;
  final Duration duration; // for videos
  final int width;
  final int height;
  final AssetEntity? asset;
  final Uint8List? preloadedThumbnail;
  final File? localFile;

  static final Map<String, Uint8List> _thumbnailMemoryCache = {};
  static const int _maxThumbnailCacheSize = 250;

  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.createDateTime,
    this.duration = Duration.zero,
    this.width = 0,
    this.height = 0,
    this.asset,
    this.preloadedThumbnail,
    this.localFile,
  });

  bool get isVideo => type == MediaItemType.video;
  bool get isImage => type == MediaItemType.image;

  MediaItem copyWith({
    String? id,
    String? title,
    MediaItemType? type,
    int? size,
    DateTime? createDateTime,
    Duration? duration,
    int? width,
    int? height,
    AssetEntity? asset,
    Uint8List? preloadedThumbnail,
    File? localFile,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      size: size ?? this.size,
      createDateTime: createDateTime ?? this.createDateTime,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      asset: asset ?? this.asset,
      preloadedThumbnail: preloadedThumbnail ?? this.preloadedThumbnail,
      localFile: localFile ?? this.localFile,
    );
  }

  /// Retrieve actual file size in bytes using platform metadata or origin file.
  /// Does not load media bytes into memory.
  Future<int> obtainActualSize() async {
    if (size > 0) return size;
    if (asset != null) {
      try {
        final queried = await asset!.fileSize;
        if (queried > 0) return queried;
      } catch (_) {}

      try {
        final f = await asset!.originFile ?? await asset!.file;
        if (f != null && await f.exists()) {
          final len = await f.length();
          if (len > 0) return len;
        }
      } catch (_) {}
    } else if (localFile != null) {
      try {
        if (await localFile!.exists()) {
          return await localFile!.length();
        }
      } catch (_) {}
    }
    return 0;
  }

  static Future<MediaItem> fromAsset(AssetEntity asset) async {
    // Fast metadata query first via platform cursor; fallback to file stat
    int fileSize = 0;
    try {
      fileSize = await asset.fileSize;
    } catch (_) {}

    if (fileSize <= 0) {
      try {
        final originFile = await asset.originFile ?? await asset.file;
        if (originFile != null && await originFile.exists()) {
          fileSize = await originFile.length();
        }
      } catch (_) {}
    }

    return MediaItem(
      id: asset.id,
      title: asset.title ?? 'Media_${asset.id.substring(0, asset.id.length.clamp(0, 8))}',
      type: MediaItemType.fromAssetType(asset.type),
      size: fileSize,
      createDateTime: asset.createDateTime,
      duration: asset.videoDuration,
      width: asset.width,
      height: asset.height,
      asset: asset,
    );
  }

  Future<Uint8List?> getThumbnail({int width = 256, int height = 256, int quality = 80}) async {
    if (preloadedThumbnail != null) return preloadedThumbnail;

    if (_thumbnailMemoryCache.containsKey(id)) {
      return _thumbnailMemoryCache[id];
    }

    if (asset != null) {
      try {
        final bytes = await asset!.thumbnailDataWithSize(
          ThumbnailSize(width, height),
          quality: quality,
        );
        if (bytes != null) {
          if (_thumbnailMemoryCache.length >= _maxThumbnailCacheSize) {
            _thumbnailMemoryCache.remove(_thumbnailMemoryCache.keys.first);
          }
          _thumbnailMemoryCache[id] = bytes;
          return bytes;
        }
      } catch (e) {
        debugPrint('Failed to load thumbnail for $id: $e');
      }
    }
    return null;
  }

  static void clearThumbnailCache() {
    _thumbnailMemoryCache.clear();
  }

  Future<File?> getFile() async {
    if (localFile != null) return localFile;
    if (asset != null) {
      try {
        return await asset!.file;
      } catch (e) {
        debugPrint('Failed to load file for $id: $e');
      }
    }
    return null;
  }

  String get formattedSize {
    if (size <= 0) return 'Unknown size';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDuration {
    if (!isVideo || duration == Duration.zero) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(createDateTime);
  }

  String get shortDate {
    return DateFormat('MMM d, yyyy').format(createDateTime);
  }

  String get monthYear {
    return DateFormat('MMMM yyyy').format(createDateTime);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
