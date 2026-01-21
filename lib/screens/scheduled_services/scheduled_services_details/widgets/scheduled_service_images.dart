import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledServiceImages extends StatelessWidget {
  final Shipment shipment;

  const ScheduledServiceImages({super.key, required this.shipment});

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
            itemBuilder: (_, index) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index].imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 120,
                    height: 120,
                    color: Kolors.kOffWhite,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
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
                  child: const Icon(Icons.broken_image, color: Kolors.kDark),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
