import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/deletion_provider.dart';
import '../providers/gallery_provider.dart';
import '../providers/review_provider.dart';
import 'gallery/gallery_screen.dart';
import 'pending/pending_deletion_screen.dart';
import 'review/review_screen.dart';
import 'settings/settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    final deletion = context.watch<DeletionProvider>();
    final gallery = context.watch<GalleryProvider>();
    final colors = context.appColors;

    final pendingCount = deletion
        .getPendingItems(gallery.displayedItems, review.pendingDeleteIds)
        .length;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const GalleryScreen(),
            ReviewScreen(onNavigateToTab: _onTabTapped),
            PendingDeletionScreen(onNavigateToTab: _onTabTapped),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library_rounded),
              label: 'Gallery',
            ),
            const NavigationDestination(
              icon: Icon(Icons.swipe_outlined),
              selectedIcon: Icon(Icons.swipe_rounded),
              label: 'Review',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                backgroundColor: colors.deleteColor,
                child: const Icon(Icons.delete_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                backgroundColor: colors.deleteColor,
                child: const Icon(Icons.delete_rounded),
              ),
              label: 'Pending',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
