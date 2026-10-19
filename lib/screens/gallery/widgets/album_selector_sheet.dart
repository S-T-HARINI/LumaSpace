import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';
import '../../../data/services/media_service.dart';

class AlbumSelectorSheet extends StatelessWidget {
  final List<MediaAlbum> albums;
  final MediaAlbum? selectedAlbum;
  final ValueChanged<MediaAlbum?> onSelect;

  const AlbumSelectorSheet({
    super.key,
    required this.albums,
    required this.selectedAlbum,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required List<MediaAlbum> albums,
    required MediaAlbum? selectedAlbum,
    required ValueChanged<MediaAlbum?> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AlbumSelectorSheet(
        albums: albums,
        selectedAlbum: selectedAlbum,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Album',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),
                // "All Media" default option
                LiftContainer(
                  onTap: () {
                    onSelect(null);
                    Navigator.pop(context);
                  },
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  color: selectedAlbum == null
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        color: selectedAlbum == null ? theme.colorScheme.primary : colors.subtleText,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'All Media',
                          style: TextStyle(
                            fontWeight: selectedAlbum == null ? FontWeight.w600 : FontWeight.w500,
                            color: selectedAlbum == null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (selectedAlbum == null)
                        Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20),
                    ],
                  ),
                ),
                const Divider(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      final isSelected = selectedAlbum?.id == album.id;

                      return LiftContainer(
                        onTap: () {
                          onSelect(album);
                          Navigator.pop(context);
                        },
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              color: isSelected ? theme.colorScheme.primary : colors.subtleText,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                album.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.chipBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${album.assetCount}',
                                style: TextStyle(
                                  color: colors.subtleText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
