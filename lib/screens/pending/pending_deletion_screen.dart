import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/lift_container.dart';
import '../../data/services/media_service.dart';
import '../../providers/deletion_provider.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/review_provider.dart';
import '../viewer/full_screen_viewer.dart';
import 'widgets/deletion_confirmation_dialog.dart';
import 'widgets/pending_item_tile.dart';

class PendingDeletionScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const PendingDeletionScreen({super.key, this.onNavigateToTab});

  @override
  State<PendingDeletionScreen> createState() => _PendingDeletionScreenState();
}

class _PendingDeletionScreenState extends State<PendingDeletionScreen> {
  final BaseMediaService _mediaService = DeviceMediaService();

  Future<void> _handleDeleteConfirmation(
    BuildContext context,
    DeletionProvider deletion,
    ReviewProvider review,
    GalleryProvider gallery,
    List selectedItems,
  ) async {
    final result = await deletion.executePlatformDeletion(
      itemsToDelete: selectedItems.cast(),
      mediaService: _mediaService,
      reviewProvider: review,
      galleryProvider: gallery,
    );

    if (!context.mounted) return;

    final colors = context.appColors;
    Color snackbarColor;
    IconData snackbarIcon;

    switch (result.status) {
      case DeletionExecutionStatus.success:
        snackbarColor = colors.keepColor;
        snackbarIcon = Icons.check_circle_rounded;
        break;
      case DeletionExecutionStatus.partial:
        snackbarColor = colors.warningColor;
        snackbarIcon = Icons.warning_rounded;
        break;
      case DeletionExecutionStatus.cancelled:
        snackbarColor = colors.subtleText;
        snackbarIcon = Icons.info_outline_rounded;
        break;
      case DeletionExecutionStatus.error:
      case DeletionExecutionStatus.inProgress:
      case DeletionExecutionStatus.idle:
        snackbarColor = colors.deleteColor;
        snackbarIcon = Icons.error_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(snackbarIcon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryProvider>();
    final review = context.watch<ReviewProvider>();
    final deletion = context.watch<DeletionProvider>();
    final colors = context.appColors;

    final pendingItems = deletion.getPendingItems(gallery.displayedItems, review.pendingDeleteIds);
    final selectedItems = deletion.getSelectedPendingItems(gallery.displayedItems, review.pendingDeleteIds);
    final sizeSummary = deletion.calculateSizeSummary(selectedItems);
    final formattedSize = deletion.formatSummarySize(sizeSummary);
    final allSelected = pendingItems.isNotEmpty && selectedItems.length == pendingItems.length;

    // Proactively resolve sizes for pending items if any metadata is unpopulated
    if (pendingItems.any((i) => i.size <= 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          gallery.ensureItemSizes(pendingItems);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Deletion'),
            Text(
              '${pendingItems.length} marked • ${selectedItems.length} selected',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: colors.subtleText),
            ),
          ],
        ),
        actions: [
          if (pendingItems.isNotEmpty)
            TextButton(
              onPressed: () {
                if (allSelected) {
                  deletion.deselectAll(pendingItems);
                } else {
                  deletion.selectAll();
                }
              },
              child: Text(allSelected ? 'Deselect All' : 'Select All'),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: pendingItems.isEmpty
          ? EmptyStateView(
              icon: Icons.delete_sweep_outlined,
              title: 'No Pending Deletions',
              description: 'Swipe left on photos and videos during review to place them here for safe storage cleanup.',
              actionLabel: 'Go to Review',
              onAction: () => widget.onNavigateToTab?.call(1),
            )
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.chipBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.deleteColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.cleaning_services_rounded, color: colors.deleteColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedItems.isEmpty
                                  ? 'No items selected'
                                  : (sizeSummary.allSizesUnknown
                                      ? 'Reclaim: Size calculating...'
                                      : 'Reclaim ~$formattedSize'),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedItems.isEmpty
                                  ? 'Select items below to reclaim space'
                                  : (sizeSummary.hasUnknownSizes
                                      ? '${selectedItems.length} of ${pendingItems.length} items selected (${sizeSummary.unknownCount} size pending)'
                                      : '${selectedItems.length} of ${pendingItems.length} items will be removed'),
                              style: TextStyle(color: colors.subtleText, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pending item list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pendingItems.length,
                    itemBuilder: (context, index) {
                      final item = pendingItems[index];
                      final isSelected = deletion.isSelected(item.id);

                      return PendingItemTile(
                        item: item,
                        isSelected: isSelected,
                        onToggleSelection: (_) => deletion.toggleSelection(item.id),
                        onRestore: () => review.restoreItemFromPending(item.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenViewer(
                                items: pendingItems,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom Action CTA
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: LiftContainer(
                        onTap: (selectedItems.isEmpty || deletion.isProcessing)
                            ? null
                            : () {
                                DeletionConfirmationDialog.show(
                                  context,
                                  fileCount: selectedItems.length,
                                  formattedSize: formattedSize,
                                  onConfirm: () => _handleDeleteConfirmation(
                                    context,
                                    deletion,
                                    review,
                                    gallery,
                                    selectedItems,
                                  ),
                                );
                              },
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.deleteColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: (selectedItems.isEmpty || deletion.isProcessing)
                              ? null
                              : () {
                                  DeletionConfirmationDialog.show(
                                    context,
                                    fileCount: selectedItems.length,
                                    formattedSize: formattedSize,
                                    onConfirm: () => _handleDeleteConfirmation(
                                      context,
                                      deletion,
                                      review,
                                      gallery,
                                      selectedItems,
                                    ),
                                  );
                                },
                          icon: deletion.isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.delete_forever_rounded, size: 20),
                          label: Text(
                            deletion.isProcessing
                                ? 'Deleting...'
                                : 'Delete Selected (${selectedItems.length} items)',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
