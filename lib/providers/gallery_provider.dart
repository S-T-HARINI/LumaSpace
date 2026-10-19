import 'package:flutter/foundation.dart';
import '../data/models/media_item.dart';
import '../data/services/media_service.dart';

enum GallerySortOption {
  dateDesc('Newest First', 'Sort by creation date, newest first'),
  dateAsc('Oldest First', 'Sort by creation date, oldest first'),
  sizeDesc('Largest First', 'Sort by file size, largest first'),
  sizeAsc('Smallest First', 'Sort by file size, smallest first');

  final String label;
  final String description;
  const GallerySortOption(this.label, this.description);
}

enum GalleryFilterOption {
  all('All Media', null),
  photosOnly('Photos', MediaItemType.image),
  videosOnly('Videos', MediaItemType.video),
  largeFiles('Large Files (>10MB)', null);

  final String label;
  final MediaItemType? targetType;
  const GalleryFilterOption(this.label, this.targetType);
}

class GalleryProvider extends ChangeNotifier {
  final BaseMediaService _mediaService;

  GalleryProvider([BaseMediaService? mediaService])
      : _mediaService = mediaService ?? DeviceMediaService();

  AppPermissionStatus _permissionStatus = AppPermissionStatus.notDetermined;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  List<MediaItem> _rawItems = [];
  List<MediaAlbum> _albums = [];
  MediaAlbum? _selectedAlbum;

  GallerySortOption _sortOption = GallerySortOption.dateDesc;
  GalleryFilterOption _filterOption = GalleryFilterOption.all;
  int _currentPage = 0;
  static const int _pageSize = 80;

  // Getters
  AppPermissionStatus get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<MediaAlbum> get albums => _albums;
  MediaAlbum? get selectedAlbum => _selectedAlbum;
  GallerySortOption get sortOption => _sortOption;
  GalleryFilterOption get filterOption => _filterOption;

  List<MediaItem> get displayedItems {
    List<MediaItem> list = List.of(_rawItems);

    // Apply Filter
    switch (_filterOption) {
      case GalleryFilterOption.photosOnly:
        list = list.where((item) => item.type == MediaItemType.image).toList();
        break;
      case GalleryFilterOption.videosOnly:
        list = list.where((item) => item.type == MediaItemType.video).toList();
        break;
      case GalleryFilterOption.largeFiles:
        list = list.where((item) => item.size > 10 * 1024 * 1024).toList();
        break;
      case GalleryFilterOption.all:
        break;
    }

    // Apply Sort
    switch (_sortOption) {
      case GallerySortOption.dateDesc:
        list.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
        break;
      case GallerySortOption.dateAsc:
        list.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
        break;
      case GallerySortOption.sizeDesc:
        list.sort((a, b) => b.size.compareTo(a.size));
        break;
      case GallerySortOption.sizeAsc:
        list.sort((a, b) => a.size.compareTo(b.size));
        break;
    }

    return list;
  }

  int get totalItemCount => _rawItems.length;

  Future<void> initialize() async {
    _permissionStatus = await _mediaService.checkPermission();
    notifyListeners();

    if (_permissionStatus.hasAccess) {
      await loadMedia(refresh: true);
    }
  }

  Future<void> requestPermission() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _mediaService.requestPermission();
      if (_permissionStatus.hasAccess) {
        await loadMedia(refresh: true);
      } else {
        _errorMessage = 'Permission was denied. Please grant media access to browse your photos.';
      }
    } catch (e) {
      _errorMessage = 'Failed to request permission: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    await _mediaService.openSettings();
  }

  Future<void> loadMedia({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      if (refresh) {
        _albums = await _mediaService.getAlbums();
        if (_selectedAlbum != null && !_albums.any((a) => a.id == _selectedAlbum!.id)) {
          _selectedAlbum = null;
        }
      }

      final items = await _mediaService.getMediaItems(
        album: _selectedAlbum,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _rawItems = items;
      } else {
        // Avoid duplicate items
        final existingIds = _rawItems.map((e) => e.id).toSet();
        for (final item in items) {
          if (!existingIds.contains(item.id)) {
            _rawItems.add(item);
          }
        }
      }

      if (items.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = 'Failed to load media: $e';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void selectAlbum(MediaAlbum? album) {
    if (_selectedAlbum?.id == album?.id) return;
    _selectedAlbum = album;
    loadMedia(refresh: true);
  }

  void setSortOption(GallerySortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    notifyListeners();
  }

  void setFilterOption(GalleryFilterOption option) {
    if (_filterOption == option) return;
    _filterOption = option;
    notifyListeners();
  }

  void removeDeletedItems(List<String> deletedIds) {
    if (deletedIds.isEmpty) return;
    final idSet = deletedIds.toSet();
    _rawItems.removeWhere((item) => idSet.contains(item.id));
    notifyListeners();
  }

  bool _isMockMode = false;
  bool get isMockMode => _isMockMode;

  // Inject items for testing
  void setMockItems(List<MediaItem> items) {
    _rawItems = List.of(items);
    _permissionStatus = AppPermissionStatus.granted;
    _isLoading = false;
    _hasMore = false;
    _isMockMode = true;
    notifyListeners();
  }

  void clearMockDemoData() {
    _rawItems.clear();
    _isMockMode = false;
    loadMedia(refresh: true);
  }
}
