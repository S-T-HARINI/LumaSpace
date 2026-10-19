import 'package:flutter_test/flutter_test.dart';
import 'package:lumaspace/core/theme/theme_provider.dart';
import 'package:lumaspace/main.dart';
import 'package:lumaspace/providers/deletion_provider.dart';
import 'package:lumaspace/providers/gallery_provider.dart';
import 'package:lumaspace/providers/review_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LumaSpaceApp boots successfully', (tester) async {
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
        child: const LumaSpaceApp(),
      ),
    );

    expect(find.text('LumaSpace'), findsWidgets);
  });
}
