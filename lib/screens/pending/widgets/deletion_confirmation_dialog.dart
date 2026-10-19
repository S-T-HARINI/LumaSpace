import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lift_container.dart';

class DeletionConfirmationDialog extends StatelessWidget {
  final int fileCount;
  final String formattedSize;
  final VoidCallback onConfirm;

  const DeletionConfirmationDialog({
    super.key,
    required this.fileCount,
    required this.formattedSize,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int fileCount,
    required String formattedSize,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeletionConfirmationDialog(
        fileCount: fileCount,
        formattedSize: formattedSize,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = context.theme;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.deleteColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_forever_rounded, color: colors.deleteColor, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Confirm Deletion',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to delete $fileCount ${fileCount == 1 ? "file" : "files"}.',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          if (formattedSize != '0 B' && formattedSize != 'Unknown size')
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.chipBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.cleaning_services_rounded, size: 16, color: colors.keepColor),
                  const SizedBox(width: 8),
                  Text(
                    'Reclaiming ~$formattedSize of storage',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'The Android/iOS operating system will prompt you for approval. Deletion cannot be undone once confirmed by the system.',
            style: TextStyle(
              color: colors.subtleText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        LiftContainer(
          scaleFactor: 0.95,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.deleteColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
              onConfirm();
            },
            child: const Text('Proceed to Delete'),
          ),
        ),
      ],
    );
  }
}
