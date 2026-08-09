class CostOfServiceImageModel {
  final int? id;
  final String? image;
  final String? imageUrl;
  final String? uploadedAt;

  CostOfServiceImageModel({
    this.id,
    this.image,
    this.imageUrl,
    this.uploadedAt,
  });

  factory CostOfServiceImageModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return CostOfServiceImageModel();
    }

    return CostOfServiceImageModel(
      id: json["id"],
      image: json["image"],
      imageUrl: json["image_url"],
      uploadedAt: json["uploaded_at"],
    );
  }

  static List<CostOfServiceImageModel> listFromJson(
    List<dynamic>? data,
  ) {
    if (data == null) return [];

    return data
        .map(
          (e) => CostOfServiceImageModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "image": image,
      "image_url": imageUrl,
      "uploaded_at": uploadedAt,
    };
  }
}