import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/core/theme/app_theme.dart';
import 'package:lumaspace/screens/pending/widgets/deletion_confirmation_dialog.dart';

void main() {
  testWidgets('DeletionConfirmationDialog renders count, size, and triggers confirmation', (tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.googleLight,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeletionConfirmationDialog.show(
                  context,
                  fileCount: 5,
                  formattedSize: '42.5 MB',
                  onConfirm: () => confirmed = true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Confirm Deletion'), findsOneWidget);
    expect(find.text('You are about to delete 5 files.'), findsOneWidget);
    expect(find.text('Reclaiming ~42.5 MB of storage'), findsOneWidget);

    // Tap Proceed to Delete
    await tester.tap(find.text('Proceed to Delete'));
    await tester.pumpAndSettle();

    expect(confirmed, true);
    expect(find.text('Confirm Deletion'), findsNothing);
  });
}
