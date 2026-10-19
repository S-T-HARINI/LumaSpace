import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';

class StorageOverviewSheet extends StatelessWidget {
  final List<MediaItem> allItems;
  final int keptCount;
  final int pendingCount;
  final int pendingBytes;
  final String formattedPendingSize;

  const StorageOverviewSheet({
    super.key,
    required this.allItems,
    required this.keptCount,
    required this.pendingCount,
    required this.pendingBytes,
    required this.formattedPendingSize,
  });

  static Future<void> show(
    BuildContext context, {
    required List<MediaItem> allItems,
    required int keptCount,
    required int pendingCount,
    required int pendingBytes,
    required String formattedPendingSize,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => StorageOverviewSheet(
        allItems: allItems,
        keptCount: keptCount,
        pendingCount: pendingCount,
        pendingBytes: pendingBytes,
        formattedPendingSize: formattedPendingSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final photoCount = allItems.where((i) => i.isImage).length;
    final videoCount = allItems.where((i) => i.isVideo).length;
    final totalIndexedBytes = allItems.fold<int>(0, (sum, i) => sum + (i.size > 0 ? i.size : 0));
    final unknownSizeCount = allItems.where((i) => i.size <= 0).length;
    final formattedIndexedSize = totalIndexedBytes > 0
        ? '~${_formatBytes(totalIndexedBytes)}${unknownSizeCount > 0 ? " (est.)" : ""}'
        : (unknownSizeCount == allItems.length && allItems.isNotEmpty ? 'Metadata pending' : '0 B');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_outline_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Media Library Storage Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatTile(
              context,
              icon: Icons.photo_library_rounded,
              label: 'Total Indexed Media',
              value: '${allItems.length} files ($formattedIndexedSize)',
            ),
            _buildStatTile(
              context,
              icon: Icons.image_rounded,
              label: 'Indexed Photos',
              value: '$photoCount images',
            ),
            _buildStatTile(
              context,
              icon: Icons.videocam_rounded,
              label: 'Indexed Videos',
              value: '$videoCount videos',
            ),
            _buildStatTile(
              context,
              icon: Icons.check_circle_outline,
              label: 'Kept in Library',
              value: '$keptCount items',
              color: colors.keepColor,
            ),
            _buildStatTile(
              context,
              icon: Icons.delete_outline_rounded,
              label: 'Marked for Deletion',
              value: '$pendingCount items',
              color: colors.deleteColor,
            ),
            _buildStatTile(
              context,
              icon: Icons.cleaning_services_rounded,
              label: 'Potential Space Savings',
              value: '~$formattedPendingSize',
              color: colors.deleteColor,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.chipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colors.subtleText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sizes reflect photos and videos indexed from device storage, not total disk capacity. Space is safely reclaimed only after platform system confirmation.',
                      style: TextStyle(color: colors.subtleText, fontSize: 11.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final theme = context.theme;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? colors.subtleText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.subtleText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
