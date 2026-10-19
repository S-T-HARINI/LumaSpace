import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'providers/deletion_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/review_provider.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  final galleryProvider = GalleryProvider();
  final reviewProvider = ReviewProvider();
  final deletionProvider = DeletionProvider();

  // Initialize providers
  await reviewProvider.initialize();
  await galleryProvider.initialize();

  runApp(
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
}

class LumaSpaceApp extends StatelessWidget {
  const LumaSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    return MaterialApp(
      title: 'LumaSpace',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getThemeData(systemBrightness),
      home: const MainScaffold(),
    );
  }
}
