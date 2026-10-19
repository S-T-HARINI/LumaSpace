import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_state_view.dart';
import '../../core/widgets/lift_container.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/services/media_service.dart';
import '../../data/services/mock_media_helper.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/review_provider.dart';
import '../viewer/full_screen_viewer.dart';
import 'widgets/album_selector_sheet.dart';
import 'widgets/gallery_filter_bar.dart';
import 'widgets/gallery_sort_sheet.dart';
import 'widgets/media_grid_tile.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      context.read<GalleryProvider>().loadMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryProvider>();
    final review = context.watch<ReviewProvider>();
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LumaSpace'),
            Text(
              '${gallery.selectedAlbum?.name ?? "All Media"} • ${gallery.displayedItems.length} items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: colors.subtleText,
              ),
            ),
          ],
        ),
        actions: [
          // Album selection
          LiftContainer(
            onTap: () {
              AlbumSelectorSheet.show(
                context,
                albums: gallery.albums,
                selectedAlbum: gallery.selectedAlbum,
                onSelect: (album) => gallery.selectAlbum(album),
              );
            },
            child: IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'Albums',
              onPressed: () {
                AlbumSelectorSheet.show(
                  context,
                  albums: gallery.albums,
                  selectedAlbum: gallery.selectedAlbum,
                  onSelect: (album) => gallery.selectAlbum(album),
                );
              },
            ),
          ),
          // Sort selection
          LiftContainer(
            onTap: () {
              GallerySortSheet.show(
                context,
                currentSort: gallery.sortOption,
                onSelect: (sort) => gallery.setSortOption(sort),
              );
            },
            child: IconButton(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort',
              onPressed: () {
                GallerySortSheet.show(
                  context,
                  currentSort: gallery.sortOption,
                  onSelect: (sort) => gallery.setSortOption(sort),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, gallery, review),
    );
  }

  Widget _buildBody(BuildContext context, GalleryProvider gallery, ReviewProvider review) {
    final colors = context.appColors;
    // Permission Handling
    if (!gallery.permissionStatus.hasAccess) {
      if (gallery.permissionStatus == AppPermissionStatus.denied ||
          gallery.permissionStatus == AppPermissionStatus.permanentlyDenied ||
          gallery.permissionStatus == AppPermissionStatus.restricted) {
        return _buildPermissionDeniedView(context, gallery);
      }
      return _buildPermissionRequestView(context, gallery);
    }

    if (gallery.isLoading && gallery.displayedItems.isEmpty) {
      return const LoadingView(message: 'Scanning device media...');
    }

    if (gallery.errorMessage != null && gallery.displayedItems.isEmpty) {
      return ErrorStateView(
        title: 'Unable to Load Gallery',
        message: gallery.errorMessage!,
        onRetry: () => gallery.loadMedia(refresh: true),
      );
    }

    if (gallery.displayedItems.isEmpty) {
      return Column(
        children: [
          GalleryFilterBar(
            selectedOption: gallery.filterOption,
            onSelect: (option) => gallery.setFilterOption(option),
          ),
          Expanded(
            child: EmptyStateView(
              icon: Icons.photo_library_outlined,
              title: 'No Media Found',
              description: gallery.filterOption == GalleryFilterOption.all
                  ? 'There are no photos or videos in this album.'
                  : 'No items match the "${gallery.filterOption.label}" filter.',
              actionLabel: 'Refresh Gallery',
              onAction: () => gallery.loadMedia(refresh: true),
            ),
          ),
        ],
      );
    }

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 5 : 3;

    return Column(
      children: [
        if (gallery.isMockMode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.warningColor.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.warningColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode (Mock data for browser inspection & UI testing)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => gallery.clearMockDemoData(),
                  child: const Text('Exit Demo'),
                ),
              ],
            ),
          ),
        GalleryFilterBar(
          selectedOption: gallery.filterOption,
          onSelect: (option) => gallery.setFilterOption(option),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => gallery.loadMedia(refresh: true),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: gallery.displayedItems.length + (gallery.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == gallery.displayedItems.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                }

                final item = gallery.displayedItems[index];
                return MediaGridTile(
                  item: item,
                  isKept: review.isKept(item.id),
                  isPending: review.isPendingDelete(item.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenViewer(
                          items: gallery.displayedItems,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRequestView(BuildContext context, GalleryProvider gallery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.perm_media_outlined,
                size: 40,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Your Media',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'LumaSpace needs permission to organize and review photos and videos stored on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.subtleText,
                height: 1.45,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => gallery.requestPermission(),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Grant Media Permission'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final mockItems = await MockMediaHelper.generateMockItems();
                gallery.setMockItems(mockItems);
              },
              icon: const Icon(Icons.preview_rounded, size: 18),
              label: const Text('Try Demo Mode (Mock Media)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context, GalleryProvider gallery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.appColors.deleteColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: context.appColors.deleteColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Media Access Denied',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'LumaSpace cannot show your photos without media permissions. Please open Settings and enable Photo & Video access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.subtleText,
                height: 1.45,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => gallery.openAppSettings(),
              icon: const Icon(Icons.settings_outlined, size: 20),
              label: const Text('Open App Settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final mockItems = await MockMediaHelper.generateMockItems();
                gallery.setMockItems(mockItems);
              },
              icon: const Icon(Icons.preview_rounded, size: 18),
              label: const Text('Try Demo Mode (Mock Media)'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => gallery.requestPermission(),
              child: const Text('Retry Request'),
            ),
          ],
        ),
      ),
    );
  }
}
