import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_pictures_model.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/widgets/full_screen_gallery.dart';

class DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color primaryTextColor;

  const DetailCard({
    super.key,
    required this.title,
    required this.children,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isRating = label.toLowerCase().contains("rating");
    bool isName = label.toLowerCase().contains("name");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (isRating) _buildRatingPill(value) 
          else if (isName) _buildNameWidget(value)
          else _buildStandardValue(value),
        ],
      ),
    );
  }

  Widget _buildStandardValue(String val) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        val,
        style: TextStyle(
          color: onTap != null ? Colors.blueAccent : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
    );
  }

  Widget _buildRatingPill(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNameWidget(String val) {
    return Row(
      children: [
       
        const SizedBox(width: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }
}

class DetailCardHeader extends StatelessWidget {
  final String title;
  const DetailCardHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingImagesList extends StatelessWidget {
  final List<OrderPictureModel> images;
  final Color primaryTextColor;

  const BookingImagesList({super.key, required this.images, required this.primaryTextColor});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: "Service Images",
      primaryTextColor: primaryTextColor,
      children: [
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        images: images.map((e) => e.imageUrl).toList(),
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'gallery_img_$index',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      images[index].imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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