import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/media_item.dart';

class ImageViewer extends StatefulWidget {
  final MediaItem item;

  const ImageViewer({super.key, required this.item});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
  File? _file;
  bool _isLoading = true;
  String? _error;
  final TransformationController _transformController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadFile();
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    try {
      final file = await widget.item.getFile();
      if (!mounted) return;
      if (file != null && await file.exists()) {
        setState(() {
          _file = file;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Media file is not accessible or was removed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load image: $e';
        _isLoading = false;
      });
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_zoomAnimation != null && _animationController.isAnimating) return;

    final currentMatrix = _transformController.value;
    final isZoomed = currentMatrix.getMaxScaleOnAxis() > 1.2;

    final Matrix4 targetMatrix;
    if (isZoomed) {
      targetMatrix = Matrix4.identity();
    } else {
      final position = details.localPosition;
      // ignore: deprecated_member_use
      targetMatrix = Matrix4.identity()
        // ignore: deprecated_member_use
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        // ignore: deprecated_member_use
        ..scale(2.5);
    }

    _zoomAnimation = Matrix4Tween(begin: currentMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.reset();
    _zoomAnimation!.addListener(() {
      _transformController.value = _zoomAnimation!.value;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingView(message: 'Loading image...'));
    }

    if (_error != null || _file == null) {
      return Center(
        child: ErrorStateView(
          title: 'Image Unavailable',
          message: _error ?? 'File cannot be displayed.',
          onRetry: _loadFile,
        ),
      );
    }

    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 1.0,
        maxScale: 4.5,
        clipBehavior: Clip.none,
        child: Center(
          child: Image.file(
            _file!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
