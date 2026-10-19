import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/lift_container.dart';
import '../../data/services/duplicate_detection_service.dart';
import '../../providers/deletion_provider.dart';
import '../../providers/gallery_provider.dart';
import '../../providers/review_provider.dart';
import '../viewer/full_screen_viewer.dart';

class DuplicatesScreen extends StatefulWidget {
  const DuplicatesScreen({super.key});

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {
  final Set<String> _selectedForPending = {};
  List<DuplicateGroup> _duplicateGroups = [];
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanDuplicates();
    });
  }

  void _scanDuplicates() {
    final gallery = context.read<GalleryProvider>();
    final groups = DuplicateDetectionService.findPotentialDuplicates(gallery.displayedItems);
    setState(() {
      _duplicateGroups = groups;
      _isScanning = false;
      // By default, leave the oldest/first copy untouched and recommend younger duplicates
      for (final group in groups) {
        for (int i = 1; i < group.items.length; i++) {
          _selectedForPending.add(group.items[i].id);
        }
      }
    });
  }

  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedForPending.contains(id)) {
        _selectedForPending.remove(id);
      } else {
        _selectedForPending.add(id);
      }
    });
  }

  Future<void> _stageSelectedForDeletion(
    BuildContext context,
    ReviewProvider review,
    DeletionProvider deletion,
  ) async {
    if (_selectedForPending.isEmpty) return;

    for (final id in _selectedForPending) {
      await review.markPendingDelete(id);
    }

    if (!context.mounted) return;

    final count = _selectedForPending.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.appColors.deleteColor,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count ${count == 1 ? "duplicate" : "duplicates"} moved to Pending Deletion queue.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;
    final review = context.watch<ReviewProvider>();
    final deletion = context.watch<DeletionProvider>();

    int totalSavings = 0;
    for (final group in _duplicateGroups) {
      final selectedInGroup = group.items.where((i) => _selectedForPending.contains(i.id)).length;
      totalSavings += group.sampleSize * selectedInGroup;
    }
    final formattedSavings = deletion.formatBytes(totalSavings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Candidates'),
        actions: [
          if (_duplicateGroups.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedForPending.isEmpty) {
                    for (final group in _duplicateGroups) {
                      for (int i = 1; i < group.items.length; i++) {
                        _selectedForPending.add(group.items[i].id);
                      }
                    }
                  } else {
                    _selectedForPending.clear();
                  }
                });
              },
              child: Text(_selectedForPending.isEmpty ? 'Select Suggested' : 'Clear All'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning media library for identical files...'),
                ],
              ),
            )
          : _duplicateGroups.isEmpty
              ? const EmptyStateView(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'No Duplicates Detected',
                  description: 'All indexed photos and videos appear to be unique. No duplicate candidates found.',
                )
              : Column(
                  children: [
                    // Overview Banner
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
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.copy_rounded, color: theme.colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_duplicateGroups.length} Duplicate Sets Found',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Potential savings: ~$formattedSavings by staging unwanted copies',
                                  style: TextStyle(color: colors.subtleText, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Duplicate Groups List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _duplicateGroups.length,
                        itemBuilder: (context, groupIndex) {
                          final group = _duplicateGroups[groupIndex];
                          return _buildGroupCard(context, group, groupIndex + 1);
                        },
                      ),
                    ),

                    // Bottom Action Bar
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: LiftContainer(
                            onTap: _selectedForPending.isEmpty
                                ? null
                                : () => _stageSelectedForDeletion(context, review, deletion),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.deleteColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _selectedForPending.isEmpty
                                  ? null
                                  : () => _stageSelectedForDeletion(context, review, deletion),
                              icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                              label: Text(
                                'Stage ${_selectedForPending.length} for Deletion (~$formattedSavings)',
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

  Widget _buildGroupCard(BuildContext context, DuplicateGroup group, int setNumber) {
    final theme = context.theme;
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Candidate Set #$setNumber',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${group.items.length} copies • ${group.items.first.formattedSize}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.subtleText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...group.items.map((item) {
            final isSelected = _selectedForPending.contains(item.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? colors.deleteColor.withValues(alpha: 0.06) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? colors.deleteColor.withValues(alpha: 0.3) : colors.cardBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: colors.deleteColor,
                    onChanged: (_) => _toggleItemSelection(item.id),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenViewer(
                            items: group.items,
                            initialIndex: group.items.indexOf(item),
                          ),
                        ),
                      );
                    },
                    child: FutureBuilder(
                      future: item.getThumbnail(width: 120, height: 120),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.isVideo ? Icons.videocam : Icons.photo, size: 20, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.shortDate} • ${item.width}×${item.height} px',
                          style: TextStyle(color: colors.subtleText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenViewer(
                            items: group.items,
                            initialIndex: group.items.indexOf(item),
                          ),
                        ),
                      );
                    },
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
