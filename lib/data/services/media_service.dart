import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/media_item.dart';

enum AppPermissionStatus {
  notDetermined,
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted;

  bool get hasAccess => this == AppPermissionStatus.granted || this == AppPermissionStatus.limited;
}

class MediaAlbum {
  final String id;
  final String name;
  final int assetCount;
  final AssetPathEntity? assetPath;

  const MediaAlbum({
    required this.id,
    required this.name,
    required this.assetCount,
    this.assetPath,
  });
}

abstract class BaseMediaService {
  Future<AppPermissionStatus> checkPermission();
  Future<AppPermissionStatus> requestPermission();
  Future<bool> openSettings();
  Future<List<MediaAlbum>> getAlbums({RequestType type = RequestType.common});
  Future<List<MediaItem>> getMediaItems({
    MediaAlbum? album,
    int page = 0,
    int pageSize = 60,
    RequestType type = RequestType.common,
  });
  Future<List<String>> deleteMedia(List<String> ids);
}

class DeviceMediaService implements BaseMediaService {
  @override
  Future<AppPermissionStatus> checkPermission() async {
    try {
      final state = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(),
      );
      return _mapPermissionState(state);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return AppPermissionStatus.denied;
    }
  }

  @override
  Future<AppPermissionStatus> requestPermission() async {
    try {
      final state = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(),
      );
      return _mapPermissionState(state);
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return AppPermissionStatus.denied;
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      await PhotoManager.openSetting();
      return true;
    } catch (e) {
      debugPrint('Error opening settings: $e');
      return false;
    }
  }

  @override
  Future<List<MediaAlbum>> getAlbums({RequestType type = RequestType.common}) async {
    try {
      final paths = await PhotoManager.getAssetPathList(
        type: type,
        hasAll: true,
      );

      final List<MediaAlbum> albums = [];
      for (final path in paths) {
        final count = await path.assetCountAsync;
        if (count > 0) {
          albums.add(
            MediaAlbum(
              id: path.id,
              name: path.name.isEmpty ? 'All Media' : path.name,
              assetCount: count,
              assetPath: path,
            ),
          );
        }
      }
      return albums;
    } catch (e) {
      debugPrint('Error fetching albums: $e');
      return [];
    }
  }

  @override
  Future<List<MediaItem>> getMediaItems({
    MediaAlbum? album,
    int page = 0,
    int pageSize = 60,
    RequestType type = RequestType.common,
  }) async {
    try {
      AssetPathEntity? targetPath = album?.assetPath;
      if (targetPath == null) {
        final paths = await PhotoManager.getAssetPathList(
          type: type,
          hasAll: true,
          onlyAll: true,
        );
        if (paths.isEmpty) return [];
        targetPath = paths.first;
      }

      final assets = await targetPath.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      final List<MediaItem> items = [];
      for (final asset in assets) {
        // Fast mapping with lazy size loading
        items.add(
          MediaItem(
            id: asset.id,
            title: asset.title ?? 'Media_${asset.id.substring(0, asset.id.length.clamp(0, 8))}',
            type: MediaItemType.fromAssetType(asset.type),
            size: 0, // calculated or fetched on demand to avoid blocking main isolate
            createDateTime: asset.createDateTime,
            duration: asset.videoDuration,
            width: asset.width,
            height: asset.height,
            asset: asset,
          ),
        );
      }
      return items;
    } catch (e) {
      debugPrint('Error fetching media items: $e');
      return [];
    }
  }

  @override
  Future<List<String>> deleteMedia(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      // PhotoManager.editor.deleteWithIds invokes Android Scoped Storage createDeleteRequest
      // or iOS PHPhotoLibrary deletion request.
      final deletedIds = await PhotoManager.editor.deleteWithIds(ids);
      return deletedIds;
    } catch (e) {
      debugPrint('Error executing platform deletion: $e');
      return [];
    }
  }

  AppPermissionStatus _mapPermissionState(PermissionState state) {
    switch (state) {
      case PermissionState.authorized:
        return AppPermissionStatus.granted;
      case PermissionState.limited:
        return AppPermissionStatus.limited;
      case PermissionState.denied:
        return AppPermissionStatus.denied;
      case PermissionState.restricted:
        return AppPermissionStatus.restricted;
      case PermissionState.notDetermined:
        return AppPermissionStatus.notDetermined;
    }
  }
}
