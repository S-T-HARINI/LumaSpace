import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';

class SwipeCard extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onSwipeRight; // Keep
  final VoidCallback onSwipeLeft; // Pending Delete
  final VoidCallback onTap;

  const SwipeCard({
    super.key,
    required this.item,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onTap,
  });

  @override
  State<SwipeCard> createState() => SwipeCardState();
}

class SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Offset _dragOffset = Offset.zero;
  bool _hasTriggeredHaptic = false;
  Uint8List? _imageBytes;
  bool _isLoading = true;

  static const double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _dragOffset = Offset.zero;
      _loadImage();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    // Request higher resolution thumbnail for swipe card
    final bytes = await widget.item.getThumbnail(width: 800, height: 800, quality: 85);
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    }
  }

  void swipeRightManually() {
    _animateCardOff(const Offset(500, 50), widget.onSwipeRight);
  }

  void swipeLeftManually() {
    _animateCardOff(const Offset(-500, 50), widget.onSwipeLeft);
  }

  void _animateCardOff(Offset target, VoidCallback onCompleted) {
    final startOffset = _dragOffset;
    final anim = Tween<Offset>(begin: startOffset, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.reset();
    void listener() {
      setState(() {
        _dragOffset = anim.value;
      });
    }

    anim.addListener(listener);
    _animController.forward().then((_) {
      anim.removeListener(listener);
      _dragOffset = Offset.zero;
      onCompleted();
    });
  }

  void _animateBackToCenter() {
    final startOffset = _dragOffset;
    final anim = Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.reset();
    void listener() {
      setState(() {
        _dragOffset = anim.value;
      });
    }

    anim.addListener(listener);
    _animController.forward().then((_) {
      anim.removeListener(listener);
      _hasTriggeredHaptic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = context.theme;
    final size = MediaQuery.of(context).size;

    final dx = _dragOffset.dx;
    final rotation = (dx / size.width) * (math.pi / 14);

    final keepProgress = (dx / _swipeThreshold).clamp(0.0, 1.0);
    final deleteProgress = (-dx / _swipeThreshold).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _dragOffset,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: (details) {
            setState(() {
              _dragOffset += details.delta;
            });

            if (_dragOffset.dx.abs() > _swipeThreshold && !_hasTriggeredHaptic) {
              HapticFeedback.mediumImpact();
              _hasTriggeredHaptic = true;
            } else if (_dragOffset.dx.abs() <= _swipeThreshold) {
              _hasTriggeredHaptic = false;
            }
          },
          onPanEnd: (details) {
            if (_dragOffset.dx > _swipeThreshold) {
              _animateCardOff(Offset(size.width * 1.5, _dragOffset.dy), widget.onSwipeRight);
            } else if (_dragOffset.dx < -_swipeThreshold) {
              _animateCardOff(Offset(-size.width * 1.5, _dragOffset.dy), widget.onSwipeLeft);
            } else {
              _animateBackToCenter();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: colors.cardBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Display
                  _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : (_isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                              ),
                            )
                          : _buildPlaceholder()),

                  // Gradient scrim at bottom for text contrast
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 40, 18, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.82),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.item.isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                widget.item.shortDate,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              if (widget.item.size > 0) ...[
                                const Text(' • ', style: TextStyle(color: Colors.white54)),
                                Text(
                                  widget.item.formattedSize,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                              if (widget.item.isVideo && widget.item.formattedDuration.isNotEmpty) ...[
                                const Text(' • ', style: TextStyle(color: Colors.white54)),
                                Text(
                                  widget.item.formattedDuration,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // "KEEP" Overlay badge (when dragging right)
                  if (keepProgress > 0)
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Opacity(
                        opacity: keepProgress,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.keepColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'KEEP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // "DELETE" Overlay badge (when dragging left)
                  if (deleteProgress > 0)
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Opacity(
                        opacity: deleteProgress,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.deleteColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'DELETE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        widget.item.isVideo ? Icons.videocam : Icons.photo,
        size: 54,
        color: Colors.grey.withValues(alpha: 0.4),
      ),
    );
  }
}
