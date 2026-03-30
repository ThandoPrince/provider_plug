import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrderPictureModel {
  final int id;
  final String image;

  OrderPictureModel({
    required this.id,
    required this.image,
  });

  factory OrderPictureModel.fromJson(Map<String, dynamic> json) {
    return OrderPictureModel(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }

  /// ✅ Add this to serialize back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
    };
  }

  String get imageUrl {
    final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
    // Replace with your server's IP/domain
    return "$baseUrl$image";
  }
}
