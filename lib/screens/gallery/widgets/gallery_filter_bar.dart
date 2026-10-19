import 'package:flutter/material.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../providers/gallery_provider.dart';

class GalleryFilterBar extends StatelessWidget {
  final GalleryFilterOption selectedOption;
  final ValueChanged<GalleryFilterOption> onSelect;

  const GalleryFilterBar({
    super.key,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          BadgeChip(
            label: 'All',
            icon: Icons.all_inclusive,
            isSelected: selectedOption == GalleryFilterOption.all,
            onTap: () => onSelect(GalleryFilterOption.all),
          ),
          const SizedBox(width: 8),
          BadgeChip(
            label: 'Photos',
            icon: Icons.photo_outlined,
            isSelected: selectedOption == GalleryFilterOption.photosOnly,
            onTap: () => onSelect(GalleryFilterOption.photosOnly),
          ),
          const SizedBox(width: 8),
          BadgeChip(
            label: 'Videos',
            icon: Icons.videocam_outlined,
            isSelected: selectedOption == GalleryFilterOption.videosOnly,
            onTap: () => onSelect(GalleryFilterOption.videosOnly),
          ),
          const SizedBox(width: 8),
          BadgeChip(
            label: 'Large Files',
            icon: Icons.storage_outlined,
            isSelected: selectedOption == GalleryFilterOption.largeFiles,
            onTap: () => onSelect(GalleryFilterOption.largeFiles),
          ),
        ],
      ),
    );
  }
}
