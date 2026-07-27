import 'package:flutter/material.dart';

/// Full-screen image viewer opened by tapping a sign's step image.
/// Dismiss by tapping the image, the close button, or the system back
/// button/gesture (which works automatically since this is just a normal
/// pushed route).
class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late int _currentIndex = widget.initialIndex;
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child:
                        Image.asset(widget.images[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Text(
                  'Step ${_currentIndex + 1} of ${widget.images.length} — tap to close',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
