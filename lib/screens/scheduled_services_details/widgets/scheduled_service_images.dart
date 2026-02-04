import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledServiceImages extends StatelessWidget {
  final Shipment shipment;

  const ScheduledServiceImages({super.key, required this.shipment});

  void _openFullScreenGallery(
    BuildContext context,
    List images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => _FullScreenGallery(
        images: images.map((e) => e.imageUrl as String).toList(),
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = shipment.serviceOrdered?.order?.orderPictures;
    if (images == null || images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Service Images",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Kolors.kDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final imageUrl = images[index].imageUrl;

              return GestureDetector(
                onTap: () =>
                    _openFullScreenGallery(context, images, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        color: Kolors.kOffWhite,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress
                                        .expectedTotalBytes !=
                                    null
                                ? loadingProgress
                                        .cumulativeBytesLoaded /
                                    loadingProgress
                                        .expectedTotalBytes!
                                : null,
                            color: Kolors.kPrimary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: Kolors.kOffWhite,
                      child: const Icon(Icons.broken_image,
                          color: Kolors.kDark),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() =>
      _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int currentIndex;

  final Map<int, TransformationController> _controllers = {};

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  TransformationController _getController(int index) {
    return _controllers.putIfAbsent(
      index,
      () => TransformationController(),
    );
  }

  void _handleDoubleTap(
      int index, TapDownDetails details) {
    final controller = _getController(index);
    final position = details.localPosition;

    if (controller.value != Matrix4.identity()) {
      controller.value = Matrix4.identity();
    } else {
      controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => currentIndex = i),
          itemBuilder: (context, index) {
            final imageUrl = widget.images[index];
            final controller = _getController(index);

            return Center(
              child: GestureDetector(
                onDoubleTapDown: (details) =>
                    _handleDoubleTap(index, details),
                child: InteractiveViewer(
                  transformationController: controller,
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(imageUrl),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
