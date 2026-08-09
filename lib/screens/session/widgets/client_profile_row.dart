// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/common/utils/kcolors.dart';

// class ClientProfileRow extends StatelessWidget {
//   final String name;
//   final String? imageUrl;
//   final double? rating;

//   const ClientProfileRow({
//     super.key,
//     required this.name,
//     this.imageUrl,
//     this.rating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: imageUrl == null
//           ? null
//           : () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => _FullImageView(imageUrl: imageUrl!)),
//               ),
//       child: Row(
//         children: [
//           Hero(
//             tag: imageUrl ?? name,
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Kolors.kPrimary.withOpacity(0.1), width: 2),
//               ),
//               child: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: Colors.grey.shade100,
//                 backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
//                 child: imageUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                     color: Kolors.kDark,
//                   ),
//                 ),
//                 if (rating != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
//                         const SizedBox(width: 4),
//                         Text(
//                           rating!.toStringAsFixed(1),
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//         ],
//       ),
//     );
//   }
// }

// class _FullImageView extends StatelessWidget {
//   final String imageUrl;
//   const _FullImageView({required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0),
//       body: Center(
//         child: InteractiveViewer(
//           child: Hero(tag: imageUrl, child: Image.network(imageUrl)),
//         ),
//       ),
//     );
//   }
// }