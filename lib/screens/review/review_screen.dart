import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/lift_container.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/review_provider.dart';
import '../viewer/full_screen_viewer.dart';
import '../viewer/widgets/metadata_sheet.dart';
import 'widgets/review_controls_bar.dart';
import 'widgets/swipe_card.dart';

class ReviewScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const ReviewScreen({super.key, this.onNavigateToTab});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final GlobalKey<SwipeCardState> _cardKey = GlobalKey<SwipeCardState>();

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryProvider>();
    final review = context.watch<ReviewProvider>();
    final theme = context.theme;
    final colors = context.appColors;

    final unreviewed = review.getUnreviewedItems(gallery.displayedItems);

    if (unreviewed.isNotEmpty && unreviewed.first.size <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          gallery.resolveItemSize(unreviewed.first);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Media'),
        actions: [
          if (review.canUndo)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              tooltip: 'Undo Last Action',
              onPressed: () async {
                final restored = await review.undoLastAction();
                if (restored != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restored ${restored.decision.name == "keep" ? "kept" : "deleted"} item to review queue'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar showing Kept, Pending, Remaining counts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.keepColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: colors.keepColor),
                        const SizedBox(width: 6),
                        Text(
                          '${review.keptCount} Kept',
                          style: TextStyle(
                            color: colors.keepColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.deleteColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 14, color: colors.deleteColor),
                        const SizedBox(width: 6),
                        Text(
                          '${review.pendingCount} Pending',
                          style: TextStyle(
                            color: colors.deleteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${unreviewed.length} remaining',
                    style: TextStyle(
                      color: colors.subtleText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Card stack area
            Expanded(
              child: unreviewed.isEmpty
                  ? _buildCompletedOrEmptyState(context, gallery, review)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Stack(
                        children: [
                          // Background card preview (if there is a next card)
                          if (unreviewed.length > 1)
                            Positioned.fill(
                              child: Transform.scale(
                                scale: 0.94,
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colors.cardBorder),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Top interactive card
                          Positioned.fill(
                            child: SwipeCard(
                              key: _cardKey,
                              item: unreviewed.first,
                              onSwipeRight: () => review.markKeep(unreviewed.first.id),
                              onSwipeLeft: () => review.markPendingDelete(unreviewed.first.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenViewer(
                                      items: unreviewed,
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Bottom action controls
            if (unreviewed.isNotEmpty)
              ReviewControlsBar(
                canUndo: review.canUndo,
                onUndo: () => review.undoLastAction(),
                onInfo: () => MetadataSheet.show(context, unreviewed.first),
                onPendingDelete: () => _cardKey.currentState?.swipeLeftManually(),
                onKeep: () => _cardKey.currentState?.swipeRightManually(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrEmptyState(
    BuildContext context,
    GalleryProvider gallery,
    ReviewProvider review,
  ) {
    if (gallery.displayedItems.isEmpty) {
      return EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: 'No Media Available',
        description: 'Grant media access or take photos to start reviewing your media.',
        actionLabel: 'Go to Gallery',
        onAction: () => widget.onNavigateToTab?.call(0),
      );
    }

    final theme = context.theme;
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.keepColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 44,
                color: colors.keepColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Review Complete!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'All ${gallery.displayedItems.length} items have been reviewed.\nYou have ${review.pendingCount} items marked for deletion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.subtleText,
                height: 1.45,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 24),
            if (review.pendingCount > 0)
              LiftContainer(
                onTap: () => widget.onNavigateToTab?.call(2),
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNavigateToTab?.call(2),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text('View Pending Deletions (${review.pendingCount})'),
                ),
              ),
            const SizedBox(height: 12),
            LiftContainer(
              onTap: () => review.resetAllReviews(),
              child: OutlinedButton.icon(
                onPressed: () => review.resetAllReviews(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Review Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
