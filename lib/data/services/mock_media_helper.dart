import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MockMediaHelper {
  static Future<Uint8List> _createGradientThumbnail(Color startColor, Color endColor, bool isVideo) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 400));

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(400, 400),
        [startColor, endColor],
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 400, 400), const Radius.circular(16)),
      paint,
    );

    // Decorative circle
    final circlePaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(const Offset(200, 200), 80, circlePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 400);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<List<MediaItem>> generateMockItems() async {
    final thumb1 = await _createGradientThumbnail(const Color(0xFF1E88E5), const Color(0xFF1565C0), false);
    final thumb2 = await _createGradientThumbnail(const Color(0xFF43A047), const Color(0xFF2E7D32), false);
    final thumb3 = await _createGradientThumbnail(const Color(0xFFE53935), const Color(0xFFC62828), true);
    final thumb4 = await _createGradientThumbnail(const Color(0xFFFB8C00), const Color(0xFFEF6C00), false);
    final thumb5 = await _createGradientThumbnail(const Color(0xFF8E24AA), const Color(0xFF6A1B9A), true);
    final thumb6 = await _createGradientThumbnail(const Color(0xFF00ACC1), const Color(0xFF00838F), false);
    final thumb7 = await _createGradientThumbnail(const Color(0xFF3949AB), const Color(0xFF283593), false);
    final thumb8 = await _createGradientThumbnail(const Color(0xFFD81B60), const Color(0xFFAD1457), true);

    return [
      MediaItem(
        id: 'mock_item_1',
        title: '[Mock Data] Mountain Sunrise.jpg',
        type: MediaItemType.image,
        size: 1024 * 1024 * 4 + 500 * 1024, // 4.5 MB
        createDateTime: DateTime.now().subtract(const Duration(hours: 2)),
        width: 3840,
        height: 2160,
        preloadedThumbnail: thumb1,
      ),
      MediaItem(
        id: 'mock_item_2',
        title: '[Mock Data] Forest Trail.jpg',
        type: MediaItemType.image,
        size: 1024 * 1024 * 8 + 200 * 1024, // 8.2 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 2)),
        width: 4032,
        height: 3024,
        preloadedThumbnail: thumb2,
      ),
      MediaItem(
        id: 'mock_item_3',
        title: '[Mock Data] Coastal Drone Video.mp4',
        type: MediaItemType.video,
        size: 1024 * 1024 * 48, // 48 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 5)),
        duration: const Duration(minutes: 1, seconds: 45),
        width: 1920,
        height: 1080,
        preloadedThumbnail: thumb3,
      ),
      MediaItem(
        id: 'mock_item_4',
        title: '[Mock Data] Golden Sunset.jpg',
        type: MediaItemType.image,
        size: 1024 * 1024 * 14 + 100 * 1024, // 14.1 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 10)),
        width: 4000,
        height: 3000,
        preloadedThumbnail: thumb4,
      ),
      MediaItem(
        id: 'mock_item_5',
        title: '[Mock Data] City Skyline Timelapse.mp4',
        type: MediaItemType.video,
        size: 1024 * 1024 * 32 + 500 * 1024, // 32.5 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 25)),
        duration: const Duration(seconds: 42),
        width: 3840,
        height: 2160,
        preloadedThumbnail: thumb5,
      ),
      MediaItem(
        id: 'mock_item_6',
        title: '[Mock Data] Ocean Waves.jpg',
        type: MediaItemType.image,
        size: 1024 * 1024 * 3 + 100 * 1024, // 3.1 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 45)),
        width: 3000,
        height: 2000,
        preloadedThumbnail: thumb6,
      ),
      MediaItem(
        id: 'mock_item_7',
        title: '[Mock Data] Architectural Detail.jpg',
        type: MediaItemType.image,
        size: 1024 * 1024 * 18, // 18 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 90)),
        width: 5000,
        height: 3333,
        preloadedThumbnail: thumb7,
      ),
      MediaItem(
        id: 'mock_item_8',
        title: '[Mock Data] Festival Highlights.mp4',
        type: MediaItemType.video,
        size: 1024 * 1024 * 75, // 75 MB
        createDateTime: DateTime.now().subtract(const Duration(days: 120)),
        duration: const Duration(minutes: 3, seconds: 12),
        width: 1920,
        height: 1080,
        preloadedThumbnail: thumb8,
      ),
    ];
  }
}
