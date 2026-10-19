import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/lift_container.dart';
import '../../data/services/media_service.dart';
import '../../data/services/mock_media_helper.dart';
import '../../providers/deletion_provider.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/review_provider.dart';
import 'widgets/storage_overview_sheet.dart';
import 'widgets/theme_selector_sheet.dart';
import '../duplicates/duplicates_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final gallery = context.watch<GalleryProvider>();
    final review = context.watch<ReviewProvider>();
    final deletion = context.watch<DeletionProvider>();

    final theme = context.theme;
    final colors = context.appColors;

    final pendingItems = deletion.getPendingItems(gallery.displayedItems, review.pendingDeleteIds);
    final selectedPending = deletion.getSelectedPendingItems(gallery.displayedItems, review.pendingDeleteIds);
    final sizeSummary = deletion.calculateSizeSummary(selectedPending);
    final formattedSize = deletion.formatSummarySize(sizeSummary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Appearance
          _buildSectionHeader(context, 'Appearance'),
          LiftContainer(
            onTap: () => ThemeSelectorSheet.show(context),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(themeProvider.currentPreset.icon, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        themeProvider.currentPreset.label,
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.subtleText),
              ],
            ),
          ),

          // Section: Storage & Stats
          _buildSectionHeader(context, 'Media & Storage'),
          LiftContainer(
            onTap: () {
              StorageOverviewSheet.show(
                context,
                allItems: gallery.displayedItems,
                keptCount: review.keptCount,
                pendingCount: pendingItems.length,
                pendingBytes: sizeSummary.totalBytes,
                formattedPendingSize: formattedSize,
              );
            },
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.keepColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pie_chart_outline_rounded, color: colors.keepColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Storage Overview',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${gallery.displayedItems.length} media indexed • ~$formattedSize pending',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.subtleText),
              ],
            ),
          ),
          LiftContainer(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DuplicatesScreen()),
              );
            },
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.copy_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duplicate Media Review',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Find photos and videos with identical size & dimensions',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.subtleText),
              ],
            ),
          ),
          LiftContainer(
            onTap: () async {
              if (gallery.isMockMode) {
                gallery.clearMockDemoData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exited demo mode. Restored real media state.')),
                );
              } else {
                final mockItems = await MockMediaHelper.generateMockItems();
                if (!context.mounted) return;
                gallery.setMockItems(mockItems);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loaded 8 mock media items for UI testing & inspection.')),
                );
              }
            },
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.warningColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    gallery.isMockMode ? Icons.check_circle_outline : Icons.science_outlined,
                    color: colors.warningColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gallery.isMockMode ? 'Exit Demo / Mock Mode' : 'Browser Audit Demo Mode',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gallery.isMockMode
                            ? 'Currently displaying 8 labeled mock photos & videos'
                            : 'Load mock media to inspect gestures & UI in browser',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.subtleText),
              ],
            ),
          ),

          // Section: Review Session
          _buildSectionHeader(context, 'Review Session'),
          LiftContainer(
            onTap: review.canUndo
                ? () async {
                    final restored = await review.undoLastAction();
                    if (restored != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restored last reviewed item'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                : null,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: review.canUndo
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : colors.chipBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.undo_rounded,
                    color: review.canUndo ? theme.colorScheme.primary : colors.subtleText,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Undo Latest Action',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: review.canUndo ? theme.colorScheme.onSurface : colors.subtleText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.canUndo
                            ? '${review.actionHistory.length} review actions recorded'
                            : 'No actions to undo',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          LiftContainer(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Review Session?'),
                  content: const Text(
                    'This will clear all "Keep" and "Pending Deletion" markings. Your actual device photos will not be touched.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: colors.deleteColor),
                      onPressed: () {
                        review.resetAllReviews();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review session has been reset')),
                        );
                      },
                      child: const Text('Reset Session', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.deleteColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.refresh_rounded, color: colors.deleteColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reset Review Progress',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Clear all marked decisions and start fresh',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section: System & Permissions
          _buildSectionHeader(context, 'System & Platform'),
          LiftContainer(
            onTap: () => gallery.openAppSettings(),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            border: Border.all(color: colors.cardBorder),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.chipBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.security_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Permissions',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${_permissionStatusString(gallery.permissionStatus)}',
                        style: TextStyle(color: colors.subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, color: colors.subtleText, size: 20),
              ],
            ),
          ),

          // Section: About
          _buildSectionHeader(context, 'About'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LumaSpace',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'v1.0.0 • Mobile App Development',
                          style: TextStyle(color: colors.subtleText, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '"Your photos. Your memories. Your space."',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Built for GDG Tech Wildcard Entry. Features a swipe review engine, safe multi-step platform deletion workflow, 7 curated themes, and memory-efficient media indexing.',
                  style: TextStyle(color: colors.subtleText, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: context.appColors.subtleText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  String _permissionStatusString(AppPermissionStatus status) {
    switch (status) {
      case AppPermissionStatus.granted:
        return 'Granted (Full Access)';
      case AppPermissionStatus.limited:
        return 'Limited Access';
      case AppPermissionStatus.denied:
        return 'Denied';
      case AppPermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case AppPermissionStatus.restricted:
        return 'Restricted';
      case AppPermissionStatus.notDetermined:
        return 'Not Determined';
    }
  }
}
