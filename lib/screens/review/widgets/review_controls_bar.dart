import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';

class ReviewControlsBar extends StatelessWidget {
  final VoidCallback onKeep;
  final VoidCallback onPendingDelete;
  final VoidCallback? onUndo;
  final VoidCallback onInfo;
  final bool canUndo;

  const ReviewControlsBar({
    super.key,
    required this.onKeep,
    required this.onPendingDelete,
    this.onUndo,
    required this.onInfo,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo Button
          LiftContainer(
            onTap: canUndo ? onUndo : null,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: canUndo ? colors.chipBackground : colors.chipBackground.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: canUndo ? colors.cardBorder : Colors.transparent,
                ),
              ),
              child: Icon(
                Icons.undo_rounded,
                color: canUndo ? theme.colorScheme.onSurface : colors.subtleText.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
          ),

          // Delete Button (Swipe Left action)
          LiftContainer(
            onTap: onPendingDelete,
            scaleFactor: 0.92,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.deleteColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.deleteColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: colors.deleteColor,
                size: 30,
              ),
            ),
          ),

          // Info Button
          LiftContainer(
            onTap: onInfo,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.chipBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
            ),
          ),

          // Keep Button (Swipe Right action)
          LiftContainer(
            onTap: onKeep,
            scaleFactor: 0.92,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.keepColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.keepColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: colors.keepColor,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
