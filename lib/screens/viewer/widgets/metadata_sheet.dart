import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';

class MetadataSheet extends StatelessWidget {
  final MediaItem item;

  const MetadataSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, MediaItem item) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => MetadataSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Name', item.title, Icons.title_rounded),
            _buildDetailRow(context, 'Date', item.formattedDate, Icons.calendar_today_outlined),
            _buildDetailRow(context, 'Type', item.isVideo ? 'Video' : 'Photo', Icons.category_outlined),
            if (item.size > 0)
              _buildDetailRow(context, 'Size', item.formattedSize, Icons.data_usage_rounded),
            if (item.width > 0 && item.height > 0)
              _buildDetailRow(context, 'Dimensions', '${item.width} × ${item.height} px', Icons.aspect_ratio_rounded),
            if (item.isVideo && item.formattedDuration.isNotEmpty)
              _buildDetailRow(context, 'Duration', item.formattedDuration, Icons.timelapse_rounded),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    final colors = context.appColors;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.subtleText),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: colors.subtleText,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
