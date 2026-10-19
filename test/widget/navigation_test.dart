import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/core/theme/theme_provider.dart';
import 'package:lumaspace/providers/deletion_provider.dart';
import 'package:lumaspace/providers/gallery_provider.dart';
import 'package:lumaspace/providers/review_provider.dart';
import 'package:lumaspace/screens/main_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MainScaffold displays navigation destinations and switches tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    final galleryProvider = GalleryProvider();
    final reviewProvider = ReviewProvider();
    final deletionProvider = DeletionProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: galleryProvider),
          ChangeNotifierProvider.value(value: reviewProvider),
          ChangeNotifierProvider.value(value: deletionProvider),
        ],
        child: const MaterialApp(
          home: MainScaffold(),
        ),
      ),
    );

    // Initial tab is Gallery
    expect(find.text('Gallery'), findsWidgets);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);

    // Switch to Pending tab
    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();

    expect(find.text('Pending Deletion'), findsOneWidget);
  });
}
