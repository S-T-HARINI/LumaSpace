import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

enum GalleryGroupOption {
  none('None', 'Continuous media grid', Icons.grid_view_rounded),
  byDate('By Date', 'Group media by day', Icons.calendar_today_rounded),
  byMonth('By Month', 'Group media by month', Icons.calendar_view_month_rounded);

  final String label;
  final String description;
  final IconData icon;
  const GalleryGroupOption(this.label, this.description, this.icon);
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
  GalleryGroupOption _groupOption = GalleryGroupOption.none;
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
  GalleryGroupOption get groupOption => _groupOption;

  void setGroupOption(GalleryGroupOption option) {
    if (_groupOption == option) return;
    _groupOption = option;
    notifyListeners();
  }

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

  Map<String, List<MediaItem>> get groupedItems {
    final items = displayedItems;
    if (_groupOption == GalleryGroupOption.none) {
      return {'': items};
    }

    final Map<String, List<MediaItem>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      String key;
      if (item.createDateTime.year <= 1970) {
        key = 'Unknown Date';
      } else if (_groupOption == GalleryGroupOption.byMonth) {
        key = DateFormat('MMMM yyyy').format(item.createDateTime);
      } else {
        // By Date
        final itemDate = DateTime(
          item.createDateTime.year,
          item.createDateTime.month,
          item.createDateTime.day,
        );
        if (itemDate == today) {
          key = 'Today • ${DateFormat('d MMMM yyyy').format(item.createDateTime)}';
        } else if (itemDate == yesterday) {
          key = 'Yesterday • ${DateFormat('d MMMM yyyy').format(item.createDateTime)}';
        } else {
          key = DateFormat('d MMMM yyyy').format(item.createDateTime);
        }
      }

      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups;
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

  void updateItemSize(String id, int size) {
    final index = _rawItems.indexWhere((item) => item.id == id);
    if (index != -1 && _rawItems[index].size != size) {
      _rawItems[index] = _rawItems[index].copyWith(size: size);
      notifyListeners();
    }
  }

  Future<void> resolveItemSize(MediaItem item) async {
    if (item.size > 0) return;
    final actualSize = await item.obtainActualSize();
    if (actualSize > 0) {
      updateItemSize(item.id, actualSize);
    }
  }

  Future<void> ensureItemSizes(List<MediaItem> items) async {
    final missing = items.where((i) => i.size <= 0).toList();
    if (missing.isEmpty) return;

    bool updated = false;
    await Future.wait(
      missing.map((item) async {
        final actualSize = await item.obtainActualSize();
        if (actualSize > 0) {
          final idx = _rawItems.indexWhere((r) => r.id == item.id);
          if (idx != -1) {
            _rawItems[idx] = _rawItems[idx].copyWith(size: actualSize);
            updated = true;
          }
        }
      }),
    );

    if (updated) {
      notifyListeners();
    }
  }

  void clearMockDemoData() {
    _rawItems.clear();
    _isMockMode = false;
    loadMedia(refresh: true);
  }
}
