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
    // Replace with your server's IP/domain
    return "http://192.168.18.64:8000$image";
  }
}
