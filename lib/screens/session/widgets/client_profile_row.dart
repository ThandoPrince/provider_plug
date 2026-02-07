import 'package:flutter/material.dart';

class ClientProfileRow extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double? rating; // ⭐ NEW

  const ClientProfileRow({
    super.key,
    required this.name,
    this.imageUrl,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: imageUrl == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullImageView(imageUrl: imageUrl!),
                ),
              );
            },
      child: Row(
        children: [
          Hero(
            tag: imageUrl ?? name,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),

          const SizedBox(width: 14),

          /// NAME
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          /// ⭐ RATINGS SECTION
          if (rating != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
class _FullImageView extends StatelessWidget {
  final String imageUrl;

  const _FullImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
