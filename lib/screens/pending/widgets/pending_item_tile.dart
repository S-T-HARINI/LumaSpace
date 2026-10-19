import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';
import '../../../data/models/media_item.dart';

class PendingItemTile extends StatefulWidget {
  final MediaItem item;
  final bool isSelected;
  final ValueChanged<bool?> onToggleSelection;
  final VoidCallback onRestore;
  final VoidCallback onTap;

  const PendingItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onRestore,
    required this.onTap,
  });

  @override
  State<PendingItemTile> createState() => _PendingItemTileState();
}

class _PendingItemTileState extends State<PendingItemTile> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant PendingItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    setState(() => _isLoading = true);
    final bytes = await widget.item.getThumbnail(width: 160, height: 160, quality: 75);
    if (mounted) {
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = context.theme;

    return LiftContainer(
      onTap: widget.onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(14),
      color: theme.cardColor,
      border: Border.all(
        color: widget.isSelected ? colors.deleteColor.withValues(alpha: 0.4) : colors.cardBorder,
        width: widget.isSelected ? 1.5 : 1,
      ),
      child: Row(
        children: [
          // Checkbox for deletion selection
          Checkbox(
            value: widget.isSelected,
            activeColor: colors.deleteColor,
            onChanged: widget.onToggleSelection,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),

          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 58,
              child: _thumbnailBytes != null
                  ? Image.memory(
                      _thumbnailBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : (_isLoading
                      ? Container(color: colors.chipBackground)
                      : _buildPlaceholder()),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.item.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                      size: 15,
                      color: colors.subtleText,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.item.shortDate}${widget.item.size > 0 ? " • ${widget.item.formattedSize}" : ""}',
                  style: TextStyle(
                    color: colors.subtleText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Restore button (Keep)
          LiftContainer(
            onTap: widget.onRestore,
            scaleFactor: 0.92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.keepColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.keepColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.undo_rounded, size: 14, color: colors.keepColor),
                  const SizedBox(width: 4),
                  Text(
                    'Keep',
                    style: TextStyle(
                      color: colors.keepColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.withValues(alpha: 0.2),
      child: Icon(
        widget.item.isVideo ? Icons.videocam : Icons.photo,
        size: 24,
        color: Colors.grey,
      ),
    );
  }
}
