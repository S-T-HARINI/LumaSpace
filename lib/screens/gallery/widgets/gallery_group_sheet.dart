import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';
import '../../../providers/gallery_provider.dart';

class GalleryGroupSheet extends StatelessWidget {
  final GalleryGroupOption currentGroup;
  final ValueChanged<GalleryGroupOption> onSelect;

  const GalleryGroupSheet({
    super.key,
    required this.currentGroup,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required GalleryGroupOption currentGroup,
    required ValueChanged<GalleryGroupOption> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => GalleryGroupSheet(
        currentGroup: currentGroup,
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
            Row(
              children: [
                Icon(Icons.calendar_view_month_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Group Media',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...GalleryGroupOption.values.map((option) {
              final isSelected = option == currentGroup;
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
                      option.icon,
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
}
