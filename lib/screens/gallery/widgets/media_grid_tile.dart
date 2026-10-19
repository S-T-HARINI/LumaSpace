import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';
import '../../../data/models/media_item.dart';

class MediaGridTile extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final bool isKept;
  final bool isPending;

  const MediaGridTile({
    super.key,
    required this.item,
    required this.onTap,
    this.isKept = false,
    this.isPending = false,
  });

  @override
  State<MediaGridTile> createState() => _MediaGridTileState();
}

class _MediaGridTileState extends State<MediaGridTile> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant MediaGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final bytes = await widget.item.getThumbnail(width: 256, height: 256, quality: 75);
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

    return LiftContainer(
      onTap: widget.onTap,
      scaleFactor: 0.96,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail / Background
            Container(
              color: colors.chipBackground,
              child: _thumbnailBytes != null
                  ? Image.memory(
                      _thumbnailBytes!,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(Icons.broken_image_outlined),
                    )
                  : (_isLoading
                      ? Container(color: colors.chipBackground)
                      : _buildPlaceholder(widget.item.isVideo ? Icons.videocam_outlined : Icons.image_outlined)),
            ),

            // Video indicator with duration
            if (widget.item.isVideo)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                      if (widget.item.formattedDuration.isNotEmpty) ...[
                        const SizedBox(width: 2),
                        Text(
                          widget.item.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Review status tag (if already reviewed)
            if (widget.isPending)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.deleteColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 12),
                ),
              )
            else if (widget.isKept)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.keepColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 26,
        color: Colors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}
