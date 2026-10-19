import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';
import '../../../providers/gallery_provider.dart';

class GallerySortSheet extends StatelessWidget {
  final GallerySortOption currentSort;
  final ValueChanged<GallerySortOption> onSelect;

  const GallerySortSheet({
    super.key,
    required this.currentSort,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required GallerySortOption currentSort,
    required ValueChanged<GallerySortOption> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => GallerySortSheet(
        currentSort: currentSort,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Media',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),
            ...GallerySortOption.values.map((option) {
              final isSelected = option == currentSort;
              return LiftContainer(
                onTap: () {
                  onSelect(option);
                  Navigator.pop(context);
                },
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      _getIcon(option),
                      color: isSelected ? theme.colorScheme.primary : colors.subtleText,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            option.description,
                            style: TextStyle(
                              color: colors.subtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(GallerySortOption option) {
    switch (option) {
      case GallerySortOption.dateDesc:
        return Icons.arrow_downward_rounded;
      case GallerySortOption.dateAsc:
        return Icons.arrow_upward_rounded;
      case GallerySortOption.sizeDesc:
        return Icons.sort_by_alpha_rounded;
      case GallerySortOption.sizeAsc:
        return Icons.filter_list_rounded;
    }
  }
}
