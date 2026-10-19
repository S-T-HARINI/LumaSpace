import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'lift_container.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? customColor;
  final Color? customTextColor;
  final EdgeInsetsGeometry padding;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.customColor,
    this.customTextColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.appColors;

    final bgColor = isSelected
        ? theme.colorScheme.primary
        : (customColor ?? colors.chipBackground);

    final fgColor = isSelected
        ? theme.colorScheme.onPrimary
        : (customTextColor ?? theme.colorScheme.onSurface);

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : colors.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;

    return LiftContainer(
      onTap: onTap,
      scaleFactor: 0.95,
      child: chip,
    );
  }
}
